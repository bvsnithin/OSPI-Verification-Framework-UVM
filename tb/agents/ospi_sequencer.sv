
class ospi_sequencer extends uvm_sequencer #(ospi_seq_item);
  `uvm_component_utils(ospi_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass