// alu_SUBC.sv
module alu_SUBC (
    input logic [15:0] a,    // Operand A
    input logic [15:0] b,    // Operand B
	 input logic carry_in,
	 output logic [15:0] psw_out,
	 output logic [15:0] psw_msk,
    output logic [15:0] result // Result

);

    logic [16:0] wide_result;
	 assign wide_result = {1'b0, a} - {1'b0, b} - carry_in;
	 
	 assign result = wide_result[15:0]; // Bitwise AND operation
	 assign carry_out = wide_result[16];
endmodule 