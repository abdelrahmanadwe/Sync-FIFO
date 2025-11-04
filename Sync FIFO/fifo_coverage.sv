package fifo_coverage_pkg;

    import fifo_transaction_pkg::*;

    class fifo_coverage;
        fifo_transaction fifo_cvg_txn;
        covergroup fifo_cg;
            wr_en_cp : coverpoint fifo_cvg_txn.wr_en{
                bins wr_en_on = {1};
                bins wr_en_off = {0};
            }
            rd_en_cp : coverpoint fifo_cvg_txn.rd_en{
                bins rd_en_on = {1};
                bins rd_en_off = {0};
            }
            wr_ack_cp : coverpoint fifo_cvg_txn.wr_ack{
                bins wr_ack_on = {1};
                bins wr_ack_off = {0};
            }
            overflow_cp : coverpoint fifo_cvg_txn.overflow{
                bins overflow_on = {1};
                bins overflow_off = {0};
            }
            full_cp : coverpoint fifo_cvg_txn.full{
                bins full_on = {1};
                bins full_off = {0};
            }
            empty_cp : coverpoint fifo_cvg_txn.empty{
                bins empty_on = {1};
                bins empty_off = {0};
            }
            almostfull_cp : coverpoint fifo_cvg_txn.almostfull{
                bins almostfull_on = {1};
                bins almostfull_off = {0};
            }
            almostempty_cp : coverpoint fifo_cvg_txn.almostempty{
                bins almostempty_on = {1};
                bins almostempty_off = {0};
            }
            underflow_cp : coverpoint fifo_cvg_txn.underflow{
                bins underflow_on = {1};
                bins underflow_off = {0};
            }
            wr_rd_ack_cp : cross wr_en_cp, rd_en_cp, wr_ack_cp{
                illegal_bins wr_en_ack_on = binsof(wr_en_cp) intersect {0} && binsof(wr_ack_cp) intersect {1};
            }
            wr_rd_overflow_cp: cross wr_en_cp, rd_en_cp, overflow_cp{
                illegal_bins wr_en_overflow_on = binsof(wr_en_cp) intersect {0} && binsof(overflow_cp) intersect {1};
            }
            wr_rd_full_cp: cross wr_en_cp, rd_en_cp, full_cp{
                illegal_bins wr_en_overflow_on = binsof(rd_en_cp) intersect {1} && binsof(full_cp) intersect {1};
            }
            wr_rd_empty_cp: cross wr_en_cp, rd_en_cp, empty_cp;
            wr_rd_almostfull_cp: cross wr_en_cp, rd_en_cp, almostfull_cp;
            wr_rd_almostempty_cp: cross wr_en_cp, rd_en_cp, almostempty_cp;
            wr_rd_underflow_cp: cross wr_en_cp, rd_en_cp, underflow_cp{
                illegal_bins wr_en_overflow_on = binsof(rd_en_cp) intersect {0} && binsof(underflow_cp) intersect {1};
            }
        endgroup

        function new;
            fifo_cg = new;
        endfunction

        function void sample_data(fifo_transaction F_txn);
            fifo_cvg_txn = F_txn;
            fifo_cg.sample();
        endfunction
    endclass
endpackage