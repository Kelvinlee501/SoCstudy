
module task_i2c;

	task task_compare_i2c_data;
	begin
		$display("[%0t][ERROR] task_compare_i2c_data is not defined", $time);
		top.error_count = top.error_count + 1;
	end
	endtask
endmodule
