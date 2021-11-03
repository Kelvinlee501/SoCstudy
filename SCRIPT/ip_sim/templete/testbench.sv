`timescale 1ns/100ps


module tb;
	`include "sim_param.svh"

	reg				clk;
	reg				resetn;

	// vip.sv file define
	`include "vip.svh"

	// monitor.sv file define
	`include "monitor.svh"

	// test_normal_access.sv file define
	`include "../tests/test_templete.svh"

	initial begin
		forever #(P_CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		$timeformat(-9,0, "", 1);
      	$dumpfile("dump.vcd");
		$dumpvars(0);

        $display("[%0t] [INFO] Simulation is started", $time);
		clk = 'b0;
		resetn = 'b0;

		// Initial Value

		#100
		resetn = 'b1;

		// Test case
		if ($test$plusargs("NORMAL_TEST")) TASK_NORMAL_TEST;
		
		#100
		// End value or Post Process
	
		#100
        $display("[%0t] [INFO] Simulation is end\n", $time);
		if(error_count == 0) begin
			$display("[INFO] TEST_PASSED");
		end
		else begin
			$display("[INFO] TEST_FAILED");
		end
		$display("	Warning Count   : %d", warning_count);
		$display("	Error Count     : %d", error_count);

		$finish;
	end

	src_templete #(
		.PARAM				(PARAM_TEMPLETE)
	) dut (
		.I_CLK				(clk),
		.I_RESETn			(resetn)
	);

	`include "vip.sv"
	`include "monitor.sv"

	// TEST list
	`include "../tests/test_templete.sv"

endmodule
