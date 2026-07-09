module mem_para #(
    parameter ADDR_WIDTH = 11,   
    parameter DATA_WIDTH = 8   ) (
    input  logic                  CLK,
    input  logic                  RSTN,
    input  logic                  PD,
    input  logic                  CEN,
    input  logic [ADDR_WIDTH-1:0] ADDR,
    input  logic                  WEN,
    input  logic [DATA_WIDTH-1:0] Data,
    output logic [DATA_WIDTH-1:0] Q_Out
);

  localparam int DEPTH = 1 << ADDR_WIDTH;

  logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
  integer i;

  always_ff @(posedge CLK or negedge RSTN) begin
    if (!RSTN) begin
      for (i = 0; i < DEPTH; i = i + 1)
        mem[i] <= 'x;
      Q_Out <= 'x;
    end
    else if (PD) begin
      Q_Out <= 'x;
    end
    else if (!CEN) begin
      if (WEN == 1'b0)
        mem[ADDR] <= Data;
      else
        Q_Out <= mem[ADDR];
    end
  end

endmodule
