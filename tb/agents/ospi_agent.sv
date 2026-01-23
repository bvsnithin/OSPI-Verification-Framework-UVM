
class ospi_agent extends uvm_agent;
  `uvm_component_utils(ospi_agent)

  // Declare handles for the components we built
  ospi_driver    drv;
  ospi_monitor   mon;
  ospi_sequencer sqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase: Create the components
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    mon = ospi_monitor::type_id::create("mon", this);

    // Agents can be "Active" (Driving signals) or "Passive" (Just watching).
    // If Active, we need a Driver and Sequencer.
    if (get_is_active() == UVM_ACTIVE) begin
      drv = ospi_driver::type_id::create("drv", this);
      sqr = ospi_sequencer::type_id::create("sqr", this);
    end
  end

  // Connect Phase: Hook things together
  function void connect_phase(uvm_phase phase);
    if (get_is_active() == UVM_ACTIVE) begin
      
      drv.seq_item_port.connect(sqr.seq_item_export);
      
    end
  end

endclass