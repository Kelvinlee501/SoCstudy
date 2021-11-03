
	typedef enum	{DEFAULT, CASE1, CASE2} sim_state;

	sim_state		now_state;

	initial begin
		now_state = DEFAULT;
		local_error_cnt = 0;
	end
	
	task TASK_NORMAL_TEST;
		TASK_CASE1;
		TASK_CASE2;
	endtask

	task TASK_CASE1;
		now_state = CASE1;
		$display("===============================================");
		$display("| [INFO] Test Case : %s", now_state);
		$display("===============================================");
		local_error_cnt = error_count;

		// CUSTOM TEST

		if(local_error_cnt == error_count) begin
			$display("\n	LOCAL TEST PASSED\n");
		end
		else begin
			$display("\n	LOCAL TEST FAILED\n");
		end
	endtask

	task TASK_CASE2;
		now_state = CASE2;
		$display("===============================================");
		$display("| [INFO] Test Case : %s", now_state);
		$display("===============================================");
		local_error_cnt = error_count;

		// CUSTOM TEST

		if(local_error_cnt == error_count) begin
			$display("\n	LOCAL TEST PASSED\n");
		end
		else begin
			$display("\n	LOCAL TEST FAILED\n");
		end
	endtask

