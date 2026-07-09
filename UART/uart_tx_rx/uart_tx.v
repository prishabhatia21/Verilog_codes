module uart_tx (
    input  wire  clk,          // System clock
    input  wire  rstn,         // Reset
    input  wire  baud_tick,    // 1 tick per bit time
    input  wire  tx_start,     // Start transmission pulse
    input  wire [7:0] tx_data, // 8-bit data to send
    output reg tx,             // Serial output wire
    output reg tx_busy         // Busy flag (1 = transmitting)
);

    // State machine states
    localparam IDLE  = 2'b00;  // Waiting to send
    localparam START = 2'b01;  // Sending START bit (0)
    localparam DATA  = 2'b10;  // Sending 8 data bits (LSB first)
    localparam STOP  = 2'b11;  // Sending STOP bit (1)
    
    reg [1:0] state;      // Current state
    reg [2:0] bit_index;  // Which data bit we're on (0-7)
    reg [7:0] data_reg;   // Copy of tx_data (to keep stable)
    
   
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin 
            state     <= IDLE;
            tx        <= 1'b1;   // Idle = HIGH
            tx_busy   <= 1'b0;
            bit_index <= 3'd0;
            data_reg  <= 8'd0;
        end else begin
            case (state)
                
                // ============================================
                // IDLE: Waiting for data
                // ============================================
                IDLE: begin
                    tx      <= 1'b1;    // Line is HIGH (idle)
                    tx_busy <= 1'b0;    // Not busy
                    
                    if (tx_start) begin  // User wants to send
                        data_reg <= tx_data;  // Save data
                        tx_busy  <= 1'b1;     // Busy now!
                        state    <= START;    // Go to START
                    end
                end
                
                // ============================================
                // START: Send START bit (0)
                // ============================================
                START: begin
                    tx_busy <= 1'b1;
                    
                    if (baud_tick) begin    // Wait for tick
                        tx <= 1'b0;         // START bit = 0
                        state <= DATA;      // Go to DATA
                        bit_index <= 3'd0;  // Start from bit 0
                    end
                end
                
                // ============================================
                // DATA: Send 8 bits (LSB first!)
                // ============================================
                DATA: begin
                    tx_busy <= 1'b1;
                    
                    if (baud_tick) begin
                        // Send current bit (LSB first)
                        tx <= data_reg[bit_index];
                        
                        if (bit_index == 3'd7) begin  // Last bit?
                            state <= STOP;            // Go to STOP
                            bit_index <= 3'd0;        // Reset for next
                        end else begin
                            bit_index <= bit_index + 1;  // Next bit
                        end
                    end
                end
                
                // ============================================
                // STOP: Send STOP bit (1)
                // ============================================
                STOP: begin
                    if (baud_tick) begin
                        tx      <= 1'b1;    // STOP bit = 1
                        tx_busy <= 1'b0;    // Done!
                        state   <= IDLE;    // Go back to IDLE
                    end
                end
                
                default: state <= IDLE;  // Safety
            endcase
        end
    end
    
endmodule
