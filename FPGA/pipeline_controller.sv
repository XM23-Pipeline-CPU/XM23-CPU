/*---------------------------------------------*\
|  Pipeline Controller - Author: Vlad Chiriac   |
|                              & Roee Omessi    |
|  Module contains logic for:                   |
|     - Simple branch prediction                |
|     - RAW hazard prevention                   |
\*---------------------------------------------*/

module pipeline_controller (

   // RAW hazard prevention IO ----------------------------------------------

   // This is the async input
   // from the decode block of the CPU.

   input logic [7:0] async_set_from_decode,	// set dependancy
   input logic [7:0] async_dep_from_decode,	// is dependant

   // The inputs above will be used to
   // set the dependencies in the stage
   // memory (like a D-flip-flop chain).
   // There will be outputs for these memories
   // for debugging/visualization software.
   //  _________	___  ___
   //  |Dec (2)|->|3|->|4| Stage memory
   //  ¯¯¯¯¯¯¯¯¯  ¯^¯  ¯^¯
   //              |    |
   //   Clk--------*----*

   input logic clk,

   // If either corresponding stage 3 or 4 dependancy
   // exists and the decode has the dependancy, stall.

   output logic [7:0] stall,

   //------------------------------------------------------------------------

   // Simple branch prediction IO -------------------------------------------

   input logic [2:0] three_msb, 		// test leading 3 bits 0b000 | 0b001
   input logic [12:0] thirteen_lsb,	// to get offset from bits 0-12
   input logic signed [15:0] PC_in,
   input logic PSW_in,
   output logic [15:0] PC_next,
   output logic [15:0] LBPC,			// PC to revert if needed (at exec)
   output logic [15:0] LBPC_LR,		// PC to revert if needed (at exec) only for LR
   output logic [15:0] LBPSW			// PSW to revert if needed (at exec)

   //------------------------------------------------------------------------

);
   // RAW hazard prevention Impl --------------------------------------------

   // Test for dependancies in stage 3 or 4
   // Stall if dependancy exists and decode block (stage 2) is dependant

   logic [7:0] stage_3_dep = 0;
   logic [7:0] stage_4_dep = 0;
   logic [7:0] stage_3_or_4;
   assign stage_3_or_4 = stage_3_dep | stage_4_dep;
   assign stall = stage_3_or_4 & async_dep_from_decode;

   // Propagate dependancies into memory when appropriate
   // (conditional logic on stage 2->3)

   always_ff @(posedge clk) begin
      stage_4_dep <= stage_3_dep;
      stage_3_dep <= 	~(async_dep_from_decode & stall)
                        & async_set_from_decode;
   end

   //------------------------------------------------------------------------

   // Simple branch prediction Impl -----------------------------------------

   logic signed [15:0] extended_13;
   logic signed [15:0] extended_9;
   logic [15:0] LBPC1;	// We need two LBPCs
   logic [15:0] LBPC2;	// incase there are multiple consecutive branches.

   logic [15:0] LBPSW1;	// Likewise for PSW
   logic [15:0] LBPSW2;

   assign LBPC_LR = LBPC1;
   assign LBPC = LBPC2;
   assign LBPSW = LBPSW2;

   always_comb begin
      // Sign-extend 13-bit input to 16-bit signed output
      extended_13 = { {3{thirteen_lsb[12]}}, thirteen_lsb } << 1;
   end

   always_comb begin
      // Sign-extend 9-bit input to 16-bit signed output
      extended_9 = { {7{thirteen_lsb[8]}}, thirteen_lsb[8:0] } << 1;
   end

   always_ff @(negedge clk) begin
      // Store LBPC1, LBPC2 and calculate next PC
      LBPC2 <= LBPC1;
      LBPC1 <= PC_in + 16'b0000000000000010;
      // Likewise for PSW
      LBPSW2 <= LBPSW1;
      LBPSW1 <= PSW_in;
      if ((three_msb == 3'b000)) begin
         PC_next <= PC_in + extended_13 + 16'b0000000000000010;
      end else if ((three_msb == 3'b001)) begin
         PC_next <= PC_in + extended_9 + 16'b0000000000000010;
      end else begin
         PC_next <= PC_in + 16'b0000000000000010;
      end
   end

   //------------------------------------------------------------------------

endmodule
