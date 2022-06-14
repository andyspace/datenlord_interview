module bus(
        input	wire	clk			,
        input	wire	RSTn		,

        input	wire[23:0]TOP_DATA	,
        input	wire	top_valid	,
        output	wire	bus_ready	,

        input	wire	spi_ready   ,
        output	wire	bus_valid   ,
        output	wire[23:0] BUS_DATA
    );
    reg  [23:0] DATA_BUFFER;
    reg data_status;

    //detect spi_ready_negedge
    reg spi_ready_q1;
    reg spi_ready_q0;

    always @ (posedge clk or negedge RSTn) begin
        if (!RSTn) begin
            spi_ready_q1 <= 1'b0;
            spi_ready_q0 <= 1'b0;
        end
        else begin
            spi_ready_q0 <= spi_ready;
            spi_ready_q1 <= spi_ready_q0;
        end
    end

    wire    spi_ready_negedge;
    assign spi_ready_negedge = spi_ready_q1 && !spi_ready_q0;

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
                    data_status <= spi_ready_negedge ? (top_valid ? 1'b1 : 1'b0) : data_status;
                end
                default : begin
                    data_status <= data_status;
                end
            endcase
        end
    end

    //bus ready
    assign bus_ready = (!data_status) || spi_ready_negedge;

    //tx valid
    assign bus_valid = data_status;

    //BUS_DATA
    assign BUS_DATA = bus_valid ? DATA_BUFFER : 24'd0;


endmodule









