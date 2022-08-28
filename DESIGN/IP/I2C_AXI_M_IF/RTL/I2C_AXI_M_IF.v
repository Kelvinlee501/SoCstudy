////////////////////////////////////
//
//
//
////////////////////////////////////

module I2C_AXI_M_IF #(
	parameter			PARAM = 1	
) (
	input					    ACLK,
	input						ARESETn,

    //AW-Channel
    output reg                  AWID,
    output reg                  AWADDR,
    output reg                  AWLEN,
    output reg                  AWSIZE,
    output reg                  AWBURST,
    output reg                  AWLOCK,
    output reg                  AWCACHE,
    output reg                  AWPROT,
    output reg                  AWQOS,
    output reg                  AWREGION,
    output reg                  AWUSER,
    output reg                  AWVALID,
    input                       AWREADY,

    //W-channel
    output reg                  WID,
    output reg                  WDATA,
    output reg                  WSTRB,
    output reg                  WLAST,
    output reg                  WUSER,
    output reg                  WVALID,
    input                       WREADY,

    //B-channel
    
);

endmodule
