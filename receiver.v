module receiver (
    input clk,
    input rstn,
    output reg ready,
    output reg [6:0] data_out,
    output reg parity_ok_n,
    input serial_in
);

    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg [1:0] state;

    localparam IDLE = 2'd0;
    localparam RECEIVE = 2'd1;
    localparam DONE = 2'd2;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state <= IDLE;
            bit_cnt <= 0;
            shift_reg <= 0;
            data_out <= 0;
            ready <= 0;
            parity_ok_n <= 1;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 0;
                    if (serial_in == 0) begin
                        // start bit detectado
                        bit_cnt <= 0;
                        state <= RECEIVE;
                    end
                end

                RECEIVE: begin
                    shift_reg[bit_cnt] <= serial_in;
                    bit_cnt <= bit_cnt + 1;
                    if (bit_cnt == 7) begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    data_out <= shift_reg[6:0];
                    parity_ok_n <= (^shift_reg[6:0]) ^ shift_reg[7]; // 0 se paridade OK
                    ready <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
