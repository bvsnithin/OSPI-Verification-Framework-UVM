
class ospi_monitor extends uvm_monitor;

  `uvm_component_utils(ospi_monitor)

  virtual ospi_if vif;
  
  // Analysis Port: This is how the monitor broadcasts what it sees to the rest of the UVM env
  uvm_analysis_port #(ospi_seq_item) item_collected_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    item_collected_port = new("item_collected_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ospi_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("MONITOR", "Could not get vif from config db")
    end
  end

  task run_phase(uvm_phase phase);
    ospi_seq_item item;
    
    forever begin

      wait(vif.mon_cb.cs_n==0);


      // Once cs_n is low, we are in a transaction!
      item = ospi_seq_item::type_id::create("item");
      item.is_write = 1; // Assuming write for now
      
      // Simple logic to capture one byte (just for this demo)
      // In a real monitor, we would loop until cs_n goes high.
      item.data = new[1]; 
      item.data[0] = vif.mon_cb.dq;
      
      // Send the item to the scoreboard
      item_collected_port.write(item);
      
      // Wait until the transaction is over (cs_n goes high)
      wait(vif.mon_cb.cs_n == 1);
    end
  endtask

endclass