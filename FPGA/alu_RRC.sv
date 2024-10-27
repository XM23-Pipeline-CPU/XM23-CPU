module alu_RRC (
	input logic [15:0] a,    // Operand A
	input logic carry_in,
	output logic [15:0] result // Result
);
	logic [16:0] temp;
	assign temp = {carry_in, a} >> 1;
	assign result = temp[15:0];
	
endmodule