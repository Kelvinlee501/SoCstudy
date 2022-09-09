//Single-Cycle 8bit custom ISA CPU core

module SCC_8bit(
    //system clock & reset
    input resetn,
    input clk,

    //instuction memory interface
    output [4:0] inst_addr,
    input [7:0] inst,

    //data memeory insterface
    output [7:0] mem_wdata,
    input [7:0] mem_rdata
);

    //wire declear
    wire [7:0] acc_out;
    wire [7:0] mdr_out;
    wire [7:0] alu_out;
    wire [7:0] alu2datamem_out;
    wire flag_zero;

    //-------------------------------------
    //Instantiate data path logics
    //-------------------------------------
    PC_LOGIC pc_logic (
        .resetn(resetn),
        .clk(clk),
        .ld(),
        .inc(),
        .jump(),
        .pc_in(inst[4:0]),
        .pc_out()
    );

    FLAG flag (
        .resetn(resetn),
        .clk(clk),
        .ld(),
        .acc_result(acc_out),
        .flag(flag_zero)
    );

    ACC acc (
        .resetn(resetn),
        .clk(clk),
        .ld(),
        .acc_in(alu_out),
        .acc_out(acc_out)
    );
    
    MDR mdr (
        .resetn(resetn),
        .clk(clk),
        .ld(),
        .mdr_in(),
        .mdr_out(mdr_out)
    );

    ALU alu(
        .opcode(inst[7:5]),
        .in1(acc_out),
        .in2(mdr_out),
        .mem_data_in(mem_rdata),
        .datamem_sel(),
        .alu2datamem(alu2datamem_out),
        .alu_out(alu_out),
    );

    //instantiate control logic


    
    //-------------------------------------
    //Assignments
    //-------------------------------------
    assign mem_wdata = alu2datamem_out;

endmodule
