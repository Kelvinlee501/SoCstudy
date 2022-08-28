/////////////////////////////////////////////////////////////////////////
// Project     : AXI2APB bridge
// Function    : Change protocol from AXI to APB
// update date : 21/12/10
/////////////////////////////////////////////////////////////////////////

module AXI2APB_BRIDGE #(
    //module_instance parameter
	parameter			ID_WIDTH = 4
) (
    //=============================================================
    // AXI4 slave interface
    //=============================================================
    // Global Signal
	input						ACLK,     //AXI bus global clock
	input						ARESETn,  //AXI bus global reset, active low

    // AR-channel
    input [(ID_WIDTH-1):0]      ARID,     //Read address ID
    input [31:0]                ARADDR,   //Read address
    input                       ARLEN,    //Read burst length
    input                       ARSIZE,   //Read burst size
    input                       ARBURST,  //Read burst type
    input                       ARVALID,  //Read address valid
    output wire                 ARREADY,  //Read address ready
    input                       ARPROT,   //Read protection information

    // R-channel
    output reg [(ID_WIDTH-1):0] RID,      //Read data ID
    output reg                  RLAST,    //Read data last
    output reg [31:0]           RDATA,    //Read data
    output reg                  RRESP,    //Read response
    output reg                  RVALID,   //Read data valid
    input                       RREADY,   //Read data ready

    // AW-channel
    input [(ID_WIDTH-1):0]      AWID,     //Write address ID
    input [31:0]                AWADDR,   //Write address
    input                       AWLEN,    //Write burst length
    input                       AWSIZE,   //Write burst size
    input                       AWBURST,  //Write burst type
    input                       AWVALID,  //Write address valid
    output wire                 AWREADY,  //Write address ready
    input                       AWPROT,   //Write protection information

    // W-channel
    input                       WLAST,    //Write data last
    input [31:0]                WDATA,    //Write data
    input                       WSTRB,    //Write strobe
    input                       WVALID,   //Write data valid
    output wire                 WREADY,   //Write data ready

    // B-channel
    output reg [(ID_WIDTH-1):0] BID,      //Write response ID
    output reg                  BRESP,    //Write response
    output reg                  BVALID,   //Write response valid
    input                       BREADY,   //Write response ready

    //=============================================================
    // APB4 slave interface
    //=============================================================

    output reg [31:0]           PADDR,    //APB address
    output reg                  PPROT,    //APB protection type
    output reg                  PSEL,     //APB select
    output reg                  PENABLE,  //APB enable
    output wire                 PWRITE,   //APB R/W control
    output reg [31:0]           PWDATA,   //APB write data
    output reg                  PSTRB,    //APB strobe
    input                       PREADY,   //APB ready
    input      [31:0]           PRDATA,   //APB read data
    input                       PSLVERR   //APB error response

);
    //==========================================
    // parameter define
    //==========================================

    localparam AXI_FSM_IDLE                  = 6'b00_0001;
    localparam AXI_FSM_APB_TRANS             = 6'b00_0010;
    localparam AXI_FSM_WAIT_RREADY           = 6'b00_0100;
    localparam AXI_FSM_WAIT_WVALID_OR_BREADY = 6'b00_1000;
    localparam AXI_FSM_TXN_WRERR             = 6'b01_0000;
    localparam AXI_FSM_TXN_RDERR             = 6'b10_0000;

    localparam APB_FSM_IDLE   = 3'b001;
    localparam APB_FSM_SETUP  = 3'b010;
    localparam APB_FSM_ACCESS = 3'b100;
    
    //==========================================
    // signals define part
    //==========================================
    // reg signals
    reg        r_ARREADY;
    reg        r_AWREADY;
    reg        r_WREADY;
    reg        NextARREADY;
    reg        NextAWREADY;
    reg        NextWREADY;
    reg        NextBVALID;

    reg        r_PSEL;
    reg        r_PENABLE;
    reg [31:0] r_PADDR;
    reg        r_PWRITE;

    reg        NextPWRITE;

    reg [5:0]  AXI_fsm_nstate;
    reg [5:0]  AXI_fsm_pstate;

    reg [2:0]  APB_fsm_nstate;
    reg [2:0]  APB_fsm_pstate;

    reg        r_APB_trans_start;
    reg        r_APB_trans_complete;
    reg        Next_APB_trans_complete;

    reg        r_ldAXIWRDATA;

    // wire signals

    //==========================================
    // assign part
    //==========================================

    assign ARREADY = r_ARREADY;
    assign AWREADY = r_AWREADY;
    assign WREADY  = r_WREADY;

    assign PWRITE  = r_PWRITE; 

    //==========================================
    // Registered output
    //==========================================

    // AXI Slave RVALID, BVALID reset value
    //always @(posedge ACLK or negedge ARESETn) begin
    //   if(!ARESETn) RVALID <= 1'b0;
    //   else         RVALID <= ;
    //end

    always @(posedge ACLK or negedge ARESETn) begin
       if(!ARESETn) BVALID <= 1'b0;
       else         BVALID <= (NextBVALID&Next_APB_trans_complete);
    end

    // AXI slave RID, BID registered output
    always @(posedge ACLK or negedge ARESETn) begin
       if(!ARESETn)      RID <= {ID_WIDTH{1'b0}};
       else if(r_ARREADY) RID <= ARID;
    end

    always @(posedge ACLK or negedge ARESETn) begin
       if(!ARESETn)      BID <= {ID_WIDTH{1'b0}};
       else if(r_AWREADY) BID <= AWID;
    end

    // AXI AR,AW READY registered output
    always @(posedge ACLK or negedge ARESETn) begin
       if(!ARESETn) begin
            r_ARREADY <= 1'b0;
            r_AWREADY <= 1'b0;
            r_WREADY <= 1'b0;
       end
       else begin
            r_ARREADY <= NextARREADY;
            r_AWREADY <= NextAWREADY;
            r_WREADY  <= NextWREADY;
       end
    end

    //APB4 master source output signal
    always @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn) begin
            PSEL    <= 1'b0;
            PENABLE <= 1'b0;
            PADDR   <= 32'h0000_0000;
        end
        else begin
            PSEL    <= r_PSEL;
            PENABLE <= r_PENABLE;
            PADDR   <= r_PADDR;
        end
    end


    //APB4 PWRITE output signal
    always @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn) r_PWRITE <= 1'b0;
        else         r_PWRITE <= NextPWRITE;
    end

    //APB4 PWDATA output signal
    always @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn)           PWDATA <= {32{1'b0}};
        else if(r_ldAXIWRDATA) PWDATA <= WDATA;
    end

    //APB4 Next trans conplete signal
    always @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn) r_APB_trans_complete <= 1'b0;
        else         r_APB_trans_complete <= Next_APB_trans_complete;
    end


    //=========================================
    //combinational logic part
    //=========================================

    //AXI slave ARREADY, AWREADY comb logic
    always @(AXI_fsm_pstate or ARVALID or AWVALID or WVALID or r_PWRITE) begin
        NextARREADY = 1'b0;
        NextAWREADY = 1'b0;

        if(AXI_fsm_pstate == AXI_FSM_IDLE) begin
            //If previous APB access was a write, give priority to APB read access -> round robin method
            if((ARVALID & r_PWRITE) == 1'b1) begin
                NextARREADY = 1'b1;
            end
            else if((AWVALID & WVALID) == 1'b1) begin
                NextAWREADY = 1'b1;
            end
            else if(ARVALID) begin
                NextARREADY = 1'b1;
            end
        end
    end

    //AXI slave WREADY comb logic
    always @(AXI_fsm_pstate or r_PWRITE or ARVALID or AWVALID or WVALID) begin
        NextWREADY = 1'b0;

        case(AXI_fsm_pstate)
            
            AXI_FSM_IDLE :  begin
                //When the priority given to APB read access is assert then do not load AXI WDATA.
                if(((ARVALID & r_PWRITE) == 1'b0)&&((AWVALID & WVALID) == 1'b1)) begin
                    NextWREADY = 1'b1;
                end
            end
        endcase
    end

    //AXI slave BVALID comb logic
    always @(AXI_fsm_pstate or PREADY or PENABLE or PSEL) begin
        NextBVALID = 1'b0;

        case(AXI_fsm_pstate)
            
            AXI_FSM_APB_TRANS : begin
                if(PREADY & PENABLE & PSEL) begin
                    NextBVALID = 1'b1;
                end
            end

            AXI_FSM_WAIT_WVALID_OR_BREADY : begin
                NextBVALID = 1'b1;
            end
        endcase
    end

    //APB4 PWRITE comb logic
    always @(AXI_fsm_pstate or ARVALID or AWVALID or WVALID or r_PWRITE) begin
        NextPWRITE = r_PWRITE; //Default value

        if(AXI_fsm_pstate == AXI_FSM_IDLE) begin
            //If previous APB access was a write, give priority to APB read access -> round robin method
            if((ARVALID & r_PWRITE) == 1'b1) begin
                NextPWRITE = 1'b0; 
            end
            else if((AWVALID & WVALID) == 1'b1) begin
                NextPWRITE = 1'b1;
            end
            else if(ARVALID) begin
                NextPWRITE = 1'b0;
            end
        end
    end

    //APB4 PWDATA load signal comb logic
    always @(AXI_fsm_pstate or ARVALID or AWVALID or WVALID or r_PWRITE) begin
        r_ldAXIWRDATA = 1'b0;

            case(AXI_fsm_pstate)
            
            AXI_FSM_IDLE :  begin
                //When the priority given to APB read access is assert then do not load AXI WDATA.
                if(((ARVALID & r_PWRITE) == 1'b0)&&((AWVALID & WVALID) == 1'b1)) begin
                    r_ldAXIWRDATA = 1'b1;
                end
            end
        endcase
    end

    //===============================================================================
    //AXI2APB_BRIDGE FSM part..
    //===============================================================================

    //=========================================
    //AXI slave interface FSM
    //=========================================
    //AXI FSM sequential logic
    always @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn) AXI_fsm_pstate <= AXI_FSM_IDLE;
        else         AXI_fsm_pstate <= AXI_fsm_nstate;
    end

    //AXI FSM comb logic
    always @(AXI_fsm_pstate or AWVALID or WVALID or ARVALID or BVALID or BREADY or r_APB_trans_complete or r_PWRITE or PREADY or PENABLE) begin
        AXI_fsm_nstate    = AXI_fsm_pstate;
        r_APB_trans_start = 1'b0;
        r_PADDR           = PADDR;

        case(AXI_fsm_pstate)
            AXI_FSM_IDLE : begin
                //If previous APB access was a write, give priority to APB read access -> round robin method
                if((ARVALID & r_PWRITE) == 1'b1) begin
                   AXI_fsm_nstate = AXI_FSM_APB_TRANS;
                   r_PADDR = ARADDR;
                   r_APB_trans_start = 1'b1;
                end
                else if((AWVALID & WVALID) == 1'b1) begin
                   AXI_fsm_nstate = AXI_FSM_APB_TRANS;
                   r_PADDR  = AWADDR;
                   r_APB_trans_start = 1'b1;
                end
                else if(ARVALID) begin
                   AXI_fsm_nstate = AXI_FSM_APB_TRANS;
                   r_PADDR = ARADDR;
                   r_APB_trans_start = 1'b1;
                end
            end
            
            AXI_FSM_APB_TRANS : begin
                if(PREADY&PENABLE) begin
                    if(r_PWRITE) begin
                        AXI_fsm_nstate = AXI_FSM_WAIT_WVALID_OR_BREADY;
                    end
                    else begin
                        AXI_fsm_nstate = AXI_FSM_WAIT_RREADY;
                    end
                end
            end
            AXI_FSM_WAIT_WVALID_OR_BREADY : begin
                if(r_APB_trans_complete) begin
                    if(BVALID) begin
                        if(BREADY) begin
                            AXI_fsm_nstate = AXI_FSM_IDLE;
                        end
                    end
                end
            end
            AXI_FSM_WAIT_RREADY : begin 
                if(r_APB_trans_complete) begin
                    if(RREADY) begin
                        AXI_fsm_nstate = AXI_FSM_IDLE;
                    end
                end
            end
        endcase
    end
    
    //=========================================
    //APB master interface FSM
    //=========================================
    //APB FSM sequential logic
    always @(posedge ACLK or negedge ARESETn) begin
        if(!ARESETn) APB_fsm_pstate <= APB_FSM_IDLE;
        else         APB_fsm_pstate <= APB_fsm_nstate;
    end

    //APB FSM comb logic
    always @(APB_fsm_pstate or r_APB_trans_start or PREADY) begin

        Next_APB_trans_complete = 1'b0;

        case(APB_fsm_pstate)
            APB_FSM_IDLE   : begin
                if(r_APB_trans_start == 1'b1) begin
                    APB_fsm_nstate = APB_FSM_SETUP;
                    r_PSEL    = 1'b1;
                    r_PENABLE = 1'b0;
                end
                else begin
                    APB_fsm_nstate = APB_FSM_IDLE;
                    r_PSEL    = 1'b0;
                    r_PENABLE = 1'b0;
                end
            end

            APB_FSM_SETUP  : begin
                APB_fsm_nstate = APB_FSM_ACCESS;
                r_PSEL    = 1'b1;
                r_PENABLE = 1'b1;
            end

            APB_FSM_ACCESS : begin
                if(PREADY == 1'b0) begin
                    APB_fsm_nstate = APB_FSM_ACCESS;
                    r_PSEL    = 1'b1;
                    r_PENABLE = 1'b1;
                end
                else if((PREADY == 1'b1)&&(r_APB_trans_start == 1'b1)) begin // and transfer
                    APB_fsm_nstate = APB_FSM_SETUP;
                    r_PSEL    = 1'b1;
                    r_PENABLE = 1'b0;

                    Next_APB_trans_complete = 1'b1;
                end
                else if((PREADY == 1'b1)&&(r_APB_trans_start == 1'b0)) begin // and no transfer
                    APB_fsm_nstate = APB_FSM_IDLE;
                    r_PSEL    = 1'b0;
                    r_PENABLE = 1'b0;

                    Next_APB_trans_complete = 1'b1;
                end
            end
        endcase
    end
endmodule
