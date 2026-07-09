 module uart_tb;
  reg clk, rst, tx_start;
  reg [7:0] tx_data;
  wire [7:0] rx_data;
  wire rx_done; 
  
  uart_top dut (.clk (clk),
    .rst (rst),
    .tx_start(tx_start),
    .tx_data (tx_data),
    .rx_data (rx_data),
    .rx_done (rx_done)
);
   
 always #10 clk = ~clk;
   initial begin
     
  $dumpfile("dump1.vcd");
  $dumpvars(0, uart_tb);
    clk      = 0;
    rst      = 1;
    tx_start = 0;
    tx_data  = 0;
   
    #100;
    rst = 0;
    #100;
    tx_data  = 8'h47;
    tx_start = 1;
    #20;
    tx_start = 0;
    @(posedge rx_done);
    if (rx_data == 8'h47)
        $display("PASS: received %h", rx_data);
    else
        $display("FAIL: expected 47, got %h", rx_data);
    
    $finish;
end

   
    
endmodule
