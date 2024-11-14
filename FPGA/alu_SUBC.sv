// alu_SUBC.sv
module alu_SUBC (
   input  logic [15:0] a,        // Operand A
   input  logic [15:0] b,        // Operand B
   input  logic        carry_in, // Carry
   output logic [15:0] result    // Result
);
   logic [15:0] src;
   assign src = ~b;
   assign result = a + src + carry_in;
endmodule 
