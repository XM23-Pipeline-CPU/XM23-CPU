// alu.sv
module alu (
	input logic [15:0] a,         // Operand A
	input logic [15:0] b,         // Operand B
	input logic [40:0] enable,    // Mode Select
	input logic carry_in,         // Carry In for Addc/Subc/Dadd
	output logic [15:0] result,   // ALU Result
	output logic enable_psw_msk
);
	// INPUT A == DST, INPUT B == SRC
	
	
	
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
	
	
	logic [15:0] mov_result;
	logic [15:0] sra_result;
	logic [15:0] rrc_result;
	logic [15:0] comp_result;
	logic [15:0] swpb_result;
	logic [15:0] sxt_result;


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
	
	alu_MOV mov_op (.b(b), .result(mov_result));
	
	alu_SRA sra_op (.a(a), .result(sra_result));
	alu_RRC rrc_op (.a(a), .carry_in(carry_in), .result(rrc_result));
	alu_COMP comp_op (.a(a), .result(comp_result));
	alu_SWPB swpb_op (.a(a), .result(swpb_result));
	alu_SXT sxt_op (.a(a), .result(sxt_result));
	

	// Mode Select Logic
	always_comb begin
		if (enable[9] == 1'b1) begin //ADD
			result = add_result;
			enable_psw_msk = 1'b1;
		end else if (enable[10] == 1'b1) begin //ADDC
			result = addc_result;
			enable_psw_msk = 1'b1;
		end else if (enable[11] == 1'b1) begin //SUB
			result = sub_result;
			enable_psw_msk = 1'b1;
		end else if (enable[12] == 1'b1) begin //SUBC
			result = subc_result;
			enable_psw_msk = 1'b1;
		end else if (enable[13] == 1'b1) begin //DADD
			result = dadd_result;
			enable_psw_msk = 1'b1;
		end else if (enable[14] == 1'b1) begin //CMP
			// This result will not be writen back
			result = sub_result;
			enable_psw_msk = 1'b1;
		end else if (enable[15] == 1'b1) begin //XOR
			result = xor_result;
			enable_psw_msk = 1'b1;
		end else if (enable[16] == 1'b1) begin //AND
			result = and_result;
			enable_psw_msk = 1'b1;
		end else if (enable[17] == 1'b1) begin //OR
			result = or_result;
			enable_psw_msk = 1'b1;
		end else if (enable[18] == 1'b1) begin //BIT
			// This result will not be writen back
			result = bit_result; 
			enable_psw_msk = 1'b1;
		end else if (enable[19] == 1'b1) begin //BIC
			result = bic_result;
			enable_psw_msk = 1'b1;
		end else if (enable[20] == 1'b1) begin //BIS
			result = bis_result;
			enable_psw_msk = 1'b1;
		end else if (enable[21] == 1'b1) begin //MOV
			result = mov_result;
			enable_psw_msk = 1'b0;
		end else if (enable[23] == 1'b1) begin //SRA
			result = sra_result;
			enable_psw_msk = 1'b0;
		end else if (enable[24] == 1'b1) begin //RRC
			result = rrc_result;
			enable_psw_msk = 1'b0;
		end else if (enable[25] == 1'b1) begin //COMP
			result = comp_result;
			enable_psw_msk = 1'b0;
		end else if (enable[26] == 1'b1) begin //SWPB
			result = swpb_result;
			enable_psw_msk = 1'b0;
		end else if (enable[27] == 1'b1) begin //SXT
			result = sxt_result;
			enable_psw_msk = 1'b0;
		end else begin
			result = 16'b0;
			enable_psw_msk = 1'b0;
		end
	end
			
endmodule
