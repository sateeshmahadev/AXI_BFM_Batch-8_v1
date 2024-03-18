//*************************************************
//******TEST: FIFO 32b READ TEST ******************
//*************************************************
`ifndef FIFO_BFM_32B_RD_TEST_INCLUDED_
`define FIFO_BFM_32B_RD_TEST_INCLUDED_

//*********************************************
//*************CLASS DESCRIPTION***************
//*********************************************

// Extend fifo_bfm_32b_rd_test from fifo_base_test

class fifo_bfm_32b_rd_test extends fifo_base_test;

// Factory registration using `uvm_component_utils
 `uvm_component_utils(fifo_bfm_32b_rd_test)

 
  // Declare the handle for fifo_bfm_32b_rd_seq sequence
  fifo_bfm_32b_rd_seq fifo_32b_rd_seq_h;
  
  // Declare the handle for axi4_slave_nbk_read_32b_transfer_seq sequence
  axi4_slave_nbk_read_32b_transfer_seq axi4_slave_nbk_read_32b_transfer_seq_h;
  
//**************************************
// Standard UVM Methods:
//**************************************

  extern function new(string name = "fifo_bfm_32b_rd_test", uvm_component parent = null);
  extern virtual task run_phase(uvm_phase phase);

endclass : fifo_bfm_32b_rd_test

//************************************************************
// Parameters:name - fifo_bfm_32b_rd_test
//  parent - parent under which this component is created
//************************************************************


//***************** constructor new method *******************

function fifo_bfm_32b_rd_test::new(string name = "fifo_bfm_32b_rd_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new


	
//***************** run() phase method *********************

task fifo_bfm_32b_rd_test::run_phase(uvm_phase phase);


  //create instance for axi4_slave_nbk_read_32b_transfer_seq_h  sequence handle
  axi4_slave_nbk_read_32b_transfer_seq_h = axi4_slave_nbk_read_32b_transfer_seq::type_id::create("axi4_slave_nbk_read_32b_transfer_seq_h");
  
  //create instance for fifo_32b_rd_seq_h  sequence handle
  fifo_32b_rd_seq_h = fifo_bfm_32b_rd_seq::type_id::create("fifo_32b_rd_seq_h");
  
  `uvm_info(get_type_name(),$sformatf("fifo_bfm_rd_test"),UVM_LOW);
  
  
  //raise objection
  phase.raise_objection(this);
  
  fork
  begin: T1_SL_RD
    forever begin
      $display("slave_nbk_read_begin");
	  //start the sequence wrt sequencer
        axi4_slave_nbk_read_32b_transfer_seq_h.start(env_h.axi_slave_agent_h.axi4_slave_read_seqr_h);
        $display("slave_nbk_read_happened");
      end
    end
  join_none

  $display("fifo_32bit_sequence_MESHAK_begin");
  //start the sequence wrt sequencer
  fifo_32b_rd_seq_h.start(env_h.write_fifo_agent_h.write_fifo_sequencer_h);
  $display("fifo_32bit_sequence_MESHAK_end");
  
  //drop objection
  phase.drop_objection(this);

endtask : run_phase

`endif 
