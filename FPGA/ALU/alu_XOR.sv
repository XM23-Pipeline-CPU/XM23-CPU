// alu_XOR.sv
module alu_XOR (
    input logic [15:0] a,    // Operand A
    input logic [15:0] b,    // Operand B
    output logic [15:0] result // Result
);
    assign result = a ^ b; // Bitwise AND operation
endmodule