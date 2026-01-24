package ospi_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // 1. DATA OBJECTS (Must be first!)
  `include "agents/ospi_seq_item.sv"

  // 2. COMPONENTS (depend on seq_item)
  `include "agents/ospi_sequencer.sv"
  `include "agents/ospi_driver.sv"
  `include "agents/ospi_monitor.sv"
  `include "agents/ospi_agent.sv"

  // 3. ENVIRONMENT (depends on agent)
  `include "env/ospi_env.sv"

  // 4. SEQUENCES (depend on seq_item)
  `include "sequences/ospi_base_seq.sv"

  // 5. TEST (depends on env and sequences)
  `include "tests/test.sv"

endpackage