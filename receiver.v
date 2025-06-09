module receiver (
    input wire clk,
    input wire rstn,
    input wire serial_in,
    output reg ready,
    output reg [6:0] data_out,
    output reg parity_ok_n
);

    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg [1:0] state;

    localparam IDLE = 2'd0,
               START = 2'd1,
               RECEIVE = 2'd2;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            bit_cnt <= 0;
            shift_reg <= 0;
            state <= IDLE;
            ready <= 0;
            data_out <= 0;
            parity_ok_n <= 1;
        end else begin
            ready <= 0; // só ativa por um ciclo
            case (state)
                IDLE: begin
                    if (serial_in == 0) begin
                        state <= START;
                    end
                end

                START: begin
                    // espera 1 ciclo para sair do start bit
                    bit_cnt <= 0;
                    state <= RECEIVE;
                end

                RECEIVE: begin
                    shift_reg <= {serial_in, shift_reg[7:1]};
                    bit_cnt <= bit_cnt + 1;

                    if (bit_cnt == 7) begin
                        // shift_reg agora contém [6:0] = data, [7] = paridade
                        data_out <= shift_reg[6:0];
                        parity_ok_n <= ^shift_reg;  // paridade par
                        ready <= 1;
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
