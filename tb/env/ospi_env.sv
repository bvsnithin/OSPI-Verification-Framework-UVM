
// tb/env/ospi_env.sv
class ospi_env extends uvm_env;
  `uvm_component_utils(ospi_env)

  
  ospi_agent m_agent;
  ospi_scoreboard m_scb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    m_agent = ospi_agent::type_id::create("m_agent",this);
    m_scb   = ospi_scoreboard::type_id::create("m_scb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    m_agent.mon.item_collected_port.connect(m_scb.item_collected_export);
  endfunction

endclass