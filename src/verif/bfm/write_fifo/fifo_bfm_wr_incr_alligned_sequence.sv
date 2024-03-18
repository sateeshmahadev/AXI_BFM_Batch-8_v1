//------------------------------------------------------------------------------------------------------------
//  FILE_NAME: fifo_bfm_wr_incr_unalligned_sequence.sv
//  AUTHOR: Vinay Kumar
//
//  DESCRIPTION:
//
//  In this sequence we will receive values to the local variables through the test 
//  and these values are assigned to the sequence item variables. 
//--------------------------------------------------------------------------------------------------------------

`ifndef FIFO_BFM_WR_INCR_ALLIGNED_SEQUENCE_INCLUDED_
`define FIFO_BFM_WR_INCR_ALLIGNED_SEQUENCE_INCLUDED_

//-----------------------------------------------------------------------------
// Class: fifo_bfm_wr_incr_alligned_sequence
// Description of the class:
// This class provides write sequence for aligned transactions
//-----------------------------------------------------------------------------

class fifo_bfm_wr_incr_alligned_sequence extends base_sequence;

  //local variables of this sequence class that collect values from test and assign to sequence item variables 
  bit[31:0] wdata_seq[$];
  bit[3:0] awlenn;
  bit[31:0] addr;
  bit[3:0] wstrbb;
  bit[1:0] awburstt;
  bit[2:0] awsizee;
  int i;

  `uvm_object_utils(fifo_bfm_wr_incr_alligned_sequence)

  //-----------------------------------------------------------------------------
  // Constructor: new
  // Initializes the fifo_bfm_wr_incr_alligned_sequence class object
  //
  // Parameters:
  // name - instance name of the fifo_bfm_wr_incr_alligned_sequence
  //-----------------------------------------------------------------------------
  function new(string name = "fifo_bfm_wr_incr_alligned_sequence");
    super.new(name);
  endfunction

  //-----------------------------------------------------------------------------
  // Task: body
  // Creates sequence item, randomizes it and sends to the driver  
  //-----------------------------------------------------------------------------
  virtual task body();
    begin
        // Create a write sequence item
        write_fifo_seq_item req;
        req = write_fifo_seq_item::type_id::create("req");

        // Repeat the sequence "i" times
        i = 1;
      	repeat (i) begin
        // Start the item
        start_item(req);

        // Display information about the local variables
        `uvm_info("ALIGNED_SEQUENCE", $sformatf("Address in sequence = %h", addr), UVM_MEDIUM)
        `uvm_info("ALIGNED_SEQUENCE", $sformatf("AWLEN in sequence = %h", awlenn), UVM_MEDIUM)
        `uvm_info("ALIGNED_SEQUENCE", $sformatf("WSTRB in sequence = %h", wstrbb), UVM_MEDIUM)
        `uvm_info("ALIGNED_SEQUENCE", $sformatf("AWBURST in sequence = %h", awburstt), UVM_MEDIUM)
        `uvm_info("ALIGNED_SEQUENCE", $sformatf("AWSIZE in sequence = %h", awsizee), UVM_MEDIUM)
        `uvm_info("ALIGNED_SEQUENCE", $sformatf("WDATA_SEQ in sequence = %p", wdata_seq), UVM_MEDIUM)
        `uvm_info("ALIGNED_SEQUENCE", $sformatf("WDATA_SEQ size in sequence = %0d", wdata_seq.size()), UVM_MEDIUM)

        // Setting the sequence item through local varaibles of this sequence
        assert(req.randomize() with {
          req.type_of_pkt == 0 &&
          req.awaddr == addr &&
          req.wstrb == wstrbb &&
          req.awlen == awlenn &&
          req.awburst == awburstt &&
          req.awsize == awsizee;
          foreach(req.wdata[i]) { req.wdata[i] == wdata_seq[i]; }
        });

        // Finish the item
        finish_item(req);
      end
    end
  endtask

endclass
`endif

