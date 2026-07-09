module tb_seq_det_0011;
    reg clk, rst, x;
    wire y;

    seq_det_0011 dut (.clk(clk), .rst(rst), .x(x), .y(y));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump_0011.vcd");
        $dumpvars(0, tb_seq_det_0011);
    end

    initial begin
        $monitor("time=%0t | rst=%b x=%b clk=%b y=%b", $time, rst, x, clk, y);
    end

    task apply_bit(input reg b);
        @(posedge clk);
        x = b;
    endtask

    initial begin
        rst = 1; x = 0;
        #12 rst = 0;

        // CASE 1: clean 0011 -> y=1
        $display("-- CASE 1: 0 0 1 1 --");
        apply_bit(0);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);
        #10;

        // CASE 2: 0011 twice -> y=1 twice
        $display("-- CASE 2: 0 0 1 1 0 0 1 1 --");
        apply_bit(0);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);
        apply_bit(0);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);
        #10;

        // CASE 3: broken 0 0 1 0 1 1 -> no detect
        $display("-- CASE 3: 0 0 1 0 1 1 (broken) --");
        apply_bit(0);
        apply_bit(0);
        apply_bit(1);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);
        #10;

        // CASE 4: 1 1 1 0 0 1 1 -> detect only at end
        $display("-- CASE 4: 1 1 1 0 0 1 1 --");
        apply_bit(1);
        apply_bit(1);
        apply_bit(1);
        apply_bit(0);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);
        #10;

        $display("-- SIMULATION DONE --");
        #20 $finish;
      end
endmodule
