// alu_ADDC.sv
module alu_ADDC (
    input logic [15:0] a,    // Operand A
    input logic [15:0] b,    // Operand B
	 input logic carry_in,
    output logic [15:0] result // Result

);
	 assign result = a + b + carry_in;
endmodule