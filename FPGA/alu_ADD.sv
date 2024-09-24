// alu_ADD.sv
module alu_ADD (
    input logic [15:0] a,    // Operand A
    input logic [15:0] b,    // Operand B
	 
    output logic [15:0] result, // Result
	 output logic carry_out
);

    logic [16:0] wide_result;
	 assign wide_result = a + b;
	 
	 assign result = wide_result[15:0]; // Bitwise AND operation
	 assign carry_out = wide_result[16];
endmodule