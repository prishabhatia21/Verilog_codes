module uart_top (
    input  wire       clk,          // System clock
    input  wire       rstn,         // Reset 
    input  wire       tx_start,     // Start transmission
    input  wire [7:0] tx_data,      // Data to send
    input  wire       rx_in,        // Serial input from outside
    output wire       tx_out,       // Serial output to outside
    output wire [7:0] rx_data,      // Received data
    output wire       rx_done,      // Data valid flag
    output wire       tx_busy,      // Transmitter busy
    output wire       rx_busy       // Receiver busy
);

    // Internal signals
    wire tx_baud_tick;   // Tick for TX
    wire rx_baud_tick;   // Tick for RX (8x oversampling)
    wire tx_wire;        // Internal TX signal
    
    // ============================================
    // CLOCK DIVIDER
    // ============================================
    clk_div u_clk_div (
        .clk          (clk),
        .rstn         (rstn),          
        .tx_baud_tick (tx_baud_tick), 
        .rx_baud_tick (rx_baud_tick)   
    );
    
    // ============================================
    // UART TRANSMITTER
    // ============================================
    uart_tx u_uart_tx (
        .clk        (clk),
        .rstn       (rstn),          
        .baud_tick  (tx_baud_tick),  
        .tx_start   (tx_start),
        .tx_data    (tx_data),
        .tx         (tx_wire),       
        .tx_busy    (tx_busy)
    );
    
    // Connect TX output
    assign tx_out = tx_wire;
    
    // ============================================
    // UART RECEIVER
    // ============================================
    uart_rx u_uart_rx (
        .clk        (clk),
        .rstn       (rstn),          // ← FIXED
        .baud_tick  (rx_baud_tick),  // ← Use RX tick (8x)
        .rx         (rx_in),         // ← External input
        .rx_data    (rx_data),
        .rx_done    (rx_done),
        .rx_busy    (rx_busy)
    );

endmodule
