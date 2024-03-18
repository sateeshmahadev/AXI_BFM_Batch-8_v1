`ifndef AXI4_SLAVE_BK_READ_INCR_BURST_SEQ_INCLUDED_
`define AXI4_SLAVE_BK_READ_INCR_BURST_SEQ_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi4_slave_bk_read_incr_burst_seq
// Extends the axi4_slave_bk_base_seq and randomises the req item
//--------------------------------------------------------------------------------------------
class axi4_slave_bk_read_incr_burst_seq extends axi4_slave_bk_base_seq;
  `uvm_object_utils(axi4_slave_bk_read_incr_burst_seq)

  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi4_slave_bk_read_incr_burst_seq");
  extern task body();
endclass : axi4_slave_bk_read_incr_burst_seq

//--------------------------------------------------------------------------------------------
// Construct: new
// Initializes new memory for the object
//
// Parameters:
//  name - axi4_slave_bk_read_incr_burst_seq
//--------------------------------------------------------------------------------------------
function axi4_slave_bk_read_incr_burst_seq::new(string name = "axi4_slave_bk_read_incr_burst_seq");
  super.new(name);
endfunction : new

//--------------------------------------------------------------------------------------------
// Task: body
// Creates the req of type slave_bk transaction and randomises the req
//--------------------------------------------------------------------------------------------
task axi4_slave_bk_read_incr_burst_seq::body();
  super.body();
  req.transfer_type=BLOCKING_READ;
  
  start_item(req);
  if(!req.randomize())begin
    `uvm_fatal("axi4","Rand failed");
  end
 
  req.print();
  finish_item(req);

endtask : body

`endif

