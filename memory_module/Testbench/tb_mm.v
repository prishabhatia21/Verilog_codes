module tb_mm;
  reg CLK,RSTN,PD,CEN,WEN;
  reg [11:0] ADDR;
  reg [7:0] Data;
  wire [7:0] Q_Out;
  
  mem_module dut (.CLK(CLK),.RSTN(RSTN),.PD(PD),.CEN(CEN),.WEN(WEN),.ADDR(ADDR),.Data(Data),.Q_Out(Q_Out));
 initial CLK = 0;
always #5 CLK = ~CLK;
  initial begin 
     RSTN=0; PD=0; CEN=1; WEN=1; ADDR=12'h000; Data=8'h00;#10;
    RSTN=1; #10;
     CEN=0; WEN=0; ADDR=12'h004; Data=8'hF0; #10;
    CEN=1; WEN=1; #10;
    CEN=0; WEN=1; ADDR=12'h004; #10;
    CEN=1; WEN=1; #20;
  end
 initial begin
  $dumpfile("dump1.vcd");
   $dumpvars(0, tb_mm);
  #60
    $finish;
  end  
endmodule
