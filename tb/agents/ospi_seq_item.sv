class ospi_seq_item extends uvm_sequence_item;
  
  rand bit [31:0] addr;
  rand bit [7:0] data[];  // 8-bit data to match OSPI bus width
  rand bit        is_write;

  `uvm_object_utils_begin(ospi_seq_item)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_array_int(data, UVM_ALL_ON) 
    `uvm_field_int(is_write, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "ospi_seq_item");
    super.new(name);
  endfunction

endclass 