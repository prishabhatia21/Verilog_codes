module tb_mem_8KB;
  logic        CLK, RSTN, PD, CEN, WEN;
  logic [12:0] ADDR;
  logic [7:0]  Data;
  logic [7:0]  Q_Out;

  mem_8KB dut (
    .CLK(CLK), .RSTN(RSTN), .PD(PD), .CEN(CEN),
    .ADDR(ADDR), .WEN(WEN), .Data(Data), .Q_Out(Q_Out)
  );

  initial CLK = 0;
  always #5 CLK = ~CLK;

 task write_mem(input logic [12:0] addr, input logic [7:0] data);
    @(negedge CLK);
    WEN = 0; ADDR = addr; Data = data;
    @(posedge CLK); #1;
    WEN = 1;
    $display("[WRITE] CEN=%0b | ADDR=0x%0h | Data=0x%0h | Time=%0t", CEN, addr, data, $time);
endtask


task read_mem(input logic [12:0] addr, input logic [7:0] expected);
    @(negedge CLK);
    WEN = 1; ADDR = addr;
    @(posedge CLK); #1;
    WEN = 1;
    if (Q_Out === expected)
      $display("[READ]  ADDR=0x%0h | Q_Out=0x%0h | CEN=%0b | PASS | Time=%0t", addr, Q_Out, CEN, $time);
    else
      $display("[READ]  ADDR=0x%0h | Q_Out=0x%0h | EXPECTED=0x%0h | CEN=%0b | FAIL | Time=%0t", addr, Q_Out, expected, CEN, $time);
endtask


  initial begin
    $dumpfile("tb_mem_8KB.vcd");
    $dumpvars(0, tb_mem_8KB);
  end

  initial begin
    RSTN = 0; PD = 0; CEN = 1; WEN = 1; ADDR = 0; Data = 0;
    #20;
    RSTN = 1; #10;

   $display("\n===== TEST 1: Basic Write/Read =====");
CEN = 0;
write_mem(13'h000, 8'hA1);
write_mem(13'h001, 8'hB2);
write_mem(13'h002, 8'hC3);
write_mem(13'h003, 8'hD4);
read_mem(13'h000, 8'hA1);
read_mem(13'h001, 8'hB2);
read_mem(13'h002, 8'hC3);
read_mem(13'h003, 8'hD4);

$display("\n===== TEST 2: Overwrite =====");
CEN = 0;
write_mem(13'h000, 8'h55);
read_mem(13'h000, 8'h55);

$display("\n===== TEST 3: Write Blocked When CEN Disabled =====");
CEN = 0;
write_mem(13'h004, 8'h77);   
CEN = 1;
write_mem(13'h004, 8'hFF);  
CEN = 0;
read_mem(13'h004, 8'h77);    

$display("\n===== TEST 4: Read Blocked When CEN Disabled =====");
CEN = 0;
write_mem(13'h005, 8'h99);   
CEN = 1;
read_mem(13'h005, 8'h99);    
CEN = 0;

  
    #20;
    $display("\n===== ALL TESTS DONE =====\n");
    $finish;
  end
endmodule
