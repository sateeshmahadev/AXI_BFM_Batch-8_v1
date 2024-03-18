`ifndef AXI4_COV_SUBSCRIBER_INCLUDED_
`define AXI4_COV_SUBSCRIBER_INCLUDED_

//--------------------------------------------------------------------------------------------
// Class: axi_cov_subscriber
// axi_cov_subscriber determines the how much code is covered for better functionality of the TB.
//--------------------------------------------------------------------------------------------

class axi_cov_subscriber extends uvm_subscriber#(write_fifo_seq_item);
  `uvm_component_utils(axi_cov_subscriber)

  //-------------------------------------------------------
  // Covergroup: axi_bfm_covergroup
  // Covergroup consists of the various coverpoints based on
  // no. of the variables used to improve the coverage.
  //-------------------------------------------------------
  covergroup axi_bfm_covergroup with function sample (write_fifo_seq_item packet);
    option.per_instance = 1;
    
    //-------------------------------------------------------
    // Write channel signals 
    //-------------------------------------------------------

    AWLEN_CP : coverpoint packet.awlen {
      option.comment = "Write Address Length values";
      bins AWLEN_1   = {0};
      bins AWLEN_2   = {1};
      bins AWLEN_4   = {3};
      bins AWLEN_8   = {7};
      bins AWLEN_16  = {15};
      bins AWLEN_32  = {31};
      bins AWLEN_64  = {63};
      bins AWLEN_128 = {127};
      bins AWLEN_256 = {255};
      bins AWLEN_DEFAULT = default ;
    }

    AWBURST_CP : coverpoint packet.awburst {
      option.comment = "Write Address Burst values";
      bins READ_FIXED = {0};
      bins WRITE_INCR = {1}; 
      //bins READ_WRAP  = {2};    
      illegal_bins ILLEGAL_BIN_OF_AWBURST = {3};  
    }

    AWSIZE_CP : coverpoint packet.awsize {
      option.comment = "Write Address size values";
      //bins AWSIZE_1BYTE    = {0};
      //bins AWSIZE_2BYTES   = {1};
       bins AWSIZE_4BYTES   = {2};
      //bins AWSIZE_8BYTES   = {3};
      //bins AWSIZE_16BYTES  = {4};
      //bins AWSIZE_32BYTES  = {5};
      //bins AWSIZE_64BYTES  = {6};
      //bins AWSIZE_128BYTES = {7};
    }

    AWLOCK_CP :coverpoint packet.awlock {
      option.comment = "Write Address Lock values";
      bins AWLOCK[] = {0,1};
    }

    AWCACHE_CP : coverpoint packet.awcache {
      option.comment = "Write Address Cache values";
      bins WRITE_BUFFERABLE = {[0:3]};
      //bins WRITE_MODIFIABLE = {1};
      //bins WRITE_OTHER_ALLOCATE = {2}; 
      //bins WRITE_ALLOCATE   = {3};
    }

    AWPROT_CP : coverpoint packet.awprot {
      option.comment = "Write Address Protection values";
      bins AWPROT = {[0:$]};
    }

    AWID_CP : coverpoint packet.awid {
      option.comment = "Write Address ID values";
      bins AWID[] = {[0:$]};
    }

    //-------------------------------------------------------
    // Read channel signals 
    //-------------------------------------------------------

    ARLEN_CP : coverpoint packet.arlen {
      option.comment = "Read Address Length values";
      bins ARLEN_1   = {0};
      bins ARLEN_2   = {1};
      bins ARLEN_4   = {3};
      bins ARLEN_8   = {7};
      bins ARLEN_16  = {15};
      bins ARLEN_32  = {31};
      bins ARLEN_64  = {63};
      bins ARLEN_128 = {127};
      bins ARLEN_256 = {255};
      bins ARLEN_DEFAULT = default ;
    }


    ARBURST_CP : coverpoint packet.arburst {
      option.comment = "Read Address Burst values";
      bins READ_FIXED = {0};
      bins WRITE_INCR = {1}; 
      //bins READ_WRAP  = {2};   
      illegal_bins ILLEGAL_BIN_OF_ARBURST = {3};     
    }

    ARSIZE_CP : coverpoint packet.arsize {
      option.comment = "Read Address Size values";
      //bins ARSIZE_1BYTE    = {0};
      //bins ARSIZE_2BYTES   = {1};
      bins ARSIZE_4BYTES   = {2};
      //bins ARSIZE_8BYTES   = {3};
      //bins ARSIZE_16BYTES  = {4};
      //bins ARSIZE_32BYTES  = {5};
      //bins ARSIZE_64BYTES  = {6};
      //bins ARSIZE_128BYTES = {7};
    }

    ARLOCK_CP :coverpoint packet.arlock {
      option.comment= "Read Address Lock values";
      bins ARLOCK = {0,1};
    }

    ARCACHE_CP : coverpoint packet.arcache {
      option.comment = "Read Address Cache values";
      bins READ_BUFFERABLE      = {[0:3]};
      //bins READ_MODIFIABLE      = {1};
      //bins READ_OTHER_ALLOCATE  = {2}; 
      //bins READ_ALLOCATE        = {3};
    }

    ARPROT_CP : coverpoint packet.arprot {
      option.comment = "Read Address Protection values";
      bins ARPROT = {[0:$]};
    }

    //-------------------------------------------------------
    // Cross of coverpoints
    //-------------------------------------------------------

    AWLENGTH_CP_X_AWSIZE_X_AWBURST    :cross AWLEN_CP,AWSIZE_CP,AWBURST_CP;
    ARLENGTH_CP_X_ARSIZE_X_ARBURST    :cross ARLEN_CP,ARSIZE_CP,ARBURST_CP;


  endgroup: axi_bfm_covergroup
  
  //-------------------------------------------------------
  // Externally defined Tasks and Functions
  //-------------------------------------------------------
  extern function new(string name = "axi_cov_subscriber", uvm_component parent = null);
  extern virtual function void write(write_fifo_seq_item t);
  extern virtual function void report_phase(uvm_phase phase);
   
endclass :axi_cov_subscriber

//--------------------------------------------------------------------------------------------
// Construct: new
//
// Parameters:
//  name - axi_cov_subscriber
//  parent - parent under which this component is created
//--------------------------------------------------------------------------------------------
function axi_cov_subscriber::new(string name = "axi_cov_subscriber",uvm_component parent = null);
  super.new(name, parent);
  axi_bfm_covergroup =new();
endfunction : new

//--------------------------------------------------------------------------------------------
// Function: write
// sampling is done
//--------------------------------------------------------------------------------------------
function void axi_cov_subscriber::write(write_fifo_seq_item t);
 `uvm_info(get_type_name(),$sformatf("Before calling SAMPLE METHOD"),UVM_NONE);

  axi_bfm_covergroup.sample(t);

  `uvm_info(get_type_name(),"After calling SAMPLE METHOD",UVM_NONE);

endfunction: write

//--------------------------------------------------------------------------------------------
// Function: report_phase
// Used for reporting the coverage instance percentage values
//--------------------------------------------------------------------------------------------
function void axi_cov_subscriber::report_phase(uvm_phase phase);
  `uvm_info(get_type_name(),$sformatf("AXI4 BFM Coverage = %0.2f %%", axi_bfm_covergroup.get_coverage()), UVM_NONE);
endfunction: report_phase

`endif

