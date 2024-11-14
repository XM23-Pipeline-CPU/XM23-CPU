// THIS MODULE IS NOT USED
// This was developed to interface with the offchip SRAM on the de2-115 board
// Not used in final implementation but it could be useful to someone someday

module memory_access (
   input logic clk,
   input logic [15:0] address,
   inout logic [15:0] data,

   output logic [15:0] data_out,
   input logic [15:0] data_in,

   input logic write_enable, // read_disable

   output logic SRAM_CE_N,
   output logic SRAM_OE_N,
   output logic SRAM_WE_N,
   output logic SRAM_UB_N,
   output logic SRAM_LB_N,
   output logic [19:0] SRAM_ADDR,
   inout logic [15:0] SRAM_DQ
);
   // Internal signals
   logic data_drive;

   logic read_enable;
   assign read_enable = !write_enable;

   assign SRAM_ADDR = {4'b0000, address};

   // Bidirectional data bus control
   assign SRAM_DQ = (data_drive) ? data_in : 16'bz;

   // Control logic for SRAM
   always_ff @(posedge clk) begin
      begin
         SRAM_CE_N <= 1'b0;  // Chip enabled
         SRAM_UB_N <= 1'b0;  // Upper byte enabled
         SRAM_LB_N <= 1'b0;  // Lower byte enabled
         if (write_enable) begin
            SRAM_WE_N <= 1'b0;  // Write enabled
            SRAM_OE_N <= 1'b1;  // Output disabled
            data_drive <= 1'b1;
         end else if (read_enable) begin
            SRAM_WE_N <= 1'b1;  // Write disabled
            SRAM_OE_N <= 1'b0;  // Output enabled
            data_drive <= 1'b0;
         end
      end
   end

   // Latch the output data on read enable
   always_ff @(posedge clk) begin
      if (read_enable) begin
         data_out <= SRAM_DQ;
      end
   end
endmodule
