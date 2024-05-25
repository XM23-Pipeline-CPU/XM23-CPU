// alu_OR.sv
module alu_OR (
    input logic [15:0] a,    // Operand A
    input logic [15:0] b,    // Operand B
    output logic [15:0] result // Result
);
    assign result = a | b; // Bitwise OR operation
endmodule