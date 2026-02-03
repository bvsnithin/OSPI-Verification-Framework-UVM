
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
    // Initialize signals to idle state BEFORE reset releases
    vif.drv_cb.cs_n <= 1;  // CS_N inactive (high)
    vif.drv_cb.dq <= 'z;   // Bus hi-Z
    
    // Wait for Reset Release
    wait(vif.rst_n === 1);
    
    // Wait one more clock to ensure DUT is out of reset
    @(vif.drv_cb);
    
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

    // B. Activate Chip Select (Active Low) - DUT enters IDLE, then CMD on next edge
    vif.drv_cb.cs_n <= 0;
    @(vif.drv_cb);

    // --- Command Phase ---
    // DUT is in CMD state, capture command
    // 0x02 for Write, 0x03 for Read
    vif.drv_cb.dq <= item.is_write ? 8'h02 : 8'h03;
    @(vif.drv_cb);

    // --- Address Phase (32-bit, 4 bytes) ---
    // DUT is in ADDR state
    vif.drv_cb.dq <= item.addr[31:24];
    @(vif.drv_cb);
    vif.drv_cb.dq <= item.addr[23:16];
    @(vif.drv_cb);
    vif.drv_cb.dq <= item.addr[15:8];
    @(vif.drv_cb);
    vif.drv_cb.dq <= item.addr[7:0];
    @(vif.drv_cb);

    // --- Data Phase ---
    // DUT is in DATA state
    if (item.is_write) begin
       // Write Operation: Drive data onto the bus
       foreach (item.data[i]) begin
          vif.drv_cb.dq <= item.data[i];
          @(vif.drv_cb); 
       end
    end
    else begin
       // Read Operation: Release bus and wait
       vif.drv_cb.dq <= 'z; // Release bus
       // Wait for each data byte from DUT
       foreach (item.data[i]) begin
           @(vif.drv_cb);
       end
    end

    // E. De-activate Chip Select (Return to High)
    vif.drv_cb.cs_n <= 1;
    
  endtask

endclass