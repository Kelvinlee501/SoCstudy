

module apb4m_monitor;
	`include "lib/apb4m/vip_param.svh"

	wire	pclk;
	wire	presetn;
	wire	[VIP_ADDR_WIDTH-1:0] paddr;
	wire	[2:0] pprot;
	wire	psel;
	wire	penable;
	wire	pwrite;
	wire	[VIP_DATA_WIDTH-1:0] pwdata;
	wire	[(VIP_DATA_WIDTH>>3)-1] pstrb;
	wire	pready;
	wire	[VIP_DATA_WIDTH-1:0] prdata;
	wire	pslverr;

	wire	sel_pclk;

	integer	monitor_disable;
	integer msg_on;
	integer slverr_validate;

	initial begin
		monitor_disable = 0;
		msg_on = 1;
		slverr_validate = 0;
	end

	assign sel_pclk = (monitor_disable == 1 ? 0 : pclk);

	always@(posedge sel_pclk) begin
		if(psel & penable & pready) begin
			if(slverr_validate != 1 & pslverr !== 0) begin
				if(pwrite) $display("[%0t][ERROR] Slave Error is occured during APB write, addr : 0x%0h, data : 0x%0h, pprot : 0x%h , pslverr : 0x%h", $time, paddr, pwdata, pprot, pslverr);
				else $display("[%0t][ERROR] Slave Error is occured during APB read, addr : 0x%0h, data : 0x%0h, pprot : 0x%h , pslverr : 0x%h", $time, paddr, pwdata, pprot, pslverr);
				top.error_count = top.error_count + 1;
			end
			else if(slverr_validate == 1 & pslverr !== 0) begin
				if(pwrite)
					if(msg_on == 1) $display("[%0t][INFO] Slave Error is occured during APB write, addr : 0x%0h, data : 0x%0h, pprot : 0x%h , pslverr : 0x%h", $time, paddr, pwdata, pprot, pslverr);
				else
					if(msg_on == 1) $display("[%0t][INFO] Slave Error is occured during APB read, addr : 0x%0h, data : 0x%0h, pprot : 0x%h , pslverr : 0x%h", $time, paddr, pwdata, pprot, pslverr);
			end
			else begin
				if(pwrite)
					if(msg_on == 1) $display("[%0t][INFO] APB write is successed, addr : 0x%0h, data : 0x%0h, pprot : 0x%h , pslverr : 0x%h", $time, paddr, pwdata, pprot, pslverr);
				else
					if(msg_on == 1) $display("[%0t][INFO] APB read is successed, addr : 0x%0h, data : 0x%0h, pprot : 0x%h , pslverr : 0x%h", $time, paddr, prdata, pprot, pslverr);
			end
		end

	end

	task task_apb4m_compare_read (
		input	integer		_data,
		input	integer		_expected_data
	);
	begin
		if(_data != _expected_data) begin
			$display("[%0t][ERROR] apb_read data is mismatehed. data : 0x%0h, expected : 0x%0h", $time, _data, _expected_data);
			top.error_count = top.error_count + 1;
		end
		else begin
			if(msg_on == 1) $display("[%0t][INFO] apb_read data is matched. data : 0x%0h", $time, _data);
		end
	end
	endtask

	task monitor_off; monitor_disable = 1; endtask
	task monitor_on; monitor_disable = 0; endtask
	task display_off; msg_on = 0; endtask
	task display_on; msg_on = 1; endtask

endmodule
