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
    endtask

    task TASK_CONFIG_SLAVE_MODE;
       $display("[INFO] Set I2C slave mode "); 

       //set sfr with apb4 interface to change slave mode of i2c.
       //default setting is i2c master in sfr
       task_sfr_config(`SLAVE_MODE_ADDR,32'h0000_0001);

       // Config i2c vip mode to master mode
       // I2C IF DV owner 'William' will describe this task below.
       task_i2c_vip_config(`MASTER_MODE);
    endtask

    task TASK_SINGLE_TRANSACTION_SLAVE;
       $display("[INFO] Single transaction start for testing slave mode "); 

       task_i2c_vip_write(`DEVICE_ADDR,8'b1010_1010);
    endtask

    task task_sfr_config;
        input p_sfr_addr;
        input data;

        integer _result;

        top.apb4m_vip.task_apb_write(_result,p_sfr_addr,data);
        //Need to check SCL,SDA is high... 
    endtask

    task task_i2c_vip_config;
        input mode;
    endtask
endmodule
