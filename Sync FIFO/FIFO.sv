////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(fifo_if.dut fifoif);

	localparam max_fifo_addr = $clog2(fifoif.FIFO_DEPTH);

	reg [fifoif.FIFO_WIDTH-1:0] mem [fifoif.FIFO_DEPTH-1:0];

	reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
	reg [max_fifo_addr:0] count;

	always @(posedge fifoif.clk or negedge fifoif.rst_n) begin
		if (!fifoif.rst_n) begin
			wr_ptr <= 0;
         // BUG DETECTED : wr_ack should be Low when reset is asserted.
		   fifoif.wr_ack <= 0 ;
		   // BUG DETECTED : overflow should be Low when reset is asserted.
		   fifoif.overflow <= 0 ;
		end
		else if (fifoif.wr_en && count < fifoif.FIFO_DEPTH) begin
			mem[wr_ptr] <= fifoif.data_in;
			fifoif.wr_ack <= 1;
         // BUG DETECTED : overflow should be low when the fifo is not full.
         fifoif.overflow <= 0;
			wr_ptr <= wr_ptr + 1;
		end
		else begin 
			fifoif.wr_ack <= 0; 
			if (fifoif.full && fifoif.wr_en)
				fifoif.overflow <= 1;
			else
				fifoif.overflow <= 0;
		end
	end

	always @(posedge fifoif.clk or negedge fifoif.rst_n) begin
		if (!fifoif.rst_n) begin
			rd_ptr <= 0;
         fifoif.underflow <= 0;
         // BUG DETECTED : data_out should be low when the reset is asserted.
         fifoif.data_out <=0;
		end
		else if (fifoif.rd_en && count != 0) begin
			fifoif.data_out <= mem[rd_ptr];
         // BUG DETECTED : overflow should be low when the fifo is not empty.
         fifoif.underflow <= 0;
			rd_ptr <= rd_ptr + 1;
		end
      // BUG DETECTED : Underflow output should be Sequential.
	   else begin 
		   if (fifoif.empty && fifoif.rd_en)
		   	fifoif.underflow <= 1;
		   else
		   	fifoif.underflow <= 0;
      end
	end

	always @(posedge fifoif.clk or negedge fifoif.rst_n) begin
		if (!fifoif.rst_n) begin
			count <= 0;
		end
		else begin
			if	( ({fifoif.wr_en, fifoif.rd_en} == 2'b10) && !fifoif.full) 
				count <= count + 1;
			else if ( ({fifoif.wr_en, fifoif.rd_en} == 2'b01) && !fifoif.empty)
				count <= count - 1;
         // BUG DETECTED : Uncovered case when both wr_en and rd_en are high and FIFO if full , Reading process happens .
			else if ( ({fifoif.wr_en, fifoif.rd_en} == 2'b11) && fifoif.full)
			   count <= count - 1;
			//BUG DETECTED : Uncovered case when both wr_en and rd_en are high and FIFO if empty , Writing process happens .
			else if ( ({fifoif.wr_en, fifoif.rd_en} == 2'b11) && fifoif.empty)
			   count <= count + 1;

		end
	end

	assign fifoif.full = (count == fifoif.FIFO_DEPTH)? 1 : 0;
	assign fifoif.empty = (count == 0)? 1 : 0;
   //BUG DETECTED : almostfull is high when there is two spots empty , while it should be only one .
	assign fifoif.almostfull = (count == fifoif.FIFO_DEPTH-1)? 1 : 0; 
	assign fifoif.almostempty = (count == 1)? 1 : 0;


   `ifdef SIM
	   //////////////////////////////////////// assertions /////////////////////////////////////////////////
	   always_comb begin
	   	if(!fifoif.rst_n)begin
	   		reset_wr_ptr: assert final (wr_ptr == 0);
	   		reset_rd_ptr: assert final (rd_ptr == 0);
	   		reset_count : assert final (count == 0);
	   	end
	   end

	   property wr_ack_p;
          @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
              ( fifoif.wr_en && count < fifoif.FIFO_DEPTH ) |=> 
                 (fifoif.wr_ack == 1);
       endproperty
       a_wr_ack_p: assert property (wr_ack_p) else $error("error in wr_ack");
       c_wr_ack_p: cover  property (wr_ack_p);	

       property overflow_p;
          @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
              ( fifoif.wr_en && fifoif.full ) |=> 
                 (fifoif.overflow == 1);
       endproperty
       a_overflow_p: assert property (overflow_p) else $error("error in overflow");
       c_overflow_p: cover  property (overflow_p);

      property underflow_p;
          @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
              ( fifoif.rd_en && fifoif.empty ) |=> 
                 (fifoif.underflow == 1);
      endproperty
      a_underflow_p: assert property (underflow_p) else $error("error in underflow");
      c_underflow_p: cover  property (underflow_p);
      property empty_p;
          @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
              ( count == 0 ) |-> 
                 (fifoif.empty);
      endproperty
      a_empty_p: assert property (empty_p) else $error("error in empty");
      c_empty_p: cover  property (empty_p);
      property full_p;
         @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
            ( count == fifoif.FIFO_DEPTH ) |-> 
               (fifoif.full);
      endproperty
      a_full_p: assert property (full_p) else $error("error in full");
      c_full_p: cover  property (full_p);

      property almostfull_p;
         @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
            ( count == fifoif.FIFO_DEPTH - 1) |-> 
               (fifoif.almostfull);
      endproperty
      a_almostfull_p: assert property (almostfull_p) else $error("error in almostfull");
      c_almostfull_p: cover  property (almostfull_p);

      property almostempty_p;
           @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
               ( count == 1 ) |-> 
                  (fifoif.almostempty);
      endproperty
      a_almostempty_p: assert property (almostempty_p) else $error("error in almostempty");
      c_almostempty_p: cover  property (almostempty_p);

      property wr_ptr_wrap_around_p;
           @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
               ( wr_ptr == 7 ) |-> (wr_ptr == 0) [=1];
      endproperty
      a_wr_ptr_wrap_around_p: assert property (wr_ptr_wrap_around_p) else $error("error in wr_ptr_wrap_around");
      c_wr_ptr_wrap_around_p: cover  property (wr_ptr_wrap_around_p);

      property rd_ptr_wrap_around_p;
           @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
              ( rd_ptr == 7 ) |-> (rd_ptr == 0) [=1];
      endproperty
      a_rd_ptr_wrap_around_p: assert property (rd_ptr_wrap_around_p) else $error("error in rd_ptr_wrap_around");
      c_rd_ptr_wrap_around_p: cover  property (rd_ptr_wrap_around_p);

      property count_p;
           @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
               ( count == 8 ) |-> (count == 0 || count == 7) [->1] ;
      endproperty
      a_count_p: assert property (count_p) else $error("error in count");
      c_count_p: cover  property (count_p);

      property wr_operation_p;
            @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
               ( (fifoif.wr_en && count < fifoif.FIFO_DEPTH) ) 
	   	       |=> ( mem[$past(wr_ptr)] == $past(fifoif.data_in) );
      endproperty
      a_wr_operation_p: assert property (wr_operation_p) else $error("error in wr_operation");
      c_wr_operation_p: cover  property (wr_operation_p);

      property check12 ;
	       @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
	            (wr_ptr < fifoif.FIFO_DEPTH) ;
      endproperty
      assert property (check12 ) else $error("error in check12 ");
      cover  property (check12 );

      property check13 ;
	      @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
	           (rd_ptr < fifoif.FIFO_DEPTH) ;
      endproperty
      assert property (check13) else $error("error in check13");
      cover  property (check13);	  

      property check14 ;
	        @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
	           (count <= fifoif.FIFO_DEPTH) ;
      endproperty
      assert property (check14) else $error("error in check14");
      cover  property (check14);	

      property check15;
	       @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
	             ( ({fifoif.wr_en, fifoif.rd_en} == 2'b10) && !fifoif.full) || ( ({fifoif.wr_en, fifoif.rd_en} == 2'b11) && fifoif.empty)
	                  |=> (count == $past(count)+1);
      endproperty
      assert property (check15) else $error("error in check15");
      cover  property (check15);	  

      property check16;
	        @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
	            ( ({fifoif.wr_en, fifoif.rd_en} == 2'b01) && !fifoif.empty) || ( ({fifoif.wr_en, fifoif.rd_en} == 2'b11) && fifoif.full)
	                 |=> (count == $past(count)-1);
      endproperty
      assert property (check16) else $error("error in check16");
      cover  property (check16);

      property check17;
	        @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
	            ( count <fifoif.FIFO_DEPTH -1)
	                 |-> (!fifoif.almostfull);
      endproperty
      assert property (check17) else $error("error in check17");
      cover  property (check17);

      property check18;
	        @(posedge fifoif.clk) disable iff (!fifoif.rst_n)
	             !(fifoif.overflow && fifoif.wr_ack);
      endproperty
      assert property (check18) else $error("error in check18");
      cover  property (check18);
   `endif

endmodule