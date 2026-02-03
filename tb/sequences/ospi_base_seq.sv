
class ospi_base_seq extends uvm_sequence #(ospi_seq_item);
  `uvm_object_utils(ospi_base_seq)

  function new(string name = "ospi_base_seq");
    super.new(name);
  endfunction

  // The body task is where the sequence execution happens
  task body();
    // 'req' is a built-in handle in uvm_sequence for the transaction
    req = ospi_seq_item::type_id::create("req");

    // Directed Test: Write then Read
    // Write 4 bytes to Address 0x10
    start_item(req);
    assert(req.randomize() with { addr == 32'h10; is_write == 1; data.size() == 4; });
    finish_item(req);

    // Read 4 bytes from Address 0x10
    // Note: The driver will handle the read phase.
    start_item(req);
    assert(req.randomize() with { addr == 32'h10; is_write == 0; data.size() == 4; });
    finish_item(req);

    repeat(20) begin 
      // 1. Handshake Start
      start_item(req);

      // 2. Randomize (Check for success)
      // Constrain address to valid range [0:255] and size [1:8]
      if (!req.randomize() with { addr inside {[0:255]}; data.size() inside {[1:8]}; }) begin
        `uvm_error("SEQ", "Randomization failed!")
      end

      // 3. Handshake End (Send it!)
      finish_item(req);
    end
  endtask

endclass