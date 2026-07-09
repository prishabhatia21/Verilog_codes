module uart_rx (
    input  wire clk,          // System clock
    input  wire rstn,         // Reset 
    input  wire baud_tick,    // 8x oversampled tick
    input  wire rx,           // Serial input
    output reg  [7:0] rx_data,      // Received data
    output reg  rx_done,      // Data valid flag
    output reg  rx_busy       // Receiver busy flag
);

    // State machine states
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;
  
    reg [1:0] state;
    reg [2:0] bit_index;      // 0-7 (8 data bits)
    reg [7:0] data_reg;       // Shift register for incoming data
    reg [2:0] sample_count;   // 0-7 (8x oversampling counter)
    
    // Double synchronizer for metastability
    reg rx_sync1, rx_sync2;
    
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // Reset everything
            state        <= IDLE;
            rx_busy      <= 1'b0;
            rx_done      <= 1'b0;
            bit_index    <= 3'd0;
            data_reg     <= 8'd0;
            sample_count <= 3'd0;
            rx_sync1     <= 1'b1;
            rx_sync2     <= 1'b1;
        end else begin
            // Synchronize RX input (metastability protection)
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
            
            // State machine
            case (state)
                
                // ============================================
                // IDLE: Wait for START bit
                // ============================================
                IDLE: begin
                    rx_done <= 1'b0;
                    rx_busy <= 1'b0;
                    bit_index <= 3'd0;
                    sample_count <= 3'd0;
                    
                    // Start bit detected? (1 → 0 transition)
                    if (rx_sync2 == 1'b0) begin
                        state <= START;
                        rx_busy <= 1'b1;
                        sample_count <= 3'd0;
                    end
                end
                
                // ============================================
                // START: Verify start bit (sample at middle)
                // ============================================
                START: begin
                    rx_busy <= 1'b1;
                    
                    if (baud_tick) begin
                        if (sample_count == 3'd3) begin  // 4th sample = middle of START bit
                            // Verify it's still 0 (valid start bit)
                            if (rx_sync2 == 1'b0) begin
                                // Valid start bit! Move to DATA
                                state <= DATA;
                                bit_index <= 3'd0;
                            end else begin
                                // False start! Go back to IDLE
                                state <= IDLE;
                            end
                            sample_count <= 3'd0;
                        end else begin
                            sample_count <= sample_count + 1;
                        end
                    end
                end
                
                // ============================================
                // DATA: Sample 8 bits (at middle of each bit)
                // ============================================
                DATA: begin
                    rx_busy <= 1'b1;
                    
                    if (baud_tick) begin
                        if (sample_count == 3'd3) begin  // 4th sample = middle of bit
                            // Sample the bit at the middle!
                            data_reg[bit_index] <= rx_sync2;
                            
                            if (bit_index == 3'd7) begin  // Last bit?
                                state <= STOP;
                                bit_index <= 3'd0;
                            end else begin
                                bit_index <= bit_index + 1;
                            end
                            sample_count <= 3'd0;
                        end else begin
                            sample_count <= sample_count + 1;
                        end
                    end
                end
                
                // ============================================
                // STOP: Verify stop bit, output data
                // ============================================
                STOP: begin
                    if (baud_tick) begin
                        if (sample_count == 3'd3) begin  // Middle of STOP bit
                            // Check stop bit (should be 1)
                            if (rx_sync2 == 1'b1) begin
                                rx_data <= data_reg;   // Valid data!
                                rx_done <= 1'b1;       // Data is ready
                            end
                            // Go back to IDLE
                            state <= IDLE;
                            sample_count <= 3'd0;
                        end else begin
                            sample_count <= sample_count + 1;
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
endmodule
