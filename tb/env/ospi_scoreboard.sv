class ospi_scoreboard extends uvm_scoreboard;
   `uvm_component_utils(ospi_scoreboard)

   uvm_analysis_imp #(ospi_seq_item, ospi_scoreboard) item_collected_export;
   
   logic [7:0] scb_mem [int]; // Associative array for memory
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
      item_collected_export = new("item_collected_export", this);
   endfunction
   
   function void write(ospi_seq_item item);
      if (item.is_write) begin
         `uvm_info("SCB", $sformatf("WRITE Operation: Addr=0x%0h Size=%0d", item.addr, item.data.size()), UVM_LOW)
         foreach(item.data[i]) begin
             scb_mem[item.addr + i] = item.data[i];
         end
      end
      else begin
         `uvm_info("SCB", $sformatf("READ Operation: Addr=0x%0h Size=%0d", item.addr, item.data.size()), UVM_LOW)
         foreach(item.data[i]) begin
             logic [7:0] expected = 0;
             if (scb_mem.exists(item.addr + i))
                 expected = scb_mem[item.addr + i];
             
             if (item.data[i] !== expected) begin
                 `uvm_error("SCB", $sformatf("Data Mismatch! Addr=0x%0h Exp=0x%0h Act=0x%0h", item.addr+i, expected, item.data[i]))
             end else begin
                 `uvm_info("SCB", $sformatf("Data Match! Addr=0x%0h Data=0x%0h", item.addr+i, item.data[i]), UVM_LOW)
             end
         end
      end
   endfunction
endclass
