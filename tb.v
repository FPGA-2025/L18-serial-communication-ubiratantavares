module tb();

reg [6:0] file_data [0:0];

reg clk = 0;
reg rstn;
reg start;
reg [6:0] data_in;
wire serial_out;

transmitter t(
    .clk(clk),
    .rstn(rstn),
    .start(start),
    .data_in(data_in),
    .serial_out(serial_out)
);

wire ready;
wire [6:0] data_out;
wire parity_ok_n;

receiver r(
    .clk(clk),
    .rstn(rstn),
    .ready(ready),
    .data_out(data_out),
    .parity_ok_n(parity_ok_n),
    .serial_in(serial_out)
);
   

always #1 clk = ~clk;

initial begin
    $dumpfile("saida.vcd");
    $dumpvars(0, tb);
    $readmemb("teste.txt", file_data);
    rstn = 0;
    start = 0;
    #2;
    rstn = 1;
    #2;

    start = 1;
    data_in = file_data[0];
    $display("data_in=%h", data_in);
    #2;

    start = 0;
    #20;
    $display("data_out=%h, parity_ok_n=%b, ready=%b", data_out, parity_ok_n, ready);
    $finish;
end

endmodule
