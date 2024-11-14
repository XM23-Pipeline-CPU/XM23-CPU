// alu_SRA.sv
module alu_SRA (
   input  logic [15:0] a,     // Operand A
   output logic [15:0] result // Result
);
   assign result = {a[15], a >> 1}; // shift right and sign extend
endmodule
