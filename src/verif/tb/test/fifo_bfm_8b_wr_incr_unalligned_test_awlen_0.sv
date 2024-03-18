`ifndef FIFO_BFM_8B_WR_INCR_UNALLIGNED_TEST_AWLEN_0_INCLUDED_
`define FIFO_BFM_8B_WR_INCR_UNALLIGNED_TEST_AWLEN_0_INCLUDED_

//-----------------------------------------------------------------------------
// Class: fifo_bfm_8b_wr_incr_unalligned_test_awlen_0 
// Description of the class:
// This class provides the test case for fifo_bfm_8b_wr_incr_unalligned_awlen_0 
//-----------------------------------------------------------------------------
class fifo_bfm_8b_wr_incr_unalligned_test_awlen_0 extends fifo_base_test;
  `uvm_component_utils(fifo_bfm_8b_wr_incr_unalligned_test_awlen_0)

  //Local variables of this test through which we send values to the sequence
  bit[31:0] wdata_seq[$];
  bit[3:0] awlenn = 0;
  bit [31:0] addr;
  bit[3:0] wstrbb=4'b0001;
  bit[1:0] awburstt = 1;
  bit[2:0] awsizee = 2;

  // Sequence handles for write transactions
  fifo_bfm_wr_incr_unalligned_sequence fifo_bfm_wr_incr_unalligned_sequence_h; //fifo wr sequence
  axi4_slave_nbk_write_32b_transfer_seq axi4_slave_nbk_write_32b_transfer_seq_h;  //wr_response sequence of slave avip

  //-----------------------------------------------------------------------------
  // Constructor: new
  // Initializes the fifo_bfm_8b_wr_incr_unalligned_test_awlen_0 class object
  //
  // Parameters:
  //  name - instance name of the fifo_bfm_8b_wr_incr_unalligned_test_awlen_0 
  //  parent - parent under which this component is created
  //-----------------------------------------------------------------------------
  function new(string name = "fifo_bfm_8b_wr_incr_unalligned_test_awlen_0",uvm_component parent = null);
    super.new(name, parent);
    void'(std::randomize(addr) with {addr%((2**awsizee)*8)==0;});
    `uvm_info("UVM_TEST", $sformatf("Address = %h", addr), UVM_MEDIUM)
    void'(std::randomize(wdata_seq) with {wdata_seq.size()==awlenn+1;});
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
    fifo_bfm_wr_incr_unalligned_sequence_h=fifo_bfm_wr_incr_unalligned_sequence::type_id::create("fifo_bfm_wr_incr_unalligned_sequence_h");
  endfunction

  //-----------------------------------------------------------------------------
  // Task: run_phase
  // Assign values from local variables of test to the sequence variables and starts the two sequences
  //
  // Parameters:
  //  phase - stores the current phase 
  //-----------------------------------------------------------------------------
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(),$sformatf("fifo_bfm_8b_wr_incr_unalligned_test_awlen_0"),UVM_LOW)

    phase.raise_objection(this);
   
     // Configure the write sequence parameters through local variables of test
      fifo_bfm_wr_incr_unalligned_sequence_h.awlenn=awlenn;
      fifo_bfm_wr_incr_unalligned_sequence_h.addr=addr;
      fifo_bfm_wr_incr_unalligned_sequence_h.wstrbb=wstrbb;
      fifo_bfm_wr_incr_unalligned_sequence_h.awburstt=awburstt;
      fifo_bfm_wr_incr_unalligned_sequence_h.awsizee=awsizee;
      fifo_bfm_wr_incr_unalligned_sequence_h.wdata_seq=wdata_seq;

    // Start the write sequence and the avip write response sequence concurrently
      fork
        begin
          forever begin
	  //start the avip write response sequence 
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
