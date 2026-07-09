module seq_det_0011 (
    input clk, rst, x,
    output reg y
);
    typedef enum logic [1:0] {
        S0, S1, S2, S3
    } state_t;

    state_t cs, ns;

    always @(posedge clk or posedge rst)
        if (rst) cs <= S0;
        else     cs <= ns;

    always @(*) begin
        ns = S0;
        y  = 0;
        case (cs)
            S0: if (x) begin ns = S0; y = 0; end 
                else   begin ns = S1; y = 0; end  

            S1: if (x) begin ns = S0; y = 0; end  
                else   begin ns = S2; y = 0; end  
          
            S2: if (x) begin ns = S3; y = 0; end 
                else   begin ns = S2; y = 0; end  

            S3: if (x) begin ns = S0; y = 1; end
    			else   begin ns = S1; y = 0; end
        endcase
    end
endmodule
