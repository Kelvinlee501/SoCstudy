module FLAG(
        input resetn,
        input clk,
        input ld,
        input [7:0] acc_result,
        output reg flag
);
    
    always@(posedge clk or negedge resetn) begin
        if(~resetn) flag <= 1'b0;
        else begin
            case(acc_result)
                8'b0000_0000 : if(ld == 1'b1) flag <= 1'b1;
                default      : if(ld == 1'b1) flag <= 1'b0;
            endcase
        end
    end
endmodule
