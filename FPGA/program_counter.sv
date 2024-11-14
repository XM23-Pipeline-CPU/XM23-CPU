/*------------------------------------------*\
|  Program Counter - Author: Vlad Chiriac    |
|                          & Roee Omessi     |
|  Module contains logic for:                |
|     - Controlling the PC                   |
\*------------------------------------------*/

module program_counter (
   input logic        init,     // Initialization signal (set before running/uploading a program)
   input logic [15:0] PC_init,  // Read from address FFFE (7FFF in word addressing) in memory (start address from S9 record)
   input logic 		 init_clk, // Alternate clock used during initialization only

   input logic [15:0] PC_next,     // Next PC from pipeline controller fast decode
   input logic [15:0] LBPC,        // Last branch program counter to revert if needed
   input logic [15:0] LR,          // Link register for reverting on BL
   input logic        link_back,   // Signal to trigger PC <- LR   (tried to LD mem[FFFF])
   input logic        branch_fail, // Signal to trigger PC <- LBPC (last branch failed)
   input logic        clk,         // main system clock
   input logic [7:0]  stall_in,    // stall the PC (do no increment)

   output logic [15:0] true_PC = 0,   // The true PC used by the fetch
   output logic        decode_disable // Disable the decode stage when initializing
);
   wire internal_clock;
   assign internal_clock = clk | (init_clk & init);

   reg [1:0] init_state = 2;

   always_ff @(posedge internal_clock) begin
      if (init) begin
         init_state <= 2;
         true_PC <= PC_init;

      end else begin
         if (init_state > 0) begin
            init_state <= init_state - 1;
         end else begin
            if (|stall_in) begin
               // Do nothing

            end else if (branch_fail) begin
               true_PC <= LBPC;

               // Also clear pipeline

            end else if (link_back) begin
               true_PC <= LR;
               // Also clear pipeline

            end else begin
               true_PC <= PC_next;

            end
         end
      end
   end

   assign decode_disable = (|init_state);

endmodule
