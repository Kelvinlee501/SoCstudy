
module apb4m_vip;
	`include "lib/apb4m/vip_param.svh"

	wire pclk;
	wire presetn;

	reg [VIP_ADDR_WIDTH-1:0] paddr;
	reg	[2:0] pprot;

	reg	psel;
	reg penable;
	reg pwrite;

	reg [VIP_DATA_WIDTH-1:0] pwdata;
	reg [(VIP_DATA_WIDTH>>3)-1] pstrb;

	wire pready;
	wire [VIP_DATA_WIDTH-1:0] prdata;

	wire pslverr;

	integer timeout;
	integer timeout_cnt;

	integer pre_psel_delay;
	integer post_psel_delay;

	integer	auto_psel_control;
	
	initial begin
		pre_psel_delay = 3;
		post_psel_delay = 3;
		auto_psel_control = 1;
		paddr = 0;
		pprot = 0;

		psel = 0;
		penable = 0;
		pwrite = 0;

		pwdata = 0;
		pstrb = 0;

		timeout = 300;
		timeout_cnt = 0;
	end

	task task_apb_write (
		output	integer		_result,
		input	integer		_addr,
		input	integer		_data,
		input	[2:0]		_prot = 3'b010,
		input	[(VIP_DATA_WIDTH>>3)-1:0] _strb = {(VIP_DATA_WIDTH>>3){1'b1}}
	);
	begin
		if(!presetn) $display("[%0t][ERROR] PRESETn was not actvated. but request is accepted.", $time);
		_result = 0;
		@(posedge pclk);

		if(auto_psel_control == 1) psel <= 1;
		pwrite <= 1;
		paddr <= _addr;
		pwdata <= _data;
		pprot <= _prot;
		pstrb <= _strb;
		for(int i=0;i < pre_psel_delay;i=i+1) begin
			@(posedge pclk);
		end

		if (psel != 1) begin
			$display("[%0t][ERROR] PSEL was not actvated. but request is accepted.", $time);
			_result = 1;
			top.error_count = top.error_count + 1;
		end
		penable <= 1;
		@(posedge pclk);
	
		while(!pready) begin
			@(posedge pclk);
			timeout_cnt = timeout_cnt + 1;
			if(timeout_cnt == timeout) begin
				$display("[%0t][ERROR] Timout occurs for PREADY.", $time);
				top.error_count = top.error_count + 1;
				psel <= 0;
				penable <= 0;
				timeout_cnt = 0;
				_result = 2;
				`ifdef QuestaSim
					return;
				`endif
				`ifdef iverilog
					force pready = 1;
				`endif
			end
		end
		`ifdef iverilog
			release pready;
		`endif
		timeout_cnt = 0;
		if(auto_psel_control == 1) psel <= 0;
		penable <= 0;
		if(_result == 0 & pslverr == 1) _result = 1;

		for(int i=0;i < post_psel_delay;i=i+1) begin
			@(posedge pclk);
		end
	end
	endtask

	task task_apb_read (
		output	integer		_result,
		input	integer		_addr,
		output	integer		_data,
		input	[2:0]		_prot = 3'b010
	);
	begin
		if(!presetn) $display("[%0t][ERROR] PRESETn was not actvated. but request is accepted.", $time);
		_result = 0;
		@(posedge pclk);

		if(auto_psel_control == 1) psel <= 1;
		pwrite <= 0;
		paddr <= _addr;
		pprot <= _prot;
		pstrb <= {(VIP_DATA_WIDTH>>3){1'b1}};

		for(int i=0;i < pre_psel_delay;i=i+1) begin
			@(posedge pclk);
		end
		if (psel != 1) begin
			$display("[%0t][ERROR] PSEL was not actvated. but request is accepted.", $time);
			_result = 1;
			top.error_count = top.error_count + 1;
		end
		penable <= 1;
		@(posedge pclk);

		while(!pready) begin
			@(posedge pclk);
			timeout_cnt = timeout_cnt + 1;
			if(timeout_cnt == timeout) begin
				$display("[%0t][ERROR] Timout occurs for PREADY.", $time);
				top.error_count = top.error_count + 1;
				psel <= 0;
				penable <= 0;
				timeout_cnt = 0;
				_result = 2;
				`ifdef QuestaSim
					return;
				`endif
				`ifdef iverilog
					force pready = 1;
				`endif
			end
		end
		`ifdef iverilog
			release pready;
		`endif
		timeout_cnt = 0;
		if(auto_psel_control == 1) psel <= 0;
		penable <= 0;
		_data = prdata;
		if(_result == 0 & pslverr == 1) _result = 1;

		for(int i=0;i < post_psel_delay;i=i+1) begin
			@(posedge pclk);
		end
	end
	endtask

	task active_apb; psel <= 1; endtask

	task deactive_apb; psel <= 0; endtask

endmodule
