module fifo_top();

    bit clk;
    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    fifo_if fifoif(clk);
    FIFO DUT(fifoif);
    fifo_test test(fifoif);
    fifo_monitor monitor(fifoif);
endmodule 