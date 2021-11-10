
	initial begin
		warning_count = 0;
		error_count = 0;
	end

	// !!! NEED TO CONNECT TO REAL DESIGN !!!
	assign apb4m_monitor.pclk = apb4m_vip.pclk;
	assign apb4m_monitor.presetn = apb4m_vip.presetn;
	assign apb4m_monitor.paddr = apb4m_vip.paddr;
	assign apb4m_monitor.pprot = apb4m_vip.pprot;
	assign apb4m_monitor.psel = apb4m_vip.psel;
	assign apb4m_monitor.penable = apb4m_vip.penable;
	assign apb4m_monitor.pwrite = apb4m_vip.pwrite;
	assign apb4m_monitor.pwdata = apb4m_vip.pwdata;
	assign apb4m_monitor.pstrb = apb4m_vip.pstrb;
	assign apb4m_monitor.pready = apb4m_vip.pready;
	assign apb4m_monitor.prdata = apb4m_vip.prdata;
	assign apb4m_monitor.pslverr = apb4m_vip.pslverr;
	

