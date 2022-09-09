module ALU(
        input [2:0] opcode,
        input [7:0] in1,
        input [7:0] in2,
        input [7:0] mem_data_in,
        input datamem_sel,
        output reg [7:0] alu2datamem,
        output [7:0] alu_out
);

    always@(*) begin
        case(opcode)
            3'b010  : alu2datamem = in1 + in2;
            3'b011  : alu2datamem = in1 & in2;
            3'b100  : alu2datamem = in1 ^ in2;
            3'b101  : alu2datamem = in2;
            3'b110  : alu2datamem = in1;
            default : alu2datamem = 8'b0000_0000;
        endcase
    end

    assign alu_out = datamem_sel ? mem_data_in : alu2datamem; 

endmodule
