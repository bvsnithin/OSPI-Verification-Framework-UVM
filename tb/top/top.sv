module top;
  import uvm_pkg::*;
  import ospi_pkg::*;

  // 1. Clock and Reset Generation
  logic clk;
  logic rst_n;

  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz Clock
  end

  initial begin
    rst_n = 0;
    #20 rst_n = 1;
  end

  // 2. Interface Instance
  // We instantiate the interface we created in Step 1
  ospi_if vif(clk, rst_n);


  ospi_ctrl u_dut (
    .clk   (clk),
    .rst_n (rst_n),
    .cs_n  (vif.cs_n),
    .sclk  (vif.sclk),
    .dq    (vif.dq),
    .dqs   (vif.dqs)
  );

  // 3. UVM Startup
  initial begin
    // Store the interface handle in the database so the Driver/Monitor can grab it
    // "null" = global scope, "*" = visible to everyone, "vif" = key name
    uvm_config_db#(virtual ospi_if)::set(null, "*", "vif", vif);

    // Run the test named "ospi_test"
    run_test("ospi_test");
  end

endmodule