`timescale 1ns/100ps

module test_normal;
	`include "tests/test_normal.svh"

	typedef enum	{UNDEFINED, SINGLE_TRANSACTION, DMA_BURST_TRANSACTION, NOT_DEFINED_TEST} sim_state;
	typedef enum	{SINGLE, DMA_BURST} i2c_mode;
	typedef enum	{ON, OFF} remap_mode;

	sim_state		now_state;

	integer			local_error_cnt;
	integer			done;

	task_apb apb_model();
	task_i2c i2c_model();

	initial begin
		now_state = UNDEFINED;
		local_error_cnt = 0;

		done = 0;
	end
	
	task TEST_NORMAL;
		apb_model.apb4m_config;

		TASK_SINGLE_TRANSACTION;
		TASK_DMA_BURST_TRANSACTION;
	endtask

	task TASK_SINGLE_TRANSACTION;
		now_state = SINGLE_TRANSACTION;
		$display("===============================================");
		$display("| [INFO] Test Case : %s", now_state);
		$display("===============================================");
		local_error_cnt = top.error_count;

		// CUSTOM TEST
		task_i2c_config(SINGLE, OFF, 6'b110101);
		task_i2c_write(32'h0012, 2);
		task_i2c_write(32'hcafe, 4);
		task_i2c_write(32'hbeef, 4);

		task_i2c_config(SINGLE, OFF, 6'b111001);
		task_i2c_write(32'h0012, 4);
		task_i2c_write(32'hcafe, 4);
		task_i2c_write(32'hbeef, 4);

		if(local_error_cnt == top.error_count) begin
			$display("\n	LOCAL TEST PASSED\n");
		end
		else begin
			$display("\n	LOCAL TEST FAILED\n");
		end
	endtask

	task TASK_DMA_BURST_TRANSACTION;
		now_state = DMA_BURST_TRANSACTION;
		$display("===============================================");
		$display("| [INFO] Test Case : %s", now_state);
		$display("===============================================");
		local_error_cnt = top.error_count;

		// CUSTOM TEST
		task_i2c_config(DMA_BURST, OFF, 6'b110101);
		task_i2c_dma_config(32'h0010, 32'h0040);

		task_i2c_dma_start;
		wait_transaction_done;

		if(local_error_cnt == top.error_count) begin
			$display("\n	LOCAL TEST PASSED\n");
		end
		else begin
			$display("\n	LOCAL TEST FAILED\n");
		end
	endtask

	task task_i2c_config(
		input	i2c_mode	_set_mode,
		input	remap_mode	_remap_mode,
		input	integer		_device_id
	);
	begin
		case(_set_mode)
			SINGLE : apb_model.task_single_byte_mode_enter;
			DMA_BURST : apb_model.task_dma_burst_mode_enter;
		endcase

		case(_remap_mode)
			ON : apb_model.task_remap_mode_enable;
			OFF : apb_model.task_remap_mode_disable;
		endcase

		apb_model.task_sfr_device_id_0_set(_device_id);
	end
	endtask

	task task_i2c_write(
		input	integer		_data,
		input	integer		_size
	);
	begin
		apb_model.task_sfr_data_size_set(_size);
		apb_model.task_sfr_data_set(_data);

		apb_model.task_single_byte_mode_start;

		wait_transaction_done;
		i2c_model.task_compare_i2c_data;
	end
	endtask

	task task_i2c_dma_config(
		input	integer		_start_addr,
		input	integer		_end_addr
	);
	begin
		apb_model.task_sfr_dma_start_addr_set(_start_addr);
		apb_model.task_sfr_dma_end_addr_set(_end_addr);

		i2c_model.task_compare_i2c_data;
	end
	endtask

	task task_i2c_dma_start;
	begin
		apb_model.task_dma_burst_mode_start;

		i2c_model.task_compare_i2c_data;
	end
	endtask

	task wait_transaction_done;
	begin
		apb_model.task_status_check(done);
		while (done==0) begin
			apb_model.task_status_check(done);
			#1000;
		end
		done = 0;
	end
	endtask

endmodule
