module master(
        input	wire	clk			    ,
        input	wire	RSTn		    ,
        input   wire    master_en       ,

        output	wire	master_valid    ,
        input	wire	bus_ready	    ,

        output	reg[23:0] master_data
    );

    reg[2:0]cnt;
    assign master_valid = master_en;
    always @(posedge clk or negedge RSTn) begin
        if(!RSTn) begin
            cnt <= 3'b0;
        end
        else if(bus_ready && (cnt < 3'd5) && master_valid) begin
            cnt <= cnt +1'b1;
        end
        else if (bus_ready && (cnt == 3'd5) && master_valid) begin
            cnt <= 3'd0;
        end
        else begin
            cnt <= cnt;
        end
    end

    always @(*) begin
        case(cnt)
            3'd0: begin
                master_data <= 24'h001122;
            end
            3'd1: begin
                master_data <= 24'h112233;
            end
            3'd2: begin
                master_data <= 24'h223344;
            end
            3'd3: begin
                master_data <= 24'h334455;
            end
            3'd4: begin
                master_data <= 24'h445566;
            end
            3'd5: begin
                master_data <= 24'h556677;
            end
            default : begin
                master_data <= 24'hFFFFFF;
            end
        endcase
    end

endmodule
