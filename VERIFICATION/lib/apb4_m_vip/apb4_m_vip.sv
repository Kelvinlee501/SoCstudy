
module apb4_m_vip;

	//include parameter for APB4 master VIP
	`include "apb4_m_defines.sv"
	
	//include APB4 master interface
	`include "apb4_m_intf.sv"
	
	//include APB4 master vip driver
	`include "apb4_m_driver.sv"

	//include APB4 master seqr
	`include "apb4_m_seqr.sv"
	
	//include APB4 master monitor	
	`include "apb4_m_monitor.sv"

endmodule
