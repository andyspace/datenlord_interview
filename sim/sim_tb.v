`timescale 1ns/100ps
`include "top.v"

module sim_tb();
    reg clk_50;
    reg RSTn;
    reg top_valid;



    wire 	spi_cs;
    wire 	spi_clk;
    wire 	spi_data;

    top u_top(
            //ports
            .clk       		( clk_50       		),
            .RSTn      		( RSTn      		),
            .top_valid 		( top_valid 		),
            .spi_cs    		( spi_cs    		),
            .spi_clk   		( spi_clk   		),
            .spi_data  		( spi_data  		)
        );


    always #10 clk_50 = ~clk_50;

    initial begin
        clk_50 = 1;
        RSTn = 0;
        #20 RSTn <= 1;
        top_valid = 0;

        #120 top_valid <= 1;
        #50000 $finish;
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, sim_tb);
    end


endmodule
