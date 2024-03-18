//  AUTHOR: Sateesh Mahadev
//
//  DESCRIPTION:
//   This driver recieves the sequence item(write_fifo_seq_item) from the sequencer and 
//   takes up the responsibilty of driving the packet based on control of type_of_pkt
//   from the sequence item(write_fifo_seq_item). If the type_of_pkt=0 we frame the packet
//   with all the fields like below and drive it to fifo_interface(fintf)
//
//   Packet = {SOP (8 bits),TXN_ID (4 bits),ADDR (32 bits),LEN (4 bits),SIZE (3 bits),
//             BURST (2 bits),LOCK (2 bits),CACHE (2 bits),PROT (3 bits),STROBE (4 bits),
//             DATA (1024 bits),EOP (8 bits)};
//   
//   or if the type_of_pkt=1, we frame the read packet like below and drive it to fifo_interface(fintf)
//   with data field= 8'b00000000 as it is the identifaction of read_packet.
//
//   Packet = {SOP (8 bits),TXN_ID (4 bits),ADDR (32 bits),LEN (4 bits),SIZE (3 bits),
//             BURST (2 bits),LOCK (2 bits),CACHE (2 bits),PROT (3 bits),STROBE (4 bits),
//             DATA (8'b00000000),EOP (8 bits)};
//
//--------------------------------------------------------------------------------------------------------------
`ifndef WRITE_FIFO_DRIVER_INCLUDED_
`define WRITE_FIFO_DRIVER_INCLUDED_
//-------------------------------------------------------
//
//This class describes driver logic for write and read address packets.
//-------------------------------------------------------
class write_fifo_driver extends uvm_driver#(write_fifo_seq_item);

//-------------------------------------------------------
//
//Constructor new():
//Initializes the write_fifo_driver class object
//-------------------------------------------------------
  function new(string name="write_fifo_driver",uvm_component parent= null);
      super.new(name,parent);
  endfunction
  
  //Factory registration
  `uvm_component_utils(write_fifo_driver)

  //Handle of sequence item class 
  write_fifo_seq_item write_fifo_seq_item_h;

  //Handle of fifo interface
  virtual fifo_if fintf;

  //-------------------------------------------------------------------
  //
  //Task: run_phase
  //Waits for reset and executes write_drive_pkt or read_drive_pkt
  //based on the type_of_pkt 
  //-------------------------------------------------------------------

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    // waits for reset task to happen
    wait_for_reset();
    // object creation of write_fifo_seq_item_h handle
    write_fifo_seq_item_h=write_fifo_seq_item::type_id::create("write_fifo_seq_item");
    forever begin 
    // getting transactions from seuence item
    seq_item_port.get_next_item(write_fifo_seq_item_h);
    write_fifo_seq_item_h.print();
    // selecting the task based on type_of_pkt
    if(write_fifo_seq_item_h.type_of_pkt==0)begin
      write_drive_pkt(write_fifo_seq_item_h);
    end
    else begin
        read_drive_pkt(write_fifo_seq_item_h);
      end
    // making the wr_en to '0' after completion of any task
      @(posedge(fintf.clk));
        fintf.wr_en <=0;
        seq_item_port.item_done();
      end

  endtask

  //-------------------------------------------------------
  //
  //Function: build_phase
  //creates the objects for the handles 
  //-------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //getting the virtual interface which is set in top.sv
    uvm_config_db#(virtual fifo_if)::get(this,"","vif",fintf);
  endfunction
  
  //task for reset
  task wait_for_reset();
    @(negedge(fintf.rstn));
      fintf.wr_en <=0;
      fintf.wr_data <=0;

      @(posedge(fintf.rstn));
  endtask

  //-------------------------------------------------------
  //
  //Task:read_drive_pkt
  //Driving the read address phase packet.
  //-------------------------------------------------------
  task read_drive_pkt(write_fifo_seq_item write_fifo_seq_item_h);
    // local variable
    bit [127:0] read_pkt;

    //concatinating all the signals of sequence item into packet format
    read_pkt = {write_fifo_seq_item_h.SOP,
                write_fifo_seq_item_h.arid,
                write_fifo_seq_item_h.araddr,
                write_fifo_seq_item_h.arlen,
                write_fifo_seq_item_h.arsize,
                write_fifo_seq_item_h.arburst,
                write_fifo_seq_item_h.arlock,
                write_fifo_seq_item_h.arcache,
                write_fifo_seq_item_h.arprot,
                4'hf,
                8'h0,// identifaction of read address packet
                write_fifo_seq_item_h.EOP,
                48'h0};// adding zeros so that it should match packet size of 128.

      `uvm_info(get_type_name,"waiting for FIFO is not full in read_drive_pkt task", UVM_NONE)
      @(posedge(fintf.clk));
      wait(!(fintf.full));// checking if fifo is not full
        fintf.wr_en <=1;
        fintf.wr_data <= read_pkt;// writing the read packet to fifo interface
      `uvm_info(get_type_name,"Sent read packet", UVM_NONE) 

  endtask

  //-------------------------------------------------------
  //
  //Task: write_drive_pkt
  //Driving the write address phase packet.
  //-------------------------------------------------------
  task write_drive_pkt(write_fifo_seq_item write_fifo_seq_item_h);
    //local variables
    bit[1151:0]duplicate_eop;
    //-------------------------------------------------------
    //
    // maximum transfer of packet = 64 (awid,awadr,...... wstrb) + wdata(1024)+ EOP(8)=1096 bits in packet
    // we should send 128 bits of data,
    // (64+1024+8)/128= 8.55
    // as .55 data we will be missed if we considered 1096 so we increase 1 transfer
    // so, 128 *9 =1152 
    //-------------------------------------------------------
    bit [1151:0] total_pkt; 
    bit [1023:0]wdata; // maximum value 1024 bits
    int no_of_pkt;
    bit [7:0] q[$];// local queue
    int no_of_bits_in_queue;

        // based on the strobe value pushing bytes of wdata from location 0 to local queue
        if(write_fifo_seq_item_h.wstrb == 4'b0001)
	        q.push_back(write_fifo_seq_item_h.wdata[0][7:0]);
	      else if(write_fifo_seq_item_h.wstrb == 4'b0011)
	        begin
	          q.push_back(write_fifo_seq_item_h.wdata[0][15:8]);
	          q.push_back(write_fifo_seq_item_h.wdata[0][7:0]);
	        end
	      else if(write_fifo_seq_item_h.wstrb == 4'b0111)
	      begin
	        q.push_back(write_fifo_seq_item_h.wdata[0][23:16]);
	        q.push_back(write_fifo_seq_item_h.wdata[0][15:8]);
	        q.push_back(write_fifo_seq_item_h.wdata[0][7:0]);
	      end
	    else if(write_fifo_seq_item_h.wstrb == 4'b1111)
	      begin
	        q.push_back(write_fifo_seq_item_h.wdata[0][31:24]);
	        q.push_back(write_fifo_seq_item_h.wdata[0][23:16]);
	        q.push_back(write_fifo_seq_item_h.wdata[0][15:8]);
	        q.push_back(write_fifo_seq_item_h.wdata[0][7:0]);
	      end

  //if the wdata queue of sequence item has multiple locations
	foreach(write_fifo_seq_item_h.wdata[i])
	begin
	  if(i>0)
	   begin
	     for(int j =0; j<4;j++)
		begin
      //pushing bytes of wdata to local queue
		  q.push_back(write_fifo_seq_item_h.wdata[i][31-(8*j)-:8]);
		end
	   end
	end

        no_of_bits_in_queue = q.size()*8; //calculating no. of bits in burst
        `uvm_info(get_type_name,$sformatf(" no of bits in queue: %d",no_of_bits_in_queue), UVM_NONE) 
        
	//concatenating the elements in the wdata queue in one variable bit[1023:0]wdata
        //Ex: bit[1024:0] wdata = 0000...wdata;  000 32wdata;
	foreach(q[i]) begin
          wdata = {wdata,q[i]};
        end
      
      // shifting the wdata to the starting
      //Ex: bit[1024:0] wdata = wdata......0000;
      //To know how many times we need to shift we have to calculate no of 0's in wdata,
      //So subract 1024- no_of_bits_in_queue to know how many 0's are there and shift it to that many times.
      wdata = wdata <<  (1024-(no_of_bits_in_queue));
      //Now it looks like: bit[1024:0] wdata = wdata......0000;
     
    //concatinating all the signals of sequence item into packet format
      total_pkt = {write_fifo_seq_item_h.SOP,
                   write_fifo_seq_item_h.awid,
                   write_fifo_seq_item_h.awaddr,
                   write_fifo_seq_item_h.awlen,
                   write_fifo_seq_item_h.awsize,
                   write_fifo_seq_item_h.awburst,
                   write_fifo_seq_item_h.awlock,
                   write_fifo_seq_item_h.awcache,
                   write_fifo_seq_item_h.awprot,
                   write_fifo_seq_item_h.wstrb,
                   wdata,// maximum value is 1024
                   64'b0};// to match 1152 we need to add 64 0's

      // storing our EOP in local variable             
      duplicate_eop = write_fifo_seq_item_h.EOP;
      // our packet= aid,addr,......wstr(64 bits),wdata,......0000
      // Bit[1151:0] total_pcaket   =  constantfieds wdata 00000..000
      // Bit[1151:0] duplicate_eop =  00000000000000000...EOP...00000
      //
      duplicate_eop = duplicate_eop << 1152 - (64+no_of_bits_in_queue) - 8;
      // Bit[1151:0] total_pcaket   =  constantfieds wdata 00000..000
      //                          +
      // Bit[1151:0] duplicate_eop =  00000000000000000...EOP...00000
      // ....................................................................
      //  Bit[1151:0] total_packet    =  constantfields wdata EOP 000....000
      total_pkt = total_pkt + duplicate_eop;

     // if no_of_bits_in_queue <= 56;
       // Only 1 transfer is required as it fits into 128 bits of packet
       // packet={awid,awaddr......wstrb(64)+ wdata(56)+EOP(8)}
       // 64+56+8=128
      if(no_of_bits_in_queue<=56)begin
           `uvm_info(get_full_name(),"WAITING FOR WRITE FIFO NOT FULL WHILE DRIVING WRITE PHASE PKT OF WDATA BITS LESS THAN 56",UVM_HIGH)
            wait(!(fintf.full));
            @(posedge(fintf.clk));
            fintf.wr_en <= 1;
            fintf.wr_data <= total_pkt[1151-: 128];// writing the first packet of 128 bits to fifo interface
            `uvm_info(get_full_name(),$sformatf("Final packet driven into DUT : %h",total_pkt[1151-:128]),UVM_NONE);
      end

    else if(no_of_bits_in_queue>56)begin
      // if packet is exactly divisible by 128
      if((64 + 8 + no_of_bits_in_queue)%128==0)
        //storing quotient in no_of_pkt
        no_of_pkt = (64 + 8 + no_of_bits_in_queue)/128;
        else
      // if packet is not exactly divisible by 128, need 1 extra transfer as we get decimals so add 1
          no_of_pkt = (64 + 8 + no_of_bits_in_queue)/128 + 1;

        end
          // writing each 128 bits of packet to fifo interface based on no_of_pkt
          for(int i =0;i <no_of_pkt;i++)begin

            `uvm_info(get_type_name,"waiting for FIFO is not full in write_drive_pkt task", UVM_NONE)
            wait(!(fintf.full));// checking if fifo is not full
            @(posedge(fintf.clk));
            fintf.wr_en <= 1;// stating it as write address packet
            fintf.wr_data <= total_pkt[1151 - (128 * i)-: 128];// sending 128 bits each
            `uvm_info(get_full_name(),$sformatf("Final packet driven into DUT : %h",total_pkt[1151-(128*i)-:128]),UVM_NONE);
          end
          

  endtask

endclass
`endif
