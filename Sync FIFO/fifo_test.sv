import fifo_transaction_pkg ::*;
import shared_pkg::*;

module fifo_test (fifo_if.test fifoif);

      fifo_transaction test_txn = new();

      initial begin
            fifoif.rst_n = 0 ;
            repeat(2) @(negedge fifoif.clk);
            repeat(2000) begin
                  @(negedge fifoif.clk); 
                  assert(test_txn.randomize());
                  fifoif.rst_n = test_txn.rst_n ;
                  fifoif.wr_en = test_txn.wr_en ;
                  fifoif.rd_en = test_txn.rd_en ;
                  fifoif.data_in = test_txn.data_in ;
            end
            test_finished = 1 ;
      end
endmodule