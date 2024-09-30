// module extracts values from correct registers or constants
// as specified by the decode stage, and passes them on to ALU
module regnum_to_values_to_alu (
	input logic [1:0][7:0][15:0] gprc,
	input logic [2:0] temp_rc,
	input logic [2:0][2:0] src_i,
	input logic [2:0][2:0] dst_i,
	output logic [15:0] src_val,
	output logic [15:0] dst_val
);

	// keep correct (execute stage) rc
	logic rc_in;
	logic [2:0] src_in;
	logic [2:0] dst_in;
	
	always_comb begin
		 rc_in = temp_rc[0];
		 src_in = src_i[0];
		 dst_in = dst_i[0];
	end
	
	// extract actual values from registers
	assign src_val = gprc[rc_in][src_in];
	assign dst_val = gprc[0][dst_in];
	
endmodule
