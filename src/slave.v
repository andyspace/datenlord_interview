module slave (
    input   wire    clk,
    input   wire    RSTn,
    input   wire    receive_en,
    input   wire    bus_valid,    
    input   wire[23:0] bus_data,
    output  wire    slave_ready    
);
    assign slave_ready = receive_en;
    reg [23:0]slave_buffer;
    always @(*) begin
        if(slave_ready && bus_valid)begin
            slave_buffer <= bus_data;
        end 
        else begin
            slave_buffer <= slave_buffer;
        end       
    end
    
endmodule //moduleName
