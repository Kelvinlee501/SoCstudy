
		if(top.error_count == 0) begin
			$display("[INFO] TEST_PASSED");
		end
		else begin
			$display("[INFO] TEST_FAILED");
		end
		$display("	Warning Count   : %d", top.warning_count);
		$display("	Error Count     : %d", top.error_count);
