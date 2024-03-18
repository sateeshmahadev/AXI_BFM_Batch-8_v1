`ifndef FIFO_BFM_224B_WR_INCR_ALLIGNED_TEST_AWLEN_6_INCLUDED_
`define FIFO_BFM_224B_WR_INCR_ALLIGNED_TEST_AWLEN_6_INCLUDED_

class fifo_bfm_224b_wr_incr_alligned_test_awlen_6 extends fifo_base_test;
  `uvm_component_utils(fifo_bfm_224b_wr_incr_alligned_test_awlen_6)
  bit[31:0] wdata_seq[$];
  bit[3:0] awlenn = 6;
  bit [31:0] addr;
  bit[3:0] wstrbb=4'hf;
  bit[1:0] awburstt = 1;
  bit[2:0] awsizee = 2;


  fifo_bfm_wr_incr_alligned_sequence fifo_bfm_wr_incr_alligned_sequence_h;
  axi4_slave_nbk_write_32b_transfer_seq axi4_slave_nbk_write_32b_transfer_seq_h;

  function new(string name = "fifo_bfm_224b_wr_incr_alligned_test_awlen_6",uvm_component parent = null);
    super.new(name, parent);
    void'(std::randomize(addr) with {addr%((2**awsizee)*8)==0;});
    `uvm_info("UVM_TEST", $sformatf("Address = %h", addr), UVM_MEDIUM)
    void'(std::randomize(wdata_seq) with {wdata_seq.size()==awlenn+1;});
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi4_slave_nbk_write_32b_transfer_seq_h = axi4_slave_nbk_write_32b_transfer_seq::type_id::create("axi4_slave_nbk_write_32b_transfer_seq_h");
    fifo_bfm_wr_incr_alligned_sequence_h=fifo_bfm_wr_incr_alligned_sequence::type_id::create("fifo_bfm_wr_incr_alligned_sequence_h");
  endfunction

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(),$sformatf("fifo_bfm_224b_wr_incr_alligned_test_awlen_6"),UVM_LOW)

    phase.raise_objection(this);
      fifo_bfm_wr_incr_alligned_sequence_h.awlenn=awlenn;
      fifo_bfm_wr_incr_alligned_sequence_h.addr=addr;
      fifo_bfm_wr_incr_alligned_sequence_h.wstrbb=wstrbb;
      fifo_bfm_wr_incr_alligned_sequence_h.awburstt=awburstt;
      fifo_bfm_wr_incr_alligned_sequence_h.awsizee=awsizee;
      fifo_bfm_wr_incr_alligned_sequence_h.wdata_seq=wdata_seq;

      fork
        begin
          forever begin
            axi4_slave_nbk_write_32b_transfer_seq_h.start(env_h.axi_slave_agent_h.axi4_slave_write_seqr_h);
        end
      end
    join_none

    fifo_bfm_wr_incr_alligned_sequence_h.start(env_h.write_fifo_agent_h.write_fifo_sequencer_h);
  phase.drop_objection(this);
  endtask
endclass
`endif
