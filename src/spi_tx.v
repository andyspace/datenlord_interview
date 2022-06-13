//SPI data mode:00 ,speed:(50/24)MHz
//SCK keep 0 if idle; MOSI will be sampling in the rising edge of SCK
//note that, CS will keep high if no data need trans.
module spi_tx(
        input	wire	clk			,
        input	wire	RSTn		,

        input	wire[23:0]BUS_DATA	,
        input	wire	tx_valid	,
        output	wire	spi_ready	,

        output	wire	spi_cs		,
        output	reg		spi_clk		,
        output	wire	spi_data
    );
    localparam ST_IDLE = 2'b00;
    localparam ST_W    = 2'b01;
    localparam ST_WAIT = 2'b10;

    reg [1:0]cur_sta;
    reg [1:0]nxt_sta;
    reg [4:0]sclk_cnt;
    reg [4:0]data_cnt;
    reg [23:0]DATA_BUFFER;

    //bus handshake
    assign spi_ready = (cur_sta == ST_IDLE);

    //buffer refresh
    always @ (posedge clk or negedge RSTn) begin
        if(!RSTn) begin
            DATA_BUFFER <= 24'd0;
        end
        else if(spi_ready && tx_valid) begin
            DATA_BUFFER <= BUS_DATA;
        end
        else begin
            DATA_BUFFER <= DATA_BUFFER;
        end
    end

    //spi
    assign spi_cs = ~(cur_sta == ST_W);
    assign spi_data = ((cur_sta == ST_W) && (data_cnt <= 5'd23)) ? DATA_BUFFER[5'd23-data_cnt] : 1'b0;

    always @ (posedge clk or negedge RSTn) begin
        if(!RSTn) begin
            spi_clk <= 1'b0;
        end
        else if(cur_sta == ST_W) begin
            if(sclk_cnt == 5'd11) begin
                spi_clk <= 1'b1;
            end
            else if(sclk_cnt == 5'd23) begin
                spi_clk <= 1'b0;
            end
            else begin
                spi_clk <= spi_clk;
            end
        end
        else begin
            spi_clk <= 1'b0;
        end
    end

    //cnt
    always @ (posedge clk or negedge RSTn) begin
        if(!RSTn) begin
            sclk_cnt <= 5'd0;
        end
        else if(cur_sta == ST_W) begin
            sclk_cnt <=  (sclk_cnt == 5'd23) ? 5'd0 : sclk_cnt + 1'b1 ;
        end
        else if(cur_sta == ST_WAIT) begin
            sclk_cnt <=  sclk_cnt + 1'b1 ;
        end
        else begin
            sclk_cnt <= 5'd0;
        end
    end

    always @ (posedge clk or negedge RSTn) begin
        if(!RSTn) begin
            data_cnt <= 5'd0;
        end
        else if(cur_sta == ST_W) begin
            data_cnt <=  (sclk_cnt == 5'd23) ? data_cnt + 1'b1 : data_cnt ;
        end
        else begin
            data_cnt <= 5'd0;
        end
    end



    //FSM
    always @ (posedge clk or negedge RSTn) begin
        if(!RSTn) begin
            cur_sta <= ST_IDLE;
        end
        else begin
            cur_sta <= nxt_sta;
        end
    end

    always @ (*) begin
        case(cur_sta)
            ST_IDLE : begin
                nxt_sta = tx_valid ? ST_W :ST_IDLE;
            end
            ST_W    : begin
                nxt_sta =(data_cnt == 5'd24 && sclk_cnt == 5'd10) ? ST_WAIT :ST_W;
            end
            ST_WAIT : begin
                nxt_sta =(sclk_cnt == 5'd30) ? ST_IDLE : ST_WAIT ;
            end
            default : begin
                nxt_sta = ST_IDLE;
            end
        endcase
    end


endmodule




