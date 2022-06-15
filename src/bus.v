module bus(
        input	wire	clk			    ,
        input	wire	RSTn		    ,

        input	wire[23:0]master_data   ,
        input	wire	master_valid    ,
        output	wire	bus_ready	    ,

        input	wire	slave_ready     ,
        output	wire	bus_valid       ,
        output	wire[23:0] bus_data
    );

    reg  [23:0] DATA_BUFFER;
    reg buffer_full;
    reg slave_ready_d1;

    always @(posedge clk or negedge RSTn) begin
        if (!RSTn) begin
            slave_ready_d1 <= 1'd0;
        end
        else begin
            slave_ready_d1 <= slave_ready;
        end
    end

    //bus buffer refresh
    always @ (posedge clk or negedge RSTn) begin
        if (!RSTn) begin
            DATA_BUFFER <= 24'd0;
        end
        else if (master_valid && bus_ready && (!slave_ready) && (!buffer_full)) begin
            DATA_BUFFER <= master_data;
        end
        else begin
            DATA_BUFFER <= DATA_BUFFER;
        end
    end

    //bus buffer status
    always @(posedge clk or negedge RSTn) begin
        if (!RSTn)
            buffer_full <= 1'd0;
        else if (master_valid && (!slave_ready) && (!buffer_full))
            buffer_full <= 1'd1;
        else if (slave_ready == 1'd1)
            buffer_full <= 1'd0;
    end

    //bus ready
    assign bus_ready = (!buffer_full) || slave_ready_d1;

    //tx valid
    assign bus_valid = buffer_full || master_valid;

    //BUS_DATA
    assign bus_data = buffer_full ? DATA_BUFFER : master_data;


endmodule
