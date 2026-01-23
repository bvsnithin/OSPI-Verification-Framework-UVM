
class ospi_test extends uvm_test;
  `uvm_component_utils(ospi_test)

  ospi_env      m_env;
  ospi_base_seq m_seq;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = ospi_env::type_id::create("m_env", this);
  end

  task run_phase(uvm_phase phase);
    // 1. Create the sequence
    m_seq = ospi_base_seq::type_id::create("m_seq");

    // 2. Raise an Objection (Stop the simulator from quitting immediately)
    phase.raise_objection(this);

    c
    
    // 3. Drop Objection (Allow simulation to finish)
    phase.drop_objection(this);
  endtask

endclass