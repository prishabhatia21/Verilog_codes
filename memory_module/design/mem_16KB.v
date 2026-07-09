module mem_16KB (
    input  logic        CLK,
    input  logic        RSTN,
    input  logic        PD,
    input  logic        CEN,
    input  logic [13:0] ADDR,
    input  logic        WEN,
    input  logic [7:0]  Data,
    output logic [7:0]  Q_Out
);

    wire CEN0 = CEN | ADDR[13];
    wire CEN1 = CEN | ~ADDR[13];
    wire [7:0] Q0, Q1;

    mem_8KB inst0 (
        .CLK(CLK),
        .RSTN(RSTN),
        .PD(PD),
        .CEN(CEN0),
        .ADDR(ADDR[12:0]),
        .WEN(WEN),
        .Data(Data),
        .Q_Out(Q0)
    );

    mem_8KB inst1 (
        .CLK(CLK),
        .RSTN(RSTN),
        .PD(PD),
        .CEN(CEN1),
        .ADDR(ADDR[12:0]),
        .WEN(WEN),
        .Data(Data),
        .Q_Out(Q1)
    );

    assign Q_Out = ADDR[13] ? Q1 : Q0;

endmodule
