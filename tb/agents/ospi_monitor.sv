class ospi_monitor extends uvm_monitor;
  `uvm_component_utils(ospi_monitor)

  virtual ospi_if vif;
  uvm_analysis_port #(ospi_seq_item) item_collected_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ospi_if)::get(this, "", "vif", vif))
       `uvm_fatal("MON", "Could not get vif")
  endfunction

  task run_phase(uvm_phase phase);
    ospi_seq_item item;
    logic [7:0] captured_data[$];
    logic [7:0] cmd;
    
    forever begin
      // 1. Wait for Start of Transaction (CS_N goes low)
      @(vif.mon_cb iff vif.mon_cb.cs_n == 0);
      
      item = ospi_seq_item::type_id::create("item");
      
      // 2. Wait for Command Phase (DUT is in CMD state on next cycle)
      @(vif.mon_cb);
      cmd = vif.mon_cb.dq;
      item.is_write = (cmd == 8'h02);
      
      // 3. Sample Address (4 bytes - DUT is in ADDR state)
      repeat(4) begin
         @(vif.mon_cb);
         item.addr = {item.addr[23:0], vif.mon_cb.dq};
      end
      
      // 4. Sample Data Phase
      captured_data.delete();
      
      forever begin
          @(vif.mon_cb);
          if (vif.mon_cb.cs_n == 1) break; // Transaction Ended
          captured_data.push_back(vif.mon_cb.dq);
      end

      
      // Copy data to item
      item.data = new[captured_data.size()];
      foreach(captured_data[i]) item.data[i] = captured_data[i];
      
      // Publish
      item_collected_port.write(item);
      `uvm_info("MON", $sformatf("Captured Transaction: Type=%s Addr=0x%0h Size=%0d", 
                item.is_write ? "WRITE" : "READ", item.addr, item.data.size()), UVM_LOW)
    end
  endtask

endclass