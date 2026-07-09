module clk_div (
    input  wire clk,          // 50MHz system clock
    input  wire rstn,        // Active-low reset
    output reg  tx_baud_tick, // Tick for TX (9600 baud)
    output reg  rx_baud_tick  // Tick for RX (8x oversampling)
);
  
  
  localparam TX_DIVISOR = 5208;  // 50M / 9600
  localparam RX_DIVISOR = 651;   // 5208 / 8 (8x sampling)
    
  reg [12:0] tx_count;  // 13-bit counter for TX
  reg [9:0]  rx_count;  // 10-bit counter for RX
  
  
  // ============================================
  // TRANSMITTER BAUD TICk
  // ============================================
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin               
            tx_count    <= 13'd0;
            tx_baud_tick <= 1'b0;
        end else if (tx_count == TX_DIVISOR - 1) 
          begin  // Reached max?
            tx_count    <= 13'd0;        // Reset counter
            tx_baud_tick <= 1'b1;        // Generate pulse
        end else 
          begin
            tx_count    <= tx_count + 1; // Count up
            tx_baud_tick <= 1'b0;        // No pulse
        end
    end
   
    // ============================================
    // RECEIVER BAUD TICK (8x oversampling)
    // ============================================
  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin               // Reset
            rx_count    <= 10'd0;
            rx_baud_tick <= 1'b0;
        end else if (rx_count == RX_DIVISOR - 1) begin  // Reached max?
            rx_count    <= 10'd0;        // Reset counter
            rx_baud_tick <= 1'b1;        // Generate pulse
        end else begin
            rx_count    <= rx_count + 1; // Count up
            rx_baud_tick <= 1'b0;        // No pulse
        end
    end

endmodule
