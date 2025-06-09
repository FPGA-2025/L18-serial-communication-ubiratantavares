module transmitter (
    input wire clk,
    input wire rstn,
    input wire start,
    input wire [6:0] data_in,
    output reg serial_out
);

    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg sending;

    function parity_even;
        input [6:0] data;
        integer i;
        begin
            parity_even = 0;
            for (i = 0; i < 7; i = i + 1)
                parity_even = parity_even ^ data[i];
        end
    endfunction

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            serial_out <= 1'b1;   // idle
            bit_cnt <= 0;
            sending <= 0;
            shift_reg <= 0;
        end else begin
            if (!sending) begin
                if (start) begin
                    // monta o pacote: 7 bits + paridade
                    shift_reg <= {parity_even(data_in), data_in};  // MSB = paridade
                    bit_cnt <= 0;
                    sending <= 1;
                    serial_out <= 1'b0; // start bit
                end else begin
                    serial_out <= 1'b1;
                end
            end else begin
                bit_cnt <= bit_cnt + 1;
                if (bit_cnt < 8) begin
                    serial_out <= shift_reg[0];  // envia LSB primeiro
                    shift_reg <= shift_reg >> 1;
                end else begin
                    serial_out <= 1'b1; // fim da transmissão (idle)
                    sending <= 0;
                end
            end
        end
    end
endmodule
