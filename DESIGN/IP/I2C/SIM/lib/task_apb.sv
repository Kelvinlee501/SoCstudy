
module task_apb;
	`include "tests/test_normal.svh"

	task apb4m_config;
		top.apb4m_vip.timeout = 300;			// set MAX cycle for waiting PREADY.
												// if you used iverilog, this is not supported.
		top.apb4m_vip.auto_psel_control = 1;	// psel is automatically controled. if not, need to use active_psel and deactive_psel tasks.
		top.apb4m_vip.pre_psel_delay = 3;		// interval cycle of psel posedge to penable posedge.
		top.apb4m_vip.post_psel_delay = 0;		// interval cycle of penable negedge to psel negedge.

		top.apb4m_monitor.slverr_validate = 0;	// if slverr occurs, it is judged as no error.
		top.apb4m_monitor.monitor_on;			// stop monitoring
		top.apb4m_monitor.display_on;			// if do off, just INFO log is not displayed
	endtask

	task task_single_byte_mode_enter;
	begin
		integer _data;
		integer _result;
		$display("[%0t][INFO] single_byte_mode is started", $time);
		top.apb4m_vip.task_apb_read(_result, `ADDR_MODE_CONFIG, _data);
		if(_result == 2) begin
			$display("[%0t][ERROR] single_byte_mode is failed. because PREADY timeout", $time);
			`ifdef QuestSim
				return;
			`endif
		end
		_data = _data & 32'hffff_fffd;
		top.apb4m_vip.task_apb_write(_result, `ADDR_MODE_CONFIG, _data);
	end
	endtask

	task task_dma_burst_mode_enter;
	begin
		integer _data;
		integer _result;
		$display("[%0t][INFO] task_dma_burst_mode is started", $time);
		top.apb4m_vip.task_apb_read(_result, `ADDR_MODE_CONFIG, _data);
		if(_result == 2) begin
			$display("[%0t][ERROR] dma_burst_mode_enter is failed. because PREADY timeout", $time);
			`ifdef QuestSim
				return;
			`endif
		end
		_data = _data | 32'h0000_0001;
		top.apb4m_vip.task_apb_write(_result, `ADDR_MODE_CONFIG, _data);
	end
	endtask

	task task_remap_mode_enable;
	begin
		integer _data;
		integer _result;
		$display("[%0t][INFO] task_remap_mode is enabled", $time);
		top.apb4m_vip.task_apb_read(_result, `ADDR_MODE_CONFIG, _data);
		if(_result == 2) begin
			$display("[%0t][ERROR] task_remap_mode_enable is failed. because PREADY timeout", $time);
			`ifdef QuestSim
				return;
			`endif
		end
		_data = _data | 32'h0000_0002;
		top.apb4m_vip.task_apb_write(_result, `ADDR_MODE_CONFIG, _data);
	end
	endtask

	task task_remap_mode_disable;
	begin
		integer _data;
		integer _result;
		$display("[%0t][INFO] task_remap_mode is disabled", $time);
		top.apb4m_vip.task_apb_read(_result, `ADDR_MODE_CONFIG, _data);
		if(_result == 2) begin
			$display("[%0t][ERROR] task_remap_mode_disable is failed. because PREADY timeout", $time);
			`ifdef QuestSim
				return;
			`endif
		end
		_data = _data & 32'hffff_fffd;
		top.apb4m_vip.task_apb_write(_result, `ADDR_MODE_CONFIG, _data);
	end
	endtask

	task task_single_byte_mode_start;
	begin
		integer _result;
		$display("[%0t][INFO] single_byte_mode is started", $time);
		top.apb4m_vip.task_apb_write(_result, `ADDR_START, 1);
	end
	endtask

	task task_dma_burst_mode_start;
	begin
		integer _result;
		$display("[%0t][INFO] dma_burst_mode is started", $time);
		top.apb4m_vip.task_apb_write(_result, `ADDR_START, 1);
	end
	endtask

	task task_status_check(
		output	integer		_done
	);
	begin
		integer rdata;
		integer _result;
		top.apb4m_vip.task_apb_read(_result, `ADDR_STATUS, rdata);
		if(rdata[0] == 1) begin
			$display("[%0t][INFO] i2c status is done, Status : %h", $time, rdata);
		end
		else begin
			$display("[%0t][INFO] i2c status is not done, Status : %h", $time, rdata);
		end

		_done = rdata[0];

		$display("[%0t][ERROR] apb module is not designed yet. wait is automatical ended", $time);
		top.error_count = top.error_count + 1;
		force _done = 1;
	end
	endtask

	task task_sfr_device_id_0_set(
		input	integer		_dev_id
	);
	begin
		integer _result;
		$display("[%0t][INFO] remap_id_0 is set : %000000b", $time, _dev_id);
		top.apb4m_vip.task_apb_write(_result, `ADDR_DEVICE_ID_0, _dev_id);
	end
	endtask

	task task_sfr_data_size_set(
		input	integer		_size
	);
	begin
		integer _result;
		$display("[%0t][INFO] data_size sfr is set : %0h", $time, _size);
		top.apb4m_vip.task_apb_write(_result, `ADDR_DATA_SIZE, _size);
	end
	endtask

	task task_sfr_data_set(
		input	integer		_data
	);
	begin
		integer _result;
		$display("[%0t][INFO] data sfr is set : %0h", $time, _data);
		top.apb4m_vip.task_apb_write(_result, `ADDR_DATA, _data);
	end
	endtask

	task task_sfr_dma_start_addr_set(
		input	integer		_addr
	);
	begin
		integer _result;
		$display("[%0t][INFO] sfr_dma_start_addr is set : %0h", $time, _addr);
		top.apb4m_vip.task_apb_write(_result, `ADDR_DMA_START_ADDR, _addr);
	end
	endtask

	task task_sfr_dma_end_addr_set(
		input	integer		_addr
	);
	begin
		integer _result;
		$display("[%0t][INFO] sfr_dma_end_addr is set : %0h", $time, _addr);
		top.apb4m_vip.task_apb_write(_result, `ADDR_DMA_END_ADDR, _addr);
	end
	endtask

    task  
endmodule
