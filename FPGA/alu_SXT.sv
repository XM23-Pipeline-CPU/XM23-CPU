// alu_SXT.sv
module alu_SXT (
   input  logic [15:0] a,     // Operand A
   output logic [15:0] result // Result
);
   assign result = {{8{a[7]}}, a[7:0]}; // sign extend 7th bit
endmodule
