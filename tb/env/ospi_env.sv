
// tb/env/ospi_env.sv
class ospi_env extends uvm_env;
  `uvm_component_utils(ospi_env)

  
  ospi_agent m_agent;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    m_agent = ospi_agent::type_id::create("m_agent",this)
  end

endclass