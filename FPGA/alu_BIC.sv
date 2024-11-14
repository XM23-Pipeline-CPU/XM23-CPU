// alu_BIC.sv
module alu_BIC (
   input  logic [15:0] a,     // Operand A
   input  logic [15:0] b,     // Operand B
   output logic [15:0] result // Result
);
   assign result = (a & ~(1 << b));
endmodule
