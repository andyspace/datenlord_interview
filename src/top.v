module top(
        input	wire	clk			,
        input	wire	RSTn		,
        input   wire    top_valid   ,

        output	wire	spi_cs		,
        output	reg		spi_clk		,
        output	wire	spi_data
    );


    wire	bus_ready;

    reg [23:0] data_0;
    reg [23:0] data_1;
    reg [23:0] data_2;
    reg [23:0] data_3;

    always @ (posedge clk or negedge RSTn) begin
        if (!RSTn) begin
            data_0 <= 24'h28bb85;
            data_1 <= 24'h000fff;
            data_2 <= 24'h555555;
            data_3 <= 24'h123456;
        end
        else if (top_valid && bus_ready)  begin
            data_0 <= data_1;
            data_1 <= data_2;
            data_2 <= data_3;
            data_3 <= data_0;
        end
        else begin
            data_0 <= data_0;
            data_1 <= data_1;
            data_2 <= data_2;
            data_3 <= data_3;
        end
    end


    wire 	tx_valid;

    bus u_bus(
            //ports
            .clk       		( clk       		),
            .RSTn      		( RSTn      		),
            .TOP_DATA  		( data_0  	    	),
            .top_valid 		( top_valid 		),
            .bus_ready 		( bus_ready 		),
            .spi_ready 		( spi_ready 		),
            .tx_valid  		( tx_valid  		),
            .BUS_DATA  		( BUS_DATA  	    	)
        );

    wire 	spi_ready;
    wire [23:0] BUS_DATA;

    spi_tx u_spi_tx(
               //ports
               .clk       		( clk       		),
               .RSTn      		( RSTn      		),
               .BUS_DATA  		( BUS_DATA  		),
               .tx_valid  		( tx_valid  		),
               .spi_ready 		( spi_ready 		),
               .spi_cs    		( spi_cs    		),
               .spi_clk   		( spi_clk   		),
               .spi_data  		( spi_data  		)
           );


endmodule
