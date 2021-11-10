`timescale 1ns/100ps

module incr_top;

	test_normal test_normal();

	initial begin
		$timeformat(-9,0, "", 1);
      	$dumpfile("dump.vcd");
		$dumpvars(0);

        $display("[%0t] [INFO] Simulation is started", $time);
		top.clk = 'b0;
		top.resetn = 'b0;

		// Initial Value

		#100
		top.resetn = 'b1;

		// Test case
		if ($test$plusargs("NORMAL_TEST")) test_normal.TEST_NORMAL;
		
		#100
		// End value or Post Process
	
		#100
        $display("[%0t] [INFO] Simulation is end\n", $time);
		if(top.error_count == 0) begin
			$display("[INFO] TEST_PASSED");
		end
		else begin
			$display("[INFO] TEST_FAILED");
		end
		$display("	Warning Count   : %d", top.warning_count);
		$display("	Error Count     : %d", top.error_count);

		$finish;
	end
endmodule
