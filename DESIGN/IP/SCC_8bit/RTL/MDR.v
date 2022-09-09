module MDR(
        input resetn,
        input clk,
        input ld,
        input [7:0] mdr_in,
        output reg [7:0] mdr_out
);
    
    always@(posedge clk or negedge resetn) begin
        if(~resetn) mdr_out <= 8'b0000_0000;
        else if(ld) mdr_out <= mdr_in;
    end
endmodule
