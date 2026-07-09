module tb_mm2;
  reg CLK, RSTN, PD, CEN, WEN;
  reg [11:0] ADDR;
  reg [7:0]  Data;
  wire [7:0] Q_Out;

   mem_para #(.ADDR_WIDTH(12), .DATA_WIDTH(8)) dut (
    .CLK(CLK), .RSTN(RSTN), .PD(PD),
    .CEN(CEN), .WEN(WEN), .ADDR(ADDR),
    .Data(Data), .Q_Out(Q_Out)
  );

  initial CLK = 0;
  always #5 CLK = ~CLK;

  integer f;

  initial begin
    RSTN=0; PD=0; CEN=1; WEN=1; ADDR=12'h000; Data=8'h00; #10;
    RSTN=1; #10;

    f = $fopen("mem_init.hex", "w");
    $fwrite(f, "F0\nA3\n00\nFF\n12\n34\nAB\nCD\n");
    $fclose(f);

    $readmemh("mem_init.hex", dut.mem);
    $display("Memory loaded via $readmemh");

    CEN=0; WEN=1;
    ADDR=12'h000; #10; $display("Read addr 0: Q_Out = %h (expect F0)", Q_Out);
    ADDR=12'h001; #10; $display("Read addr 1: Q_Out = %h (expect A3)", Q_Out);
    ADDR=12'h002; #10; $display("Read addr 2: Q_Out = %h (expect 00)", Q_Out);
    ADDR=12'h003; #10; $display("Read addr 3: Q_Out = %h (expect FF)", Q_Out);
    ADDR=12'h004; #10; $display("Read addr 4: Q_Out = %h (expect 12)", Q_Out);
    ADDR=12'h005; #10; $display("Read addr 5: Q_Out = %h (expect 34)", Q_Out);
    ADDR=12'h006; #10; $display("Read addr 6: Q_Out = %h (expect AB)", Q_Out);
    ADDR=12'h007; #10; $display("Read addr 7: Q_Out = %h (expect CD)", Q_Out);
    CEN=1; #10;

    CEN=0; WEN=0; ADDR=12'h010; Data=8'hBE; #10;
    CEN=1; #20;

    $writememh("mem_dump.hex", dut.mem);
    $display("Memory dumped via $writememh");

    $system("grep -v xx mem_dump.hex");


    #20;
  end

  initial begin
    $dumpfile("dump1.vcd");
    $dumpvars(0, tb_mm2);
    #180;
    $finish;
  end
endmodule
