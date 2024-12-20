// alu_SWPB.sv
module alu_SWPB (
   input  logic [15:0] a,     // Operand A
   output logic [15:0] result // Result
);
   assign result = {a[7:0], a[15:8]}; // swap bytes of a
endmodule
