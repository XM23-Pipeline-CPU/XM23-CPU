// alu_COMP.sv
module alu_COMP (
   input  logic [15:0] a,     // Operand A
   output logic [15:0] result // Result
);
   assign result = ~a;
endmodule
