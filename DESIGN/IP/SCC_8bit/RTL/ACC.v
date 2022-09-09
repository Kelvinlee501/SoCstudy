module ACC(
        input resetn,
        input clk,
        input ld,
        input [7:0] acc_in,
        output reg [7:0] acc_out
);
    
    always@(posedge clk or negedge resetn) begin
        if(~resetn) acc_out <= 8'b0000_0000;
        else if(ld) acc_out <= acc_in;
    end
endmodule
