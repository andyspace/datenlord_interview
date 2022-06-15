`timescale 1ns/100ps
`include "../src/bus.v"
module sim_tb();
    reg clk_50;
    reg RSTn;

    reg 	bus_ready;
    reg 	bus_valid;
    reg [23:0]	bus_data;

    reg 	slave_ready;
    reg 	master_valid;
    reg [23:0] master_data;

    bus u_bus(
            //ports
            .clk          		( clk_50          	),
            .RSTn         		( RSTn         		),
            .master_data  		( dut_master_data  	),
            .master_valid 		( dut_master_valid 	),
            .bus_ready    		( bus_ready    		),
            .slave_ready  		( dut_slave_ready  	),
            .bus_valid    		( bus_valid    		),
            .bus_data     		( bus_data     		)
        );

    wire [23:0]dut_bus_data;
    wire dut_bus_valid;
    wire dut_bus_ready;

    wire [23:0]dut_master_data;
    wire dut_master_valid;
    wire dut_slave_ready;

    assign #0.1 dut_bus_valid = bus_valid;
    assign #0.1 dut_bus_data = bus_data;
    assign #0.1 dut_bus_ready = bus_ready;

    assign #0.1 dut_master_valid = master_valid;
    assign #0.1 dut_master_data = master_data;
    assign #0.1 dut_slave_ready = slave_ready; 


    always #10 clk_50 = ~clk_50;

    initial begin
        clk_50 = 1;
        RSTn = 0;
        master_valid = 1'b0;
        master_data = 24'b0;
        slave_ready = 1'b0;
 
        #20 RSTn = 1;
        master_data = 24'hFFF000;
        master_valid = 1'b1;        
        slave_ready = 1'b1;
        #20  master_data = 24'h000FFF;
        #20  master_data = 24'h555555;
        #20  slave_ready = 1'b0;
        master_data = 24'h777777;
        #20  slave_ready = 1'b1;
        master_valid = 0;
        master_data = 24'h0;
        #20  slave_ready = 1'b0;
        #40
        slave_ready = 1;
        #20
        master_data = 24'h111111;
        master_valid = 1'b1; 
        #20
        master_data = 24'h222222;
        #20
        master_data = 24'h333333;
        master_valid = 0;
        #20 master_data = 24'h444444;
        #20 master_valid = 1; 
        master_data = 24'h112233;
        #20  master_data = 24'h223344;
        #20  slave_ready = 1'b0;
        master_data = 24'h445566;
        #20  slave_ready = 1'b1;
        master_valid = 0;
        master_data = 24'h667788;
        #20  slave_ready = 1'b0;

        
        #50000 $finish;
    end

    initial begin
        $dumpfile("./sim_result/wave.vcd");
        $dumpvars(0, sim_tb);
    end


endmodule
