`timescale 1ns/100ps

module top;
	//include top design define files
	`include "top_defines.sv"
	
	reg clk;
	reg resetn;

	initial begin
		forever #(P_CLK_PERIOD/2) clk <= ~clk;
	end

	`ifdef QuestaSim
		initial begin
			$dumpfile("dump.vcd");
			$dumpvars(0);
		end
	`endif

	//TOP module instanciation
	I2C #(
		.PARAM(PARAM_TEMPLETE)
	) dut (
		.I_CLK(clk),
		.I_RESETn(resetn)
	);

endmodule
