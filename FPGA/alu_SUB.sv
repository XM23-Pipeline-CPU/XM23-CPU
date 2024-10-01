// alu_SUB.sv
module alu_SUB (
    input logic [15:0] a,    // Operand A
    input logic [15:0] b,    // Operand B
    output logic [15:0] result // Result
);

    logic [16:0] wide_result;
	 assign wide_result = {1'b0, a} - {1'b0, b};
	 
	 assign result = wide_result[15:0]; // Bitwise AND operation
	 assign carry_out = wide_result[16];
endmodule 