interface ospi_if (input logic clk, input logic rst_n);

    //OSPI Physical Signals
    logic      cs_n;  // Chip Select (Active low)
    logic      sclk;  // Serial Clock
    wire       dqs;   // Data Strobe (for high speed data capture)
    wire[7:0] dq;    // Bidirectional Data Bus (Octal == 8 lines)

    // Clocking block for the Driver (drives inputs to DUT)
    // We use clocking blocks to avoid race conditions in simulation
    clocking drv_cb @(posedge clk);
        default input #1step output #1ns;
        output cs_n;
        output sclk;
        inout  dq;
        inout  dqs;
    endclocking

    // Clocking block for the Monitor (samples outputs from DUT)
    clocking mon_cb @(posedge clk);
        default input #1step output #1ns;
        input cs_n;
        input sclk;
        input dq;
        input dqs;
    endclocking


endinterface