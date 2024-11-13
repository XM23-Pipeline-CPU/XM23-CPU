module go_to_LR (
	input logic [1:0][7:0][15:0] gprc,
	input logic [2:0][2:0] src_i,
	input logic [2:0][40:0] enable,
	input logic [15:0] LR_i,
	
	output logic link_back_o
);
	parameter R = 0; // Register index
	parameter exec_stage = 0; // Memory access stage index
	parameter LD = 33; // LD instruction 
	
	always_comb begin
		// If an LD instruction with SRC address FFFF is input, this triggers the link at execute stage
		if (enable[exec_stage][LD] && (gprc[R][src_i[exec_stage]] == 16'b1111111111111111)) begin
			link_back_o = 1'b1;
		end else begin
			link_back_o = 1'b0;
		end
		
	end

endmodule
			
			