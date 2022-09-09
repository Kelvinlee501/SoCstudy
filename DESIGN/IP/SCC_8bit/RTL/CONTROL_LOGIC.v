module CONTROL_LOGIC(
    input resetn,
    input clk,

    input flag_zero,
    input [2:0] opcode,

    //registers load signals
    output reg pc_ld,
    output reg flag_ld,
    output reg acc_ld,
    output reg mdr_ld,

    //selection signals
    output reg pc_jump_sel,
    output reg pc_inc_sel,
    output reg datamem_sel

    //instruction memory controls

    //data memory controls


);

    //-----------------------------
    // define local parameters
    //-----------------------------
    localparam IF  = 3'b000;
    localparam ID  = 3'b001;
    localparam EX  = 3'b010;
    localparam MEM = 3'b011;
    localparam WB  = 3'b100;
    
    //-----------------------------
    // define reg type variables
    //-----------------------------
    reg [2:0] pstate;
    reg [2:0] nstate;


    //-----------------------------
    // Control Logic FSM
    //-----------------------------
    always@(posedge clk or negedge resetn) begin
        if(~resetn) pstate <= IF;
        else        pstate <= nstate;
    end

    always@(*) begin
        case(pstate)
            IF : ;
        endcase
    end

    


endmodule
