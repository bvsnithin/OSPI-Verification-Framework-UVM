
class ospi_base_seq extends uvm_sequence #(ospi_seq_item);
  `uvm_object_utils(ospi_base_seq)

  function new(string name = "ospi_base_seq");
    super.new(name);
  endfunction

  // The body task is where the sequence execution happens
  task body();
    // 'req' is a built-in handle in uvm_sequence for the transaction
    req = ospi_seq_item::type_id::create("req");

    repeat(5) begin // Let's send 5 transactions
      // 1. Handshake Start
      start_item(req);

      // 2. Randomize (Check for success)
      if (!req.randomize()) begin
        `uvm_error("SEQ", "Randomization failed!")
      end

      // 3. Handshake End (Send it!)
      // This must happen for the driver to get the data
      finish_item(req);
    end
  endtask

endclass