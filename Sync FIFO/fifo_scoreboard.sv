package fifo_scoreboard_pkg;

    import fifo_transaction_pkg::*;
    import shared_pkg::*;

    class fifo_scoreboard;

        parameter FIFO_WIDTH = 16;
        parameter FIFO_DEPTH = 8;

        logic  [FIFO_WIDTH-1:0] data_out_ref;
        logic  wr_ack_ref;
        logic overflow_ref;
        logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;
        localparam max_fifo_addr = $clog2(FIFO_DEPTH);
        logic [FIFO_WIDTH-1:0] queue[$];
        logic [max_fifo_addr:0] counter;
        
        function void check_data(fifo_transaction F_txn);
            logic [6:0]ref_flags,dut_flags; 
            reference_model(F_txn);
            ref_flags = {wr_ack_ref, overflow_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref};
            dut_flags = {F_txn.wr_ack, F_txn.overflow, F_txn.full, F_txn.empty, F_txn.almostfull,  F_txn.almostempty, F_txn.underflow}; 
            if( (F_txn.data_out == data_out_ref) &&(dut_flags == ref_flags))begin
                correct_count++;
            end
            else begin
                error_count++;
                $display("there is an error @ time : %0t",$time);
                $display("dut_inputs: rst_n = %0b, wr_en = %0b, rd_en = %0b",F_txn.rst_n, F_txn.wr_en, F_txn.rd_en);
                $display(" dut_flags : {wr_ack,overflow,full,empty,almostfull,almostempty,underflow}=0b%7b",dut_flags);
                $display(" ref_flags : {wr_ack,overflow,full,empty,almostfull,almostempty,underflow}=0b%7b",ref_flags);
                $display("  dut_out  : %0h, ref_out : %0h",F_txn.data_out, data_out_ref);
            end
        endfunction
        function void reference_model(fifo_transaction F_ref_txn);
            //write check
            if(!F_ref_txn.rst_n)begin
                wr_ack_ref = 0;
                overflow_ref =0;
                data_out_ref = 0;
                underflow_ref =0;
                queue.delete();
            end
            else begin
                if(F_ref_txn.wr_en && (counter < FIFO_DEPTH))begin
                    queue.push_back(F_ref_txn.data_in);
                    wr_ack_ref = 1;
                    overflow_ref =0;
                end 
                else begin
                    wr_ack_ref =0;
                    if(F_ref_txn.wr_en && full_ref)begin
                        overflow_ref =1;
                    end
                    else begin
                        overflow_ref =0;
                    end
                end
                if(F_ref_txn.rd_en && (counter != 0))begin
                    data_out_ref = queue.pop_front();
                    underflow_ref =0;
                end 
                else begin
                    if(F_ref_txn.rd_en && empty_ref)begin
                        underflow_ref =1;
                    end
                    else begin
                        underflow_ref =0;
                    end
                end
            end
            if (!F_ref_txn.rst_n) begin
              counter = 0;
            end else begin
              case ({F_ref_txn.wr_en, F_ref_txn.rd_en})
                2'b10: if (!full_ref)  counter = counter + 1;
                2'b01: if (!empty_ref) counter = counter - 1;
                2'b11: begin
                  if (full_ref && !empty_ref) counter = counter - 1; // writing when full, read takes priority
                  else if (empty_ref && !full_ref) counter = counter + 1;
                end
              endcase
            end
            full_ref = (counter == FIFO_DEPTH)?1:0;
            empty_ref = (counter == 0)?1:0;
            almostfull_ref  = (counter == FIFO_DEPTH - 1)?1:0;
            almostempty_ref = (counter == 1)?1:0;
        endfunction
    endclass
endpackage