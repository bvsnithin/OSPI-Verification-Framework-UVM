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
    forever begin
      @(posedge vif.sclk); // Simple clock wait to satisfy syntax
      // Monitor logic here
    end
  endtask

endclass