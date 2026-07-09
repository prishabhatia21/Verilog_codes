   module mem_8KB (
    input  logic        CLK,
    input  logic        RSTN,
    input  logic        PD,
    input  logic        CEN,
    input  logic [12:0] ADDR,  
    input  logic        WEN,
    input  logic [7:0]  Data,
    output logic [7:0]  Q_Out
);

     mem_para #(
        .ADDR_WIDTH(13),
        .DATA_WIDTH(8)
    ) u_mem (
    .CLK(CLK),.RSTN(RSTN),.PD(PD),.CEN(CEN),.WEN(WEN),.ADDR(ADDR),.Data(Data),.Q_Out(Q_Out)
       
    );
endmodule
