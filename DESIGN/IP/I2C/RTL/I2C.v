////////////////////////////////////
//
//
//
////////////////////////////////////

module I2C #(
	parameter			PARAM = 1	
) (
	input						I_CLK,
	input						I_RESETn
    
    //AMBA4 APB interface
    input PCLK,
    input PRESETn,
    input [31:0] PADDR,
    input PWRTIE,
    input PSEL,
    input PENABLE,
    input [31:0] PWDATA,
    output reg [31:0] PRDATA,
    output reg PREADY,
    output reg PSLVERR

);

endmodule
