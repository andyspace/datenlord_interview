module bus(
        input	wire	clk			,
        input	wire	RSTn		,

        input	wire[23:0]TOP_DATA	,
        input	wire	top_valid	,
        output	wire	bus_ready	,

        input	wire	spi_ready,
        output	wire	tx_valid,
        output	wire[23:0] BUS_DATA
    );
    reg  [23:0] DATA_BUFFER;
    reg data_status;

    //bus buffer refresh
    always @ (posedge clk or negedge RSTn) begin
        if (!RSTn) begin
            DATA_BUFFER <= 24'd0;
        end
        else if (top_valid && bus_ready)  begin
            DATA_BUFFER <= TOP_DATA;
        end
        else begin
            DATA_BUFFER <= DATA_BUFFER;
        end
    end

    //bus buffer status
    always @ (posedge clk or negedge RSTn) begin
        if(!RSTn) begin
            data_status <= 1'b0;
        end
        else begin
            case(data_status)
                1'b0 : begin
                    data_status <= top_valid ? 1'b1 :1'b0;
                end
                1'b1 : begin
                    data_status <= spi_ready ? (top_valid ? 1'b1 : 1'b0) : data_status;
                end
                default : begin
                    data_status <= data_status;
                end
            endcase
        end
    end

    //bus ready
    assign bus_ready = (!data_status) || spi_ready;

    //tx valid
    assign tx_valid = data_status;

    //BUS_DATA
    assign BUS_DATA = tx_valid ? DATA_BUFFER : 24'd0;


endmodule









