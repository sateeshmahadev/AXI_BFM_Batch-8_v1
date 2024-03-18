`ifndef FIFO_BFM_32B_WR_INCR_UNALLIGNED_TEST_AWLEN_0_TO_3_INCLUDED_
`define FIFO_BFM_32B_WR_INCR_UNALLIGNED_TEST_AWLEN_0_TO_3_INCLUDED_

//-----------------------------------------------------------------------------
// Class: fifo_bfm_32b_wr_incr_unalligned_test_awlen_8_to_11 
// Description of the class:
// This class provides the test case for fifo_bfm_32b_wr_incr_unalligned_awlen_8_to_11 
// where awlenn can be in the range [8, 11]
//-----------------------------------------------------------------------------
class fifo_bfm_32b_wr_incr_unalligned_test_awlen_8_to_11 extends fifo_base_test;
  `uvm_component_utils(fifo_bfm_32b_wr_incr_unalligned_test_awlen_8_to_11)

  //Local variables of this test through which we send values to the sequence
  bit[31:0] wdata_seq[$];
  bit[3:0] awlenn;
  bit[31:0] addr;
  bit[3:0] wstrbb;
  bit[1:0] awburstt = 1;
  bit[2:0] awsizee = 2;

  // Sequence handles for write transactions
  fifo_bfm_wr_incr_unalligned_sequence fifo_bfm_wr_incr_unalligned_sequence_h;  //write fifo sequence
  axi4_slave_nbk_write_32b_transfer_seq axi4_slave_nbk_write_32b_transfer_seq_h; //wr response sequence by avip slave

  //-----------------------------------------------------------------------------
  // Constructor: new
  // Initializes the fifo_bfm_32b_wr_incr_unalligned_test_awlen_8_to_11 class object
  //
  // Parameters:
  //  name - instance name of the fifo_bfm_32b_wr_incr_unalligned_test_awlen_8_to_11 
  //  parent - parent under which this component is created
  //-----------------------------------------------------------------------------
  function new(string name = "fifo_bfm_32b_wr_incr_unalligned_test_awlen_8_to_11", uvm_component parent = null);
    super.new(name, parent);
    // Randomize awlenn within the range [8, 11]
    void'(std::randomize(awlenn) with {awlenn inside {[8:11]};});
    `uvm_info("UVM_TEST", $sformatf("AWLEN = %h", awlenn), UVM_MEDIUM)

    //Randomize wstrbb values inside {1,3,7}
    void'(std::randomize(wstrbb) with {wstrbb inside {'h1, 'h3, 'h7};});
    `uvm_info("UVM_TEST", $sformatf("WSTRB = %h", wstrbb), UVM_MEDIUM)
    
    void'(std::randomize(addr) with {addr % ((2**awsizee) * 8) == 0;});
    `uvm_info("UVM_TEST", $sformatf("Address = %h", addr), UVM_MEDIUM)
    void'(std::randomize(wdata_seq) with {wdata_seq.size() == awlenn + 1;});
  endfunction

  //-----------------------------------------------------------------------------
  // Function: build_phase
  // Creates the required sequences
  //
  // Parameters:
  //  phase - stores the current phase 
  //-----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi4_slave_nbk_write_32b_transfer_seq_h = axi4_slave_nbk_write_32b_transfer_seq::type_id::create("axi4_slave_nbk_write_32b_transfer_seq_h");
    fifo_bfm_wr_incr_unalligned_sequence_h = fifo_bfm_wr_incr_unalligned_sequence::type_id::create("fifo_bfm_wr_incr_unalligned_sequence_h");
  endfunction

  //-----------------------------------------------------------------------------
  // Task: run_phase
  // Assign values from local variables of test to the sequence variables and starts the two sequences
  //
  // Parameters:
  //  phase - stores the current phase 
  //-----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("fifo_bfm_32b_wr_incr_unalligned_test_awlen_8_to_11"), UVM_LOW)

    phase.raise_objection(this);

    // Configure the write sequence parameters through local variables of test
    fifo_bfm_wr_incr_unalligned_sequence_h.awlenn = awlenn;
    fifo_bfm_wr_incr_unalligned_sequence_h.addr = addr;
    fifo_bfm_wr_incr_unalligned_sequence_h.wstrbb = wstrbb;
    fifo_bfm_wr_incr_unalligned_sequence_h.awburstt = awburstt;
    fifo_bfm_wr_incr_unalligned_sequence_h.awsizee = awsizee;
    fifo_bfm_wr_incr_unalligned_sequence_h.wdata_seq = wdata_seq;
   
    // Start the write sequence and the avip write response sequence concurrently
    fork
      begin
        forever begin
          axi4_slave_nbk_write_32b_transfer_seq_h.start(env_h.axi_slave_agent_h.axi4_slave_write_seqr_h);
        end
      end
    join_none

    // Start the FIFO write sequence
    fifo_bfm_wr_incr_unalligned_sequence_h.start(env_h.write_fifo_agent_h.write_fifo_sequencer_h);

    phase.drop_objection(this);
  endtask
endclass
`endif

