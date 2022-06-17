`timescale 1ns/100ps
`include "../src/master.v"
`include "../src/bus.v"
`include "../src/slave.v"
module sim_tb();
    reg clk_50;
    reg RSTn;
    reg slave_en;
    reg master_en;

    wire [23:0]bus_data;
    wire bus_valid;
    wire bus_ready;

    wire [23:0]master_data;
    wire master_valid;
    wire slave_ready;

    master u_master(
               .clk	        	    (clk_50         ),
               .RSTn	            (RSTn           ),
               .master_en           (dut_master_en  ),
               .master_valid        (master_valid   ),
               .bus_ready	        (bus_ready      ),
               .master_data         (master_data    )
           );

    bus u_bus(
            //ports
            .clk          		( clk_50          	),
            .RSTn         		( RSTn         		),
            .master_data  		( master_data  	    ),
            .master_valid 		( master_valid 	    ),
            .bus_ready    		( bus_ready    		),
            .slave_ready  		( slave_ready  	    ),
            .bus_valid    		( bus_valid    		),
            .bus_data     		( bus_data     		)
        );
    slave u_slave(
              .clk              (clk_50             ),
              .RSTn             (RSTn               ),
              .receive_en       (dut_slave_en       ),
              .bus_valid        (bus_valid          ),
              .bus_data         (bus_data           ),
              .slave_ready      (slave_ready        )
          );

    assign #0.1 dut_master_en = master_en;
    assign #0.1 dut_slave_en = slave_en;


    always #10 clk_50 = ~clk_50;

    initial begin
        clk_50 = 1;
        RSTn = 0;
        slave_en = 0;
        master_en = 0;
        #20 RSTn = 1;
        #20 slave_en = 1;
        master_en = 1;
        #20 slave_en = 1;
        #20 slave_en = 0;
        master_en = 0;
        #20 slave_en = 0;
        #20 slave_en = 1;
        #20 slave_en = 0;
        master_en = 1;
        #20 slave_en = 1;
        #20 slave_en = 0;
        #20 slave_en = 1;
        #20 slave_en = 1;
        #20 slave_en = 0;

        #80 $finish;
    end

    initial begin
        $dumpfile("./sim_result/wave.vcd");
        $dumpvars(0, sim_tb);
    end


endmodule
