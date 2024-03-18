//*************************************************
//******SEQUENCE: FIFO 512b read Transactions ******
//*************************************************
 `ifndef FIFO_BFM_512B_RD_SEQ_INCLUDED_
 `define FIFO_BFM_512B_RD_SEQ_INCLUDED_
 
//*********************************************
//*************CLASS DESCRIPTION***************
//*********************************************

// Extend fifo_bfm_512b_rd_seq from base_sequence
 class fifo_bfm_512b_rd_seq extends base_sequence;
  
// Factory registration using `uvm_object_utils 
 `uvm_object_utils(fifo_bfm_512b_rd_seq)

 
//**************************************
// Standard UVM Methods:
//**************************************

  extern function new(string name = "fifo_bfm_512b_rd_seq");
  extern virtual task body();

endclass:fifo_bfm_512b_rd_seq

//************************************************************
// Initializes fifo_bfm_wr_seq class object
// Parameters:name - fifo_bfm_wr_seq
//************************************************************

//***************** constructor new method *******************

function fifo_bfm_512b_rd_seq::new(string name="fifo_bfm_512b_rd_seq");
  super.new(name);
endfunction:new



//*********************task body method **********************************
   // Generate sequence items 
   // Hint use create req, start item, assert for randomization with in line
   // constraint (with) finish item inside repeat's begin end block 
//*************************************************************************


task fifo_bfm_512b_rd_seq::body();
begin
  write_fifo_seq_item req;
  req=write_fifo_seq_item::type_id::create("req");
  repeat(1) begin
    start_item(req);
    assert(req.randomize() with {req.type_of_pkt==1 && req.arlen==15;});
  finish_item(req);
end
end
endtask


`endif
