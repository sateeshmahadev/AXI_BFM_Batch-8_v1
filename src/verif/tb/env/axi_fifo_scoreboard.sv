`ifndef AXI_FIFO_SCOREBOARD_INCLUDED_
`define AXI_FIFO_SCOREBOARD_INCLUDED_
//--------------------------------------------------------------------------------------------
// Class: axi_fifo_scoreboard 
// Description:
// The scoreboard for write txn, based on type of packet its write and read phase packets and it compares
// fifo packet as expected and axi slave signals converted to fifo seq item as actual.
//--------------------------------------------------------------------------------------------

class axi_fifo_scoreboard extends uvm_scoreboard;

   `uvm_component_utils(axi_fifo_scoreboard);
   
   write_fifo_seq_item packet_tx_fifo_agent_q[$];       //queue to collect expected write fifo packets
   write_fifo_seq_item vip_sig_to_seq_item_packet;      //write fifo seq item instance to collect axi slave signals
   write_fifo_seq_item vip_sig_to_seq_item_packet_q[$]; //queue to collect axi slave in write fifo seq item format
   //write_fifo_seq_item packet_rx_fifo_agent_q[$];     //queue to collect receive fifo packets
  
   //declaring scoreboard ports for receiving data. 
   `uvm_analysis_imp_decl(_from_tx_fifo_agent)
   uvm_analysis_imp_from_tx_fifo_agent #(write_fifo_seq_item, axi_fifo_scoreboard) from_tx_fifo_agent;
   
   //`uvm_analysis_imp_decl(_from_rx_fifo_agent)
   //uvm_analysis_imp_from_rx_fifo_agent#(read_fifo_seq_item, axi_fifo_scoreboard) from_rx_fifo_agent;
   
   `uvm_analysis_imp_decl(_avip_slave_write_add_exp)
   uvm_analysis_imp_avip_slave_write_add_exp #(axi4_slave_tx, axi_fifo_scoreboard) avip_slave_write_add_exp;
   
   `uvm_analysis_imp_decl(_avip_slave_write_data_exp)
   uvm_analysis_imp_avip_slave_write_data_exp #(axi4_slave_tx, axi_fifo_scoreboard) avip_slave_write_data_exp;
   
   `uvm_analysis_imp_decl(_avip_slave_write_res_exp)
   uvm_analysis_imp_avip_slave_write_res_exp #(axi4_slave_tx, axi_fifo_scoreboard) avip_slave_write_res_exp;
   
   `uvm_analysis_imp_decl(_avip_slave_read_add_exp)
   uvm_analysis_imp_avip_slave_read_add_exp #(axi4_slave_tx, axi_fifo_scoreboard) avip_slave_read_add_exp;
   
   `uvm_analysis_imp_decl(_avip_slave_read_data_exp)
   uvm_analysis_imp_avip_slave_read_data_exp #(axi4_slave_tx, axi_fifo_scoreboard) avip_slave_read_data_exp;
   
   //new constructor for creating ports   
   function new(string name, uvm_component parent);
     super.new(name, parent);
     from_tx_fifo_agent= new("from_tx_fifo_agent", this);
     avip_slave_write_add_exp= new("avip_slave_write_add_exp", this);
     avip_slave_write_data_exp= new("avip_slave_write_data_exp", this);
     avip_slave_write_res_exp= new("avip_slave_write_res_exp", this);
     avip_slave_read_add_exp= new("avip_slave_read_add_exp", this);
     avip_slave_read_data_exp= new("avip_slave_read_data_exp", this);
     vip_sig_to_seq_item_packet = new();
   endfunction
   
   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
   
   endfunction
  
   //write method receives write fifo seq item packet and pushes into expected queue 
   virtual function void write_from_tx_fifo_agent(write_fifo_seq_item tx_pkt);
     `uvm_info(get_type_name(), "\n********SCB Recieved pkt from tx_fifo_packet ******* ",UVM_NONE);
     tx_pkt.print();     
     packet_tx_fifo_agent_q.push_back(tx_pkt);
     `uvm_info(get_type_name(),$sformatf("SCB QUEUE Recieved pkt from tx_fifo_packet len:%h",
               packet_tx_fifo_agent_q.size()),UVM_NONE);
   endfunction
   
   //TBD
   //virtual function void write_from_rx_fifo_agent(seq_item rx_pkt);
   //`uvm_info(get_type_name(), $printf("Recieved pkt from rx_fifo_packet", UVM_HIGH))
   //rx_pkt.print();
   //write_fifo_seq_item.addr = rx_pkt.awaddr
   //actual.push_back(new_pkt);
   //check_rx_fifo_packet_event.trigger();
   //endfunction
   
   //write method receives write address info from axi slave and converts to write fifo seq item type 
   virtual function void write_avip_slave_write_add_exp(axi4_slave_tx rx_pkt);
     `uvm_info(get_type_name(),"\n******SCB Recieved pkt from SLAVE WRITE ADDR packet******",UVM_NONE);
     `uvm_info(get_type_name(), $sformatf("\nwrite addr slave packet = \n%s",rx_pkt.sprint()), UVM_NONE);
   
     //conversion of axi slave signals into a write fifo seq item type for write
     vip_sig_to_seq_item_packet.awaddr    = rx_pkt.awaddr;
     vip_sig_to_seq_item_packet.awid      = rx_pkt.awid;
     vip_sig_to_seq_item_packet.awlen     = rx_pkt.awlen;
     vip_sig_to_seq_item_packet.awsize    = rx_pkt.awsize;
     vip_sig_to_seq_item_packet.awburst   = rx_pkt.awburst;
     vip_sig_to_seq_item_packet.awlock    = rx_pkt.awlock;
     vip_sig_to_seq_item_packet.awcache   = rx_pkt.awcache;
     vip_sig_to_seq_item_packet.awprot    = rx_pkt.awprot;
   
   endfunction
   
   //write method receives write data info from axi slave and converts to write fifo seq item type 
   virtual function void write_avip_slave_write_data_exp(axi4_slave_tx rx_pkt);
     `uvm_info(get_type_name(),"\n********SCB Recieved pkt from SLAVE WRITE DATA packet*******",UVM_NONE);
     `uvm_info(get_type_name(), $sformatf("\nwrite data slave packet = \n%s",rx_pkt.sprint()), UVM_NONE);
     //received axi slave data is converted to fifo seq item 
     for(int i=0; i<rx_pkt.awlen+1;i++) begin 
        vip_sig_to_seq_item_packet.wdata[i] = rx_pkt.wdata[rx_pkt.awlen-i];
        vip_sig_to_seq_item_packet.wstrb = rx_pkt.wstrb[rx_pkt.awlen-i];
     end
     //wait for last wdata and push the packet into the queue for comparision
     if(rx_pkt.wlast==1) begin
        vip_sig_to_seq_item_packet_q.push_back(vip_sig_to_seq_item_packet);
        `uvm_info(get_type_name(),$sformatf("SCB QUEUE Recieved pkt from vip_sig_to_seq_item_packet_q (write fifo) len:%h",vip_sig_to_seq_item_packet_q.size()),UVM_NONE);
     end
   endfunction
   
   //TBD
   //write method receives write resp info from axi slave and converts to write fifo seq item type 
   virtual function void write_avip_slave_write_res_exp(axi4_slave_tx rx_pkt);
     $display("PK: SCB Recieved pkt from SLAVE WRITE RESP packet");
     $display("PK: SCB Recieved pkt from SLAVE WRITE RESP packet len:%0h,addr:%0h",rx_pkt.awlen,rx_pkt.awaddr);
     //`uvm_info(get_type_name(), $printf("SCB Recieved pkt from tx_fifo_packet", UVM_HIGH))
     //packet_tx_fifo_agent_q.push_back(tx_pkt);
     //$display("PK: SCB QUEUE Recieved pkt from tx_fifo_packet len:%h",packet_tx_fifo_agent_q.size());
   endfunction
   
   //write method receives read addr info from axi slave and converts to write fifo seq item type 
   virtual function void write_avip_slave_read_add_exp(axi4_slave_tx rx_pkt);
     `uvm_info(get_type_name(),"\n***********SCB Recieved pkt from SLAVE READ ADDR packet*********",UVM_NONE);
     `uvm_info(get_type_name(), $sformatf("\nread addr slave packet = \n%s",rx_pkt.sprint()), UVM_NONE);

     //conversion of axi slave signals into a write fifo seq item type for read address
     vip_sig_to_seq_item_packet.araddr    = rx_pkt.araddr;
     vip_sig_to_seq_item_packet.arid      = rx_pkt.arid;
     vip_sig_to_seq_item_packet.arlen     = rx_pkt.arlen;
     vip_sig_to_seq_item_packet.arsize    = rx_pkt.arsize;
     vip_sig_to_seq_item_packet.arburst   = rx_pkt.arburst;
     vip_sig_to_seq_item_packet.arlock    = rx_pkt.arlock;
     vip_sig_to_seq_item_packet.arcache   = rx_pkt.arcache;
     vip_sig_to_seq_item_packet.arprot    = rx_pkt.arprot;
     $cast(vip_sig_to_seq_item_packet.type_of_pkt,1);  //read address phase pkt

     //push the collected packet into queue for comparision
     vip_sig_to_seq_item_packet_q.push_back(vip_sig_to_seq_item_packet);
     `uvm_info(get_type_name(),$sformatf("SCB QUEUE Recieved pkt from vip_sig_to_seq_item_packet_q (read addr)len:%h",vip_sig_to_seq_item_packet_q.size()),UVM_NONE);
   endfunction
   
   //TBD
   //write method receives read data info from axi slave and converts to write fifo seq item type 
   virtual function void write_avip_slave_read_data_exp(axi4_slave_tx rx_pkt);
     `uvm_info(get_type_name(),"***********SCB Recieved pkt from SLAVE READ DATA packet*********",UVM_NONE);
     `uvm_info(get_type_name(), $sformatf("read data slave packet = \n%s",rx_pkt.sprint()), UVM_NONE);
     //`uvm_info(get_type_name(), $printf("SCB Recieved pkt from tx_fifo_packet", UVM_HIGH))
     //packet_tx_fifo_agent_q.push_back(tx_pkt);
     //$display("PK: SCB QUEUE Recieved pkt from tx_fifo_packet len:%h",packet_tx_fifo_agent_q.size());
   endfunction
  
   //run phase - compares the expected and actual seq items  
   task run_phase (uvm_phase phase);
     //wait checks for queue is filled with data
     wait(vip_sig_to_seq_item_packet_q.size() > 0);
     if (packet_tx_fifo_agent_q.size() > 0) begin
     write_fifo_seq_item exp_pkt;
     write_fifo_seq_item act_pkt;
     `uvm_info(get_type_name(),$sformatf("FIFO queue size RUN phase :%h",packet_tx_fifo_agent_q.size()),UVM_NONE);
     `uvm_info(get_type_name(),$sformatf("AXI pkt queue size RUN phase :%h",vip_sig_to_seq_item_packet_q.size()),UVM_NONE);
     //new constructor for packets
     exp_pkt = new();
     act_pkt = new();
    
     //get seq items from the queues into exp and act pkt
     exp_pkt = packet_tx_fifo_agent_q.pop_front(); 
     act_pkt = vip_sig_to_seq_item_packet_q.pop_front();
     
     `uvm_info(get_type_name(),$sformatf("TYPE OF WRITE FIFO PACKET received :%h",exp_pkt.type_of_pkt),UVM_NONE);
     `uvm_info(get_type_name(),"\n*************FIFO PKT :EXPECTED*************",UVM_NONE);
     exp_pkt.print();
     `uvm_info(get_type_name(),"\n*************AXI SLAVE to FIFO PKT: ACTUAL*************",UVM_NONE);
     act_pkt.print();

     //if (exp_pkt.awid == act_pkt.awid) begin
     // `uvm_info(get_type_name(),"AWID Pass",UVM_NONE);
     //end
     //else begin
     // `uvm_error(get_type_name(),$sformatf("AWID FAILED Exp %0h and Act %0h",exp_pkt.awid,act_pkt.awid));
     //end
   
     //the type of packet decides the received packet is write address/data or read addres phase packets
     if (exp_pkt.type_of_pkt == 0) begin
        `uvm_info(get_type_name(),"\n************* COMPR for WRITE ADDR & DATA PHASE PKT*************",UVM_NONE);
        //WRITE ADDR COMPARISION
        if (exp_pkt.awaddr == act_pkt.awaddr && exp_pkt.awid == act_pkt.awid && exp_pkt.awlen == act_pkt.awlen && exp_pkt.awsize == act_pkt.awsize && exp_pkt.awburst == act_pkt.awburst && exp_pkt.awlock == act_pkt.awlock && exp_pkt.awcache == act_pkt.awcache && exp_pkt.awprot == act_pkt.awprot ) begin
          `uvm_info(get_type_name(),"WRITE ADDR Pass : ",UVM_NONE);
          `uvm_info(get_type_name(),$sformatf("WRITE ADDR EXPECTED: awaddr:%0h,awid :%0h,awlen :%0h,awsize :%0h,awburst :%0h,awlock :%0h,awcache :%0h,awprot :%0h " , exp_pkt.awaddr,exp_pkt.awid,exp_pkt.awlen,exp_pkt.awsize,exp_pkt.awburst,exp_pkt.awlock,exp_pkt.awcache,exp_pkt.awprot),UVM_NONE);
          `uvm_info(get_type_name(),$sformatf("WRITE ADDR ACTUAL: awaddr:%0h,awid :%0h,awlen :%0h,awsize :%0h,awburst :%0h,awlock :%0h,awcache :%0h,awprot :%0h " , act_pkt.awaddr,act_pkt.awid,act_pkt.awlen,act_pkt.awsize,act_pkt.awburst,act_pkt.awlock,act_pkt.awcache,act_pkt.awprot),UVM_NONE);
        end
        else begin
          `uvm_error(get_type_name(),"WRITE ADDR FAILED : ");
          `uvm_info(get_type_name(),$sformatf("WRITE ADDR EXPECTED: awaddr:%0h,awid :%0h,awlen :%0h,awsize :%0h,awburst :%0h,awlock :%0h,awcache :%0h,awprot :%0h " , exp_pkt.awaddr,exp_pkt.awid,exp_pkt.awlen,exp_pkt.awsize,exp_pkt.awburst,exp_pkt.awlock,exp_pkt.awcache,exp_pkt.awprot),UVM_NONE);
          `uvm_info(get_type_name(),$sformatf("WRITE ADDR ACTUAL: awaddr:%0h,awid :%0h,awlen :%0h,awsize :%0h,awburst :%0h,awlock :%0h,awcache :%0h,awprot :%0h " , act_pkt.awaddr,act_pkt.awid,act_pkt.awlen,act_pkt.awsize,act_pkt.awburst,act_pkt.awlock,act_pkt.awcache,act_pkt.awprot),UVM_NONE);
        end
   
        //WRITE DATA COMPARISION
        if(exp_pkt.awlen == act_pkt.awlen) begin
          if(exp_pkt.wstrb == act_pkt.wstrb) begin
            `uvm_info(get_type_name(),$sformatf("WRITE DATA in decim form EXPECTED :  %p  ACTUAL : %p",
                      exp_pkt.wdata,act_pkt.wdata),UVM_NONE);
            //based on the size of awlen the data is compared  
            for(int i=0; i<act_pkt.awlen+1;i++) begin 
              //comparing 32 bit data in iteration   
              if (exp_pkt.wdata[i] == act_pkt.wdata[i]) begin
                  `uvm_info(get_type_name(),$sformatf("WRITE DATA PASSED -- EXPECTED[%0h] : %0h : WRITE DATA ACTUAL[%0h] : %0h",
                            i,exp_pkt.wdata[i],i,act_pkt.wdata[i]),UVM_NONE);
              end
              else begin
                  `uvm_error(get_type_name(),$sformatf("WRITE DATA FAILED -- EXPECTED[%0h] : %0h : WRITE DATA ACTUAL[%0h] : %0h",
                             i,exp_pkt.wdata[i],i,act_pkt.wdata[i]));
              end
            end
          end
          else begin
            `uvm_error(get_type_name(),$sformatf("WSTRB FAILED Exp %0h and Act %0h",exp_pkt.wstrb,act_pkt.wstrb));
          end
        end
        else begin
           `uvm_error(get_type_name(),$sformatf("AWLEN FAILED Exp %0h and Act %0h",exp_pkt.awlen,act_pkt.awlen));
        end
     end    
     else begin  //read addr phase pkt check
          `uvm_info(get_type_name(),"\n************* COMPR for READ ADDR PHASE PKT*************",UVM_NONE);

          if (exp_pkt.araddr == act_pkt.araddr && exp_pkt.arid == act_pkt.arid && exp_pkt.arlen == act_pkt.arlen && exp_pkt.arsize == act_pkt.arsize && exp_pkt.arburst == act_pkt.arburst && exp_pkt.arlock == act_pkt.arlock && exp_pkt.arcache == act_pkt.arcache && exp_pkt.arprot == act_pkt.arprot  ) begin
               `uvm_info(get_type_name(),"READ ADDR Pass : ",UVM_NONE);
               `uvm_info(get_type_name(),$sformatf("READ ADDR EXPECTED: araddr:%0h,arid :%0h,arlen :%0h,arsize :%0h,arburst :%0h,arlock :%0h,arcache :%0h,arprot :%0h " , exp_pkt.araddr,exp_pkt.arid,exp_pkt.arlen,exp_pkt.arsize,exp_pkt.arburst,exp_pkt.arlock,exp_pkt.arcache,exp_pkt.arprot),UVM_NONE);
               `uvm_info(get_type_name(),$sformatf("READ ADDR ACTUAL: araddr:%0h,arid :%0h,arlen :%0h,arsize :%0h,arburst :%0h,arlock :%0h,arcache :%0h,arprot :%0h " , act_pkt.araddr,act_pkt.arid,act_pkt.arlen,act_pkt.arsize,act_pkt.arburst,act_pkt.arlock,act_pkt.arcache,act_pkt.arprot),UVM_NONE);
          end
          else begin
               `uvm_error(get_type_name(),"READ ADDR FAILED : ");
               `uvm_info(get_type_name(),$sformatf("READ ADDR EXPECTED: araddr:%0h,arid :%0h,arlen :%0h,arsize :%0h,arburst :%0h,arlock :%0h,arcache :%0h,arprot :%0h " , exp_pkt.araddr,exp_pkt.arid,exp_pkt.arlen,exp_pkt.arsize,exp_pkt.arburst,exp_pkt.arlock,exp_pkt.arcache,exp_pkt.arprot),UVM_NONE);
               `uvm_info(get_type_name(),$sformatf("READ ADDR ACTUAL: araddr:%0h,arid :%0h,arlen :%0h,arsize :%0h,arburst :%0h,arlock :%0h,arcache :%0h,arprot :%0h " , act_pkt.araddr,act_pkt.arid,act_pkt.arlen,act_pkt.arsize,act_pkt.arburst,act_pkt.arlock,act_pkt.arcache,act_pkt.arprot),UVM_NONE);
          end
     end
 
   end  //end for if size
   endtask

//TBD
//function check_phase
//TBD
//function report_phase


endclass
`endif

