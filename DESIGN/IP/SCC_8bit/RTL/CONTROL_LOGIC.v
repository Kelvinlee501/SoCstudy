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
    output reg data_mem_sel

    //instruction memory control signals
    output reg inst_mem_ld,

    //data memory control signals
    output reg data_mem_wt

);

    //--------------------------------------------------------------
    // define local parameters
    //--------------------------------------------------------------
    //Instructions
    localparam HALT  = 3'b000;
    localparam SIFZ  = 3'b001;
    localparam ADD   = 3'b010;
    localparam AND   = 3'b011;
    localparam XOR   = 3'b100;
    localparam LOAD  = 3'b101;
    localparam STORE = 3'b110;
    localparam JUMP  = 3'b111;

    //FSM states
    localparam IDLE = 3'b000;
    localparam IF   = 3'b001;
    localparam ID   = 3'b010;
    localparam EX   = 3'b011;
    localparam MEM  = 3'b100;
    localparam WB   = 3'b100;
    
    //--------------------------------------------------------------
    // define reg type variables
    //--------------------------------------------------------------
    reg [2:0] pstate;
    reg [2:0] nstate;


    //--------------------------------------------------------------
    // Control Logic FSM
    //--------------------------------------------------------------
    always@(posedge clk or negedge resetn) begin
        if(~resetn) pstate <= IDLE;
        else        pstate <= nstate;
    end

    always@(*) begin
        case(pstate)
            IDLE : begin
                {pc_ld, flag_ld, acc_ld, mdr_ld}        = 4'b0000;
                {pc_jump_sel, pc_inc_sel, data_mem_sel} = 3'b000;
                {inst_mem_ld, data_mem_wt}              = 2'b00;
                nstate = IF;
            end
            IF   : begin
                {pc_ld, flag_ld, acc_ld, mdr_ld}        = 4'b0000;
                {pc_jump_sel, pc_inc_sel, data_mem_sel} = 3'b000;
                {inst_mem_ld, data_mem_wt}              = 2'b10;
                nstate = ID;
            end
            ID   : begin
                if(opcode == HALT) begin
                    {pc_ld, flag_ld, acc_ld, mdr_ld}        = 4'b0000;
                    {pc_jump_sel, pc_inc_sel, data_mem_sel} = 3'b000;
                    {inst_mem_ld, data_mem_wt}              = 2'b00;
                    nstate = IF;
                end
                else if(opcode == SIFZ) begin

                end
                else if(opcode == JUMP) begin
                    {pc_ld, flag_ld, acc_ld, mdr_ld}        = 4'b1000;
                    {pc_jump_sel, pc_inc_sel, data_mem_sel} = 3'b100;
                    {inst_mem_ld, data_mem_wt}              = 2'b00;
                    nstate = IF;
                end
            end
        endcase
    end

    


endmodule
