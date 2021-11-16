
wire pclk;
wire presetn;

reg [VIP_ADDR_WIDTH-1:0] paddr;
reg [2:0] pprot;

reg psel;
reg penable;
reg pwrite;

reg [VIP_DATA_WIDTH-1:0] pwdata;
reg [(VIP_DATA_WIDTH>>3)-1] pstrb;

wire pready;
wire [VIP_DATA_WIDTH-1:0] prdata;

wire pslverr;
