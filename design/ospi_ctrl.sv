

module ospi_ctrl (
    input logic        clk,
    input  logic       rst_n,
    // Interface signals connecting to the pins
    input  logic       cs_n,
    input  logic       sclk,
    inout  wire [7:0]  dq,
    inout  wire        dqs
);
    logic [7:0] mem [0:255];
    initial begin
        for (int i=0; i<256; i++) mem[i] = 0;
    end
    logic [7:0] data_out;
    logic       drive_bus;

    // Tri-state buffer for the Bidirectional DQ bus
    assign dq = drive_bus ? data_out : 8'bz;

    // State Machine
    typedef enum logic [2:0] {
        IDLE,
        CMD,
        ADDR,
        DATA
    } state_t;

    state_t state;
    logic [7:0] cmd;
    logic [31:0] addr;
    int byte_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            drive_bus <= 0;
            data_out  <= 0;
            byte_cnt  <= 0;
            cmd       <= 0;
            addr      <= 0;
        end 
        else begin
            if (cs_n) begin
                // Transaction ended
                state <= IDLE;
                drive_bus <= 0;
                byte_cnt <= 0;
            end 
            else begin
                case (state)
                    IDLE: begin
                        // CS_N just went low, wait for Command on next edge
                        state <= CMD;
                        drive_bus <= 0;
                        $display("[DUT] IDLE->CMD Time=%0t", $time);
                    end
                    
                    CMD: begin
                        // Capture Command from bus
                        cmd <= dq;
                        state <= ADDR;
                        byte_cnt <= 0;
                        addr <= 0;
                        $display("[DUT] CMD: Captured cmd=0x%0h Time=%0t", dq, $time);
                    end
                    
                    ADDR: begin
                        // Capture Address bytes (MSB first)
                        addr <= {addr[23:0], dq};
                        $display("[DUT] ADDR[%0d]: dq=0x%0h addr_next=0x%0h Time=%0t", byte_cnt, dq, {addr[23:0], dq}, $time);
                        
                        if (byte_cnt == 3) begin
                            // All 4 address bytes captured
                            state <= DATA;
                            byte_cnt <= 0;
                            // Pre-fetch first read byte
                            if (cmd == 8'h03) begin
                                // The full address is {addr[23:0], dq}
                                data_out <= mem[dq]; // dq contains LSB of address
                                drive_bus <= 1;
                                $display("[DUT] READ Pre-fetch: addr_lsb=0x%0h mem_val=0x%0h Time=%0t", dq, mem[dq], $time);
                            end
                        end
                        else begin
                            byte_cnt <= byte_cnt + 1;
                        end
                    end

                    DATA: begin
                        if (cmd == 8'h02) begin // WRITE (0x02)
                            mem[addr[7:0]] <= dq;
                            $display("[DUT] WRITE: mem[0x%0h]=0x%0h Time=%0t", addr[7:0], dq, $time);
                            addr <= addr + 1;
                        end
                        else if (cmd == 8'h03) begin // READ (0x03)
                            drive_bus <= 1;
                            // Prepare next byte for next cycle
                            data_out <= mem[(addr[7:0] + 1) & 8'hFF];
                            $display("[DUT] READ: addr=0x%0h data_out=0x%0h mem[addr+1]=0x%0h Time=%0t", addr[7:0], data_out, mem[(addr[7:0] + 1) & 8'hFF], $time);
                            addr <= addr + 1;
                        end
                    end
                    
                    default: state <= IDLE;
                endcase
            end
        end
    end

endmodule: ospi_ctrl