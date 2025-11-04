package fifo_transaction_pkg;
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    class fifo_transaction #(parameter FIFO_WIDTH = 16,
                            parameter FIFO_DEPTH = 8);

        rand logic [FIFO_WIDTH-1:0] data_in;
        rand logic rst_n; 
        rand logic wr_en;
        rand logic rd_en;
        
        logic  [FIFO_WIDTH-1:0] data_out;
        logic  wr_ack;
        logic overflow;
        logic full, empty, almostfull, almostempty, underflow;
        int RD_EN_ON_DIST, WR_EN_ON_DIST;

        function new(int RD_EN_ON_DIST = 30, int WR_EN_ON_DIST = 70);
            this.RD_EN_ON_DIST = RD_EN_ON_DIST;
            this.WR_EN_ON_DIST = WR_EN_ON_DIST; 
        endfunction

        constraint res_cs{
            rst_n dist { 1 :/98, 0 :/2};
        }
        constraint wr_en_cs{
            wr_en dist { 1 :/WR_EN_ON_DIST, 0 :/ 100-WR_EN_ON_DIST};
        }
        constraint rd_en_cs{
            rd_en dist { 1 :/RD_EN_ON_DIST, 0 :/ 100-RD_EN_ON_DIST};
        }
        
    endclass
endpackage