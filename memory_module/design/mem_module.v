module mem_module (
    input  logic        CLK,
    input  logic        RSTN,
    input  logic        PD,
    input  logic        CEN,
    input  logic [11:0] ADDR,
    input  logic        WEN,
    input  logic [7:0]  Data,
    output logic [7:0]  Q_Out
);

  logic [7:0] mem [0:2047];
  integer i;

  always_ff @(posedge CLK or negedge RSTN) begin
    if (!RSTN) begin
    
      for (i = 0; i < 2048; i = i + 1)
        mem[i] <= 8'hxx;
      Q_Out <= 8'hxx;
    end
    else if (PD) begin
            Q_Out <= 8'hxx;
    end
    else if (!CEN) begin
      if (WEN == 1'b0)
        mem[ADDR] <= Data;       
      else
        Q_Out <= mem[ADDR];     
    end
  end

endmodule
