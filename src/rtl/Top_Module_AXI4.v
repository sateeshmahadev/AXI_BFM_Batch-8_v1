//TOP LEVEL MODULE FOR AXI4 PROJECT

module Top_Module_AXI4#(
						parameter  data_wid   = 32,
						parameter  adr_wid    = 32,
						parameter  id_wid     = 4,
						parameter  len_wid    = 4,
						parameter  siz_wid    = 3,
						parameter  bst_wid    = 2,
						parameter  loc_wid    = 2,
						parameter  cach_wid   = 2,
						parameter  prot_wid   = 3,
						parameter  strb_wid   = (data_wid/8),
						parameter  rsp_wid    = 2
								)
								
						
						( 

                //INPUT PORT DECLARATION
                 input                   clk,
                 input                   rstn,
				 input                   ACLK,
				 input                   ARESETn,
				 input                   wr_en,
                 input                   rd_en,
                 input [127:0]           wr_data,
                 input                   AWREADY_a,
                 input                   WREADY_a, 
                 input                   ARREADY_a,
                 input [id_wid-1:0]      RID_a,
                 input [data_wid-1:0]    RDATA_a,	
                 input [rsp_wid-1:0]     RRESP_a, 			
                 input                   RLAST_a, 
                 input                   RVALID_a,
				 input [id_wid-1:0]      BID_a,
                 input [rsp_wid-1:0]     BRESP_a, 			
                 input                   BVALID_a,

                 //OUTPUT PORT DECLARATION
						
                 output [id_wid-1:0]      AWID_a, 
                 output [adr_wid-1:0]     AWADDR_a,
                 output [len_wid-1:0]     AWLEN_a, 				
                 output [siz_wid-1:0]     AWSIZE_a,
                 output [bst_wid-1:0]     AWBURST_a, 
                 output [loc_wid-1:0]     AWLOCK_a, 
                 output [cach_wid-1:0]    AWCACHE_a,
                 output [prot_wid-1:0]    AWPROT_a, 
                 output                   AWVALID_a,
                 output [id_wid-1:0]      ARID_a,
                 output [adr_wid-1:0]     ARADDR_a,
                 output [len_wid-1:0]     ARLEN_a, 				
                 output [siz_wid-1:0]     ARSIZE_a,
                 output [bst_wid-1:0]     ARBURST_a, 
                 output [loc_wid-1:0]     ARLOCK_a,
                 output [cach_wid-1:0]    ARCACHE_a,
                 output [prot_wid-1:0]    ARPROT_a, 
                 output                   ARVALID_a,				 
                 output [id_wid-1:0]      WID_a,
                 output [data_wid-1:0]    WDATA_a, 
                 output [strb_wid-1:0]    WSTRB_a, 
                 output                   WLAST_a,  
                 output                   WVALID_a, 
                 output                   RREADY_a,
				 output                   BREADY_a,
				 output [127:0]           rd_data,    	
				 output                   full,
                 output                   empty
				 ); 
				 
                 //SIGNAL FOR FIFO-DECODER
				 wire          FIFO_EMPTY;
                 wire          FIFO_FULL;
                 wire          WRITE_ENABLE; 				 
                 wire  [127:0] WRITE_DATA; 
                 wire          READ_ENABLE;
				 wire  [127:0] READ_DATA;
				 
				 //SIGNAL FOR DECODER-AXI4 MASTER
				 wire                    wr_trn_en;			  
				 wire                    rd_trn_en;
				 wire                    wr_rsp_en;			  
				 wire                    rd_rsp_en;
				 wire  [adr_wid-1:0]     awaddr; 
                 wire  [(id_wid)-1:0]    txn_id_w;				 
                 wire  [bst_wid-1:0]     awburst;
				 wire  [siz_wid-1:0]     awsize;
				 wire  [(len_wid)-1:0]   awlen;
				 wire  [loc_wid-1:0]     awlock;
				 wire  [cach_wid-1:0]    awcache;
				 wire  [prot_wid-1:0]    awprot;
				 wire  [adr_wid-1:0]     araddr;
                 wire  [(id_wid)-1:0]    txn_id_r;		 
				 wire  [(len_wid)-1:0]   arlen;
				 wire  [bst_wid-1:0]     arburst;          
				 wire  [siz_wid-1:0]     arsize;
				 wire  [loc_wid-1:0]     arlock;
				 wire  [cach_wid-1:0]    arcache;
				 wire  [prot_wid-1:0]    arprot;
				 wire  [data_wid-1:0]    wdata; 
                 wire  [strb_wid-1:0]    wstrb;				 				
				 wire  [data_wid-1:0]    rdata; 
				 wire  [(id_wid)-1:0]    rid;
				 wire  [rsp_wid-1:0]     rresp;
                 wire                    rlast;				 
				 wire  [rsp_wid-1:0]     bresp;
				 wire  [id_wid-1:0]      bid;
                 wire                    write_data;
				 wire                    wvalid_d;

				 
// INSTANTIATION OF WRITE FIFO 
design_fifo DUT_FIFO (
						.clk          (clk),
						.rst          (rstn),
						.wr_en        (wr_en),
					    .wr_data      (wr_data),
					    .full         (full),							
					    .FIFO_EMPTY   (FIFO_EMPTY),
					    .READ_DATA    (READ_DATA),
					    .READ_ENABLE  (READ_ENABLE),
				        .rd_en        (rd_en),
				        .rd_data      (rd_data),
				        .empty        (empty),								
				        .FIFO_FULL    (FIFO_FULL),
				        .WRITE_ENABLE (WRITE_ENABLE),
				        .WRITE_DATA   (WRITE_DATA)
				    );
				   

//INSTANTIATION OF DECODER
my_decoder decoder (
                    .clk          (clk),
                    .rst_n        (rstn),										
                    .fifo_empty   (FIFO_EMPTY),
                    .fifo_full    (FIFO_FULL),
                    .fifo_rdata   (READ_DATA),
            	    .read_enable  (READ_ENABLE),
					.fifo_wdata   (WRITE_DATA),	
	                .write_enable (WRITE_ENABLE),					                    
		            .write_data   (write_data),								  
				    .bresp        (bresp),
                    .bid          (bid),
					.rid          (rid),
                    .rdata        (rdata),
                    .rresp        (rresp),
					.rlast        (rlast),
                    .wr_rsp_en    (wr_rsp_en),
		            .rd_rsp_en    (rd_rsp_en),
                    .awaddr       (awaddr),
                    .txn_id_w     (txn_id_w),
                    .awburst      (awburst),
                    .awlen        (awlen),
                    .awsize       (awsize),
                    .awlock       (awlock),
                    .awcache      (awcache),
                    .awprot       (awprot),
                    .wdata        (wdata),
                    .wstrb        (wstrb),
                    .wvalid       (wvalid_d),					
                    .araddr       (araddr),
                    .txn_id_r     (txn_id_r),
                    .arburst      (arburst),
		            .arlen        (arlen),
		            .arsize       (arsize),  
		            .arlock       (arlock),
                    .arcache      (arcache),
                    .arprot       (arprot),
		            .wr_trn_en    (wr_trn_en),
		            .rd_trn_en    (rd_trn_en)                            
		   );
				   
// INSTANTIATION OF AXI_MASTER
AXI_Master      #(.addr_width(32), .data_width(64))
						
						DUT_axi (
								
                    .AClk         (ACLK),
                    .ARstn        (ARESETn),
					
                    .AWID         (AWID_a),
                    .AWADDR       (AWADDR_a),
                    .AWLEN        (AWLEN_a),
                    .AWSIZE       (AWSIZE_a),
                    .AWBURST      (AWBURST_a),
                    .AWVALID      (AWVALID_a),
                    .AWREADY      (AWREADY_a),
                    .AWLOCK       (AWLOCK_a),
                    .AWCACHE      (AWCACHE_a),
                    .AWPROT       (AWPROT_a), 
					
                    .WID          (WID_a),   
                    .WSTRB        (WSTRB_a),
                    .WDATA        (WDATA_a),
                    .WLAST        (WLAST_a),
                    .WVALID       (WVALID_a),
                    .WREADY       (WREADY_a),
					
                    .BID          (BID_a),
                    .BRESP        (BRESP_a),
                    .BVALID       (BVALID_a),
                    .BREADY       (BREADY_a),
                    
                    .ARID         (ARID_a),
                    .ARADDR       (ARADDR_a),
                    .ARLEN        (ARLEN_a),
                    .ARSIZE       (ARSIZE_a),
                    .ARBURST      (ARBURST_a),
                    .ARVALID      (ARVALID_a),
                    .ARLOCK       (ARLOCK_a),
                    .ARCACHE      (ARCACHE_a),
                    .ARPROT       (ARPROT_a),
                    .ARREADY      (ARREADY_a), 
					
                    .RID          (RID_a),
                    .RDATA        (RDATA_a),
                    .RRESP        (RRESP_a),
                    .RLAST        (RLAST_a),
                    .RVALID       (RVALID_a),
                    .RREADY       (RREADY_a), 
					
                    .TXN_ID_W_d   (txn_id_w),
                    .awaddr_d     (awaddr),
                    .awlen_d      (awlen),
                    .awsize_d     (awsize),
                    .awburst_d    (awburst),
                    .awlock_d     (awlock),
                    .awcache_d    (awcache),
                    .awprot_d     (awprot),
					
                    .wdata_d      (wdata),
                    .wstrb_d      (wstrb),
					.wvalid_d     (wvalid_d),
					
                    .bresp_d      (bresp),
                    .bid_d        (bid),
                    .wr_rsp_en_d  (wr_rsp_en),
                    .wr_trn_en    (wr_trn_en), 
					
                    .TXN_ID_R_d   (txn_id_r),
                    .araddr_d     (araddr),
                    .arlen_d      (arlen),
                    .arsize_d     (arsize),
                    .arburst_d    (arburst),
                    .arlock_d     (arlock),
                    .arcache_d    (arcache),
                    .arprot_d     (arprot),
					
                    .rdata_d      (rdata),
                    .rresp_d      (rresp),
                    .rid_d        (rid),
                    .rd_rsp_en_d  (rd_rsp_en),
					.r_last_d	  (rlast),
                    .rd_trn_en    (rd_trn_en)
						  
                            
                 );
					  
					  
					  
endmodule
				 
                 				   
				 
				 
				 
				 
