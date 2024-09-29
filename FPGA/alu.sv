// alu.sv
module alu (
	input logic [15:0] a,         // Operand A
	input logic [15:0] b,         // Operand B
	input logic [40:0] enable,    // Mode Select
	input logic carry_in,         // Carry In for Addc/Subc/Dadd
	output logic [15:0] result,   // ALU Result
	output logic [15:0] psw_out,
	output logic [15:0] psw_msk
);

	// Internal result signals
	logic [15:0] and_result;
	logic [15:0] or_result;
	logic [15:0] xor_result;

	logic [15:0] bit_result;
	logic [15:0] bic_result;
	logic [15:0] bis_result;

	logic [15:0] add_result;
	logic [15:0] sub_result;
	logic [15:0] addc_result;
	logic [15:0] subc_result;
	logic [15:0] dadd_result;
	
	// Internal psw signals
	logic [15:0] and_psw_out;
	logic [15:0] or_psw_out;
	logic [15:0] xor_psw_out;

	logic [15:0] bit_psw_out;
	logic [15:0] bic_psw_out;
	logic [15:0] bis_psw_out;

	logic [15:0] add_psw_out;
	logic [15:0] sub_psw_out;
	logic [15:0] addc_psw_out;
	logic [15:0] subc_psw_out;
	logic [15:0] dadd_psw_out;
	
	// Internal psw mask signals
	logic [15:0] and_psw_msk;
	logic [15:0] or_psw_msk;
	logic [15:0] xor_psw_msk;

	logic [15:0] bit_psw_msk;
	logic [15:0] bic_psw_msk;
	logic [15:0] bis_psw_msk;

	logic [15:0] add_psw_msk;
	logic [15:0] sub_psw_msk;
	logic [15:0] addc_psw_msk;
	logic [15:0] subc_psw_msk;
	logic [15:0] dadd_psw_msk;


	// Instantiate operation modules
	alu_AND and_op (.a(a), .b(b), .result(and_result), .psw_out(and_psw_out), .psw_msk(and_psw_msk));
	alu_OR or_op (.a(a), .b(b), .result(or_result), .psw_out(or_psw_out), .psw_msk(or_psw_msk));
	alu_XOR xor_op (.a(a), .b(b), .result(xor_result), .psw_out(xor_psw_out), .psw_msk(xor_psw_msk));

	alu_BIT bit_op (.a(a), .b(b), .result(bit_result), .psw_out(bit_psw_out), .psw_msk(bit_psw_msk));
	alu_BIC bic_op (.a(a), .b(b), .result(bic_result), .psw_out(bic_psw_out), .psw_msk(bic_psw_msk));
	alu_BIS bis_op (.a(a), .b(b), .result(bis_result), .psw_out(bis_psw_out), .psw_msk(bis_psw_msk));

	alu_ADD add_op (.a(a), .b(b), .result(add_result), .psw_out(add_psw_out), .psw_msk(add_psw_msk));
	alu_SUB sub_op (.a(a), .b(b), .result(sub_result), .psw_out(sub_psw_out), .psw_msk(sub_psw_msk));
	alu_ADDC addc_op (.a(a), .b(b), .carry_in(carry_in), .result(addc_result), .psw_out(addc_psw_out), .psw_msk(addc_psw_msk));
	alu_SUBC subc_op (.a(a), .b(b), .carry_in(carry_in), .result(subc_result), .psw_out(subc_psw_out), .psw_msk(subc_psw_msk));
	alu_DADD dadd_op (.a(a), .b(b), .carry_in(carry_in), .result(dadd_result), .psw_out(dadd_psw_out), .psw_msk(dadd_psw_msk));

	// Mode Select Logic
	always_comb begin
		if (enable[9] == 1'b1) begin //ADD
			result = add_result;
			psw_out = add_psw_out;
			psw_msk = add_psw_msk;
		end else if (enable[10] == 1'b1) begin //ADDC
			result = addc_result;
			psw_out = addc_psw_out;
			psw_msk = addc_psw_msk;
		end else if (enable[11] == 1'b1) begin //SUB
			result = sub_result;
			psw_out = sub_psw_out;
			psw_msk = sub_psw_msk;
		end else if (enable[12] == 1'b1) begin //SUBC
			result = subc_result;
			psw_out = subc_psw_out;
			psw_msk = subc_psw_msk;
		end else if (enable[13] == 1'b1) begin //DADD
			result = dadd_result;
			psw_out = dadd_psw_out;
			psw_msk = dadd_psw_msk;
		end else if (enable[15] == 1'b1) begin //XOR
			result = xor_result;
			psw_out = xor_psw_out;
			psw_msk = xor_psw_msk;
		end else if (enable[16] == 1'b1) begin //AND
			result = and_result;
			psw_out = and_psw_out;
			psw_msk = and_psw_msk;
		end else if (enable[17] == 1'b1) begin //OR
			result = or_result;
			psw_out = or_psw_out;
			psw_msk = or_psw_msk;
		end else if (enable[18] == 1'b1) begin //BIT
			result = bit_result;
			psw_out = bit_psw_out;
			psw_msk = bit_psw_msk;
		end else if (enable[19] == 1'b1) begin //BIC
			result = bic_result;
			psw_out = bic_psw_out;
			psw_msk = bic_psw_msk;
		end else if (enable[20] == 1'b1) begin //BIS
			result = bis_result;
			psw_out = bis_psw_out;
			psw_msk = bis_psw_msk;
		end else begin
			result = 16'b0;
			psw_out = 16'b0;
			psw_msk = 16'b0;
		end
	end
			
endmodule
