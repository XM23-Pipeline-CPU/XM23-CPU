// alu_ADDC.sv
module alu_ADDC (
    input logic [15:0] a,    // Operand A
    input logic [15:0] b,    // Operand B
	 input logic carry_in,
    output logic [15:0] result // Result

);

    logic [16:0] wide_result;
	 assign wide_result = a + b + carry_in;
	 
	 assign result = wide_result[15:0]; // Bitwise AND operation
	 assign carry_out = wide_result[16];
endmodule