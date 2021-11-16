
module axi4_s_vip;

	//include parameter for AXI4 slave VIP
	`include "axi4_s_defines.sv"
	
	//include AXI4 slave interface
	`include "axi4_s_intf.sv"
	
	//include AXI4 slave vip driver
	`include "axi4_s_driver.sv"

	//include AXI4 slave seqr
	`include "axi4_s_seqr.sv"
	
	//include AXI4 slave monitor	
	`include "axi4_s_monitor.sv"

endmodule
