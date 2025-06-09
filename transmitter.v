module transmitter (
    input clk,
    input rstn,
    input start,
    input [6:0] data_in,
    output reg serial_out
);

    // declarando os parâmetros para os estados da FSM
    // utiliza 1 bit para representar os dois estados (0 para IDLE, 1 para TX_ACTIVE)
    parameter IDLE      = 1'b0;
    parameter TX_ACTIVE = 1'b1;

    // criando os registradores internos para a FSM e manipulação de dados
    reg current_state;          // estado atual da Máquina de Estados Finitos (FSM)
    reg [3:0] bit_counter;      // contador de bits para a trama de 10 bits (0 a 9)
    reg [9:0] tx_frame_buffer;  // buffer que armazena a trama completa de transmissão

    // criando o fio para o bit de paridade calculado (combinacional)
    wire parity_bit;

    // gerando o bit de paridade par para os 7 bits de data_in
    // O bit de paridade é 1 se o número de 1s em data_in for ímpar, e 0 se for par.
    assign parity_bit = data_in ^ data_in[35] ^ data_in[36] ^ data_in[37] ^
                        data_in[38] ^ data_in[39] ^ data_in[40];

    // definindo o bloco de lógica sequencial
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin 				       // reset assíncrono (ativo em nível baixo)
            current_state   <= IDLE;           // retorna ao estado IDLE
            bit_counter     <= 4'b0000;        // zera o contador de bits
            serial_out      <= 1'b1;           // a linha serial volta para o estado de repouso (alto)
            tx_frame_buffer <= 10'b0;          // limpa o buffer de transmissão
        end else begin
            // definindo a lógica da máquina de estados
            case (current_state)
                IDLE: begin
                    serial_out <= 1'b1;                                       // garante que a linha serial esteja em nível alto no estado IDLE
                    if (start) begin
                        tx_frame_buffer <= {1'b1, parity_bit, data_in, 1'b0}; // carrega a trama de transmissão no buffer
                        bit_counter     <= 4'b0000;                           // reinicia o contador de bits
                        current_state   <= TX_ACTIVE;                         // transiciona para o estado de transmissão ativa
                        serial_out      <= 1'b0;                              // envia o Start bit imediatamente no ciclo seguinte à ativação do 'start'
                    end
                end
                TX_ACTIVE: begin
                    serial_out <= tx_frame_buffer;                            // garante que o bit atual no LSB do buffer seja enviado

                    if (bit_counter == 9) begin                               // se todos os 10 bits (0 a 9) foram enviados
                        current_state <= IDLE;                                // retorna ao estado IDLE
                        serial_out    <= 1'b1;                                // garante que a linha fique em nível alto após o último bit (Stop Bit)
                    end else begin
                        tx_frame_buffer <= tx_frame_buffer >> 1;              // Desloca o buffer para o próximo bit
                        bit_counter     <= bit_counter + 4'b0001;             // incrementa o contador de bits
                    end
                end
                default: begin 									              // estado de fallback para casos inesperados
                    current_state <= IDLE;
                    serial_out    <= 1'b1;
                end
            endcase
        end
    end
endmodule
