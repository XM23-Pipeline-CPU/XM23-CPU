// module extracts values from correct registers or constants
// as specified by the decode stage, and passes them on to ALU
module regnum_to_values_to_alu (
	output logic [15:0] src_val,
	output logic [15:0] dst_val,
	output logic carry_val
);

	logic [1:0][7:0][15:0] gprc;
	logic [2:0] temp_carry;
	logic [2:0] temp_rc;
	logic [3:0] src_i;
	logic [3:0] dst_i;
	
	// pull data from pipeline registers
	pipeline_registers pipeline_out(
		.gprc_o(gprc),
		.C_o(temp_carry),
		.RC_o(temp_rc),
		.S_o(src_i),
		.D_o(dst_i)
	);	

	// keep correct (execute stage) carry and rc
	logic carry_in = temp_carry[0];
	logic rc_in = temp_rc[0];
	
	// extract actual values from registers
	assign carry_val = carry_in;
	assign src_val = gprc[rc_in][src_i];
	assign dst_val = gprc[rc_in][dst_i];
	
endmodule
