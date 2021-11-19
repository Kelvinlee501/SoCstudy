`timescale 1ns/100ps

module test_slave_normal;

    integer lacal_error_cnt;
    integer doen;

	task_apb apb_model();
	task_i2c i2c_model();

    initial begin
        local_error_cnt = 0;
        done = 0;
    end

    task TEST_SLAVE_NORMAL; 
		apb_model.apb4m_config;

        TASK_CONFIG_SLAVE_MODE;
        TASK_ONE_BYTE_TRANSACTION_SLAVE(8'hab);
    endtask

    task TASK_CONFIG_SLAVE_MODE;
       $display("[INFO] Set I2C slave mode "); 

       //set sfr with apb4 interface to change slave mode of i2c.
       //'Julian' will describe this task more detail.
       //default setting is i2c master in sfr
       task_sfr_config(`SLAVE_MODE_ADDR,32'h0000_0001);
       //I2C speed mode selection
       // 0 : legacy speed mode
       // 1 : fast speed mode
       // 2 : high speed mode
       task_sft_config(`DATA_RATE_CONF_ADDR,32'h0000_0000);

       //AXI mode selection
       //!!!!!this mode need to be dicussed for designing I2C IP.
       // 0 : APB
       // 1 : AXI
       task_sft_config(`AXI_MODE_SEL_ADDR,32'h0000_0000);

       // Config i2c vip mode to master mode
       // I2C IF DV owner 'William' will describe this task below.
       task_i2c_vip_config(`MASTER_MODE);
    endtask

    task TASK_ONE_BYTE_TRANSACTION_SLAVE;
       input [7:0] w_data;
        
       reg [31:0] data;
       $display("[INFO] Single transaction start for testing slave mode "); 

       // I2C vip master write single write transaction.
       // 'William' will describe this task below.
       task_i2c_vip_m_one_byte_write(`DEVICE_ADDR,w_data);
        
       //It will be wrapped in task_apb.sv 
       top.apb4m_vip.task_apb_read(_result,`RX_DATA_ADDR,data);

       //temporarily compare point
       if(data[7:0] == w_data) begin
            $display("TEST PASSED");
       else begin
            $display("TEST FAILED");
       end

    endtask

    task task_sfr_config;
        input p_sfr_addr;
        input data;

        integer _result;

        top.apb4m_vip.task_apb_write(_result,p_sfr_addr,data);
        //In my opinion, need to check SCL,SDA is high... 
    endtask

    task task_i2c_vip_config;
        input i2c_ms_mode;
    endtask
endmodule
