module PC_LOGIC(
        input resetn,
        input clk,
        input ld,
        input inc,
        input jump,
        input [4:0] pc_in,
        output reg [4:0] pc_out
);
    
    always@(posedge clk or negedge resetn) begin
        if(~resetn) pc_out <= 5'b0_0000;
        else begin
            if(ld) begin
                if(jump)     pc_out <= pc_in;
                else if(inc) pc_out <= pc_out + 1'b1;
            end
        end
    end
endmodule
