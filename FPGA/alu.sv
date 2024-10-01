// alu.sv
module alu (
	input logic [15:0] a,         // Operand A
	input logic [15:0] b,         // Operand B
	input logic [40:0] enable,    // Mode Select
	input logic carry_in,         // Carry In for Addc/Subc/Dadd
	output logic [15:0] result   // ALU Result
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


	// Instantiate operation modules
	alu_AND and_op (.a(a), .b(b), .result(and_result));
	alu_OR or_op (.a(a), .b(b), .result(or_result));
	alu_XOR xor_op (.a(a), .b(b), .result(xor_result));

	alu_BIT bit_op (.a(a), .b(b), .result(bit_result));
	alu_BIC bic_op (.a(a), .b(b), .result(bic_result));
	alu_BIS bis_op (.a(a), .b(b), .result(bis_result));

	alu_ADD add_op (.a(a), .b(b), .result(add_result));
	alu_SUB sub_op (.a(a), .b(b), .result(sub_result));
	alu_ADDC addc_op (.a(a), .b(b), .carry_in(carry_in), .result(addc_result));
	alu_SUBC subc_op (.a(a), .b(b), .carry_in(carry_in), .result(subc_result));
	alu_DADD dadd_op (.a(a), .b(b), .carry_in(carry_in), .result(dadd_result));

	// Mode Select Logic
	always_comb begin
		if (enable[9] == 1'b1) begin //ADD
			result = add_result;
		end else if (enable[10] == 1'b1) begin //ADDC
			result = addc_result;
		end else if (enable[11] == 1'b1) begin //SUB
			result = sub_result;
		end else if (enable[12] == 1'b1) begin //SUBC
			result = subc_result;
		end else if (enable[13] == 1'b1) begin //DADD
			result = dadd_result;
		end else if (enable[15] == 1'b1) begin //XOR
			result = xor_result;
		end else if (enable[16] == 1'b1) begin //AND
			result = and_result;
		end else if (enable[17] == 1'b1) begin //OR
			result = or_result;
		end else if (enable[18] == 1'b1) begin //BIT
			result = bit_result;
		end else if (enable[19] == 1'b1) begin //BIC
			result = bic_result;
		end else if (enable[20] == 1'b1) begin //BIS
			result = bis_result;
		end else begin
			result = 16'b0;
		end
	end
			
endmodule
