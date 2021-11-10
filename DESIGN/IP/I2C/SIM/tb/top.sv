`timescale 1ns/100ps

module top;
	`include "tb/sim_param.svh"

	reg				clk;
	reg				resetn;

	// vip.sv file define
	`include "lib/vip.svh"

	// monitor.sv file define
	`include "lib/monitor.svh"


	initial begin
		forever #(P_CLOCK_PERIOD/2) clk <= ~clk;
	end
	
`ifdef QuestaSim
	initial begin
      	$dumpfile("dump.vcd");
		$dumpvars(0);
	end
`endif

	I2C #(
		.PARAM				(PARAM_TEMPLETE)
	) dut (
		.I_CLK				(clk),
		.I_RESETn			(resetn)
	);

	`include "lib/vip.sv"
	`include "lib/monitor.sv"

endmodule
