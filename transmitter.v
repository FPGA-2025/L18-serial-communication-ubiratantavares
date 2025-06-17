module transmitter (
    input clk,
    input rstn,
    input start,
    input [6:0] data_in,
    output reg serial_out
);

    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg busy;
    reg parity;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            bit_cnt <= 0;
            busy <= 0;
            serial_out <= 1'b1; // linha inativa
        end else begin
            if (start && !busy) begin
                // Calcular paridade par
                parity <= ^data_in; // XOR de todos os bits
                shift_reg <= {(^data_in), data_in}; // 8 bits: paridade + dados
                bit_cnt <= 0;
                busy <= 1;
                serial_out <= 1'b0; // start bit
            end else if (busy) begin
                bit_cnt <= bit_cnt + 1;

                if (bit_cnt < 8)
                    serial_out <= shift_reg[bit_cnt];
                else begin
                    serial_out <= 1'b1; // linha ociosa após envio
                    busy <= 0;
                end
            end
        end
    end

endmodule
