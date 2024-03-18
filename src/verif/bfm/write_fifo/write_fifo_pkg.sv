//  AUTHOR: Sateesh Mahadev
`ifndef WRITE_FIFO_PKG_INCLUDED_
`define WRITE_FIFO_PKG_INCLUDED_

package write_fifo_pkg;
  
  //Import uvm package
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import axi4_globals_pkg::*;
  
  `include "write_fifo_seq_item.sv"
  `include "write_fifo_sequencer.sv"
  `include "write_fifo_driver.sv"
  `include "write_fifo_monitor.sv"
  `include "write_fifo_agent.sv"

  `include "base_sequence.sv"
  `include "write_fifo_sequence.sv"
  `include "fifo_bfm_wr_incr_alligned_sequence.sv"
  `include "fifo_bfm_wr_incr_unalligned_sequence.sv"


  `include "fifo_bfm_32b_rd_incr_alligned_sequence_arlen_0.sv"

  `include "fifo_bfm_32b_rd_seq.sv"
  `include "fifo_bfm_64b_rd_seq.sv"
  `include "fifo_bfm_96b_rd_seq.sv"
  `include "fifo_bfm_128b_rd_seq.sv"
  `include "fifo_bfm_160b_rd_seq.sv"
  `include "fifo_bfm_192b_rd_seq.sv"
  `include "fifo_bfm_224b_rd_seq.sv"
  `include "fifo_bfm_256b_rd_seq.sv"
  `include "fifo_bfm_288b_rd_seq.sv"
  `include "fifo_bfm_320b_rd_seq.sv"
  `include "fifo_bfm_352b_rd_seq.sv"
  `include "fifo_bfm_384b_rd_seq.sv"
  `include "fifo_bfm_416b_rd_seq.sv"
  `include "fifo_bfm_448b_rd_seq.sv"
  `include "fifo_bfm_480b_rd_seq.sv"
  `include "fifo_bfm_512b_rd_seq.sv"
  



endpackage

`endif

