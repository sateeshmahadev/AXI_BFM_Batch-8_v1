`ifndef FIFO_BFM_16B_WR_INCR_UNALLIGNED_TEST_AWLEN_1_INCLUDED_
`define FIFO_BFM_16B_WR_INCR_UNALLIGNED_TEST_AWLEN_1_INCLUDED_

class fifo_bfm_16b_wr_incr_unalligned_test_awlen_1 extends fifo_base_test;
  `uvm_component_utils(fifo_bfm_16b_wr_incr_unalligned_test_awlen_1)
  bit[31:0] wdata_seq[$];
  bit[3:0] awlenn =1;
  bit [31:0] addr;//=$urandom;
  bit[3:0] wstrbb=4'b0011;
  bit[1:0] awburstt = 1;
  bit[2:0] awsizee = 2;

  fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1 fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1_h;
  axi4_slave_nbk_write_32b_transfer_seq axi4_slave_nbk_write_32b_transfer_seq_h;

  function new(string name = "fifo_bfm_16b_wr_incr_unalligned_test_awlen_1",uvm_component parent = null);
    super.new(name, parent);
    void'(std::randomize(addr) with {addr%((2**awsizee)*8)==0;});
    $display("address in sequence=%h",addr);
    void'(std::randomize(wdata_seq) with {wdata_seq.size()==awlenn+1;});
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    axi4_slave_nbk_write_32b_transfer_seq_h = axi4_slave_nbk_write_32b_transfer_seq::type_id::create("axi4_slave_nbk_read_64b_transfer_seq_h");
    fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1_h=fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1::type_id::create("fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1_h");
  endfunction

  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(),$sformatf("fifo_bfm_16b_wr_incr_unalligned_test_awlen_1"),UVM_LOW)

    phase.raise_objection(this);
     // fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1_h.awlen=1;
      fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1_h.awlenn=awlenn;
      fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1_h.addr=addr;
      fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1_h.wstrbb=wstrbb;
      fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1_h.awburstt=awburstt;
      fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1_h.awsizee=awsizee;
      fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1_h.wdata_seq=wdata_seq;

      fork
        begin
          forever begin
            axi4_slave_nbk_write_32b_transfer_seq_h.start(env_h.axi_slave_agent_h.axi4_slave_write_seqr_h);
        end
      end
    join_none

    fifo_bfm_16b_wr_incr_unalligned_sequence_awlen_1_h.start(env_h.write_fifo_agent_h.write_fifo_sequencer_h);
  phase.drop_objection(this);
  endtask
endclass
`endif
