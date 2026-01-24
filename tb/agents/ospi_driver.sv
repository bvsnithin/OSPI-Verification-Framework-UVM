
class ospi_driver extends uvm_driver #(ospi_seq_item);
  `uvm_component_utils(ospi_driver)

  // Virtual Interface Handle
  virtual ospi_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase: Get the interface handle from the Configuration Database
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ospi_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("DRIVER", "Could not get vif from config db")
    end
  endfunction

  // Run Phase: The main loop
  task run_phase(uvm_phase phase);
    forever begin

      // 1. Get the next item from the sequencer
      seq_item_port.get_next_item(req);

      // 2. Drive the transaction
      drive_item(req);

      // 3. Tell the sequencer we are done
      seq_item_port.item_done();

    end
  endtask

  task drive_item(ospi_seq_item item);

    // A. Wait for a positive edge of the clock (synchronize)
    @(vif.drv_cb);

    // B. Activate Chip Select (Active Low)
    vif.drv_cb.cs_n <= 0;

    // C. Check if this is a WRITE operation
    if (item.is_write) begin
       // D. Loop through the data array inside the item
       foreach (item.data[i]) begin

          // Drive the data onto the bus
          vif.drv_cb.dq <= item.data[i];
          // Wait for a clock cycle to maintain timing
          @(vif.drv_cb); 
       end
    end
    else begin
       // READ Operation (We will handle this later, leave empty for now)
    end

    // E. De-activate Chip Select (Return to High)
    vif.drv_cb.cs_n <=1;
    
  endtask

endclass