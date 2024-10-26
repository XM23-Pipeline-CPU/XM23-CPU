module program_counter (
	input logic [15:0] PC_next,
	input logic [15:0] LBPC,
	input logic        branch_fail,
	input logic        clk,
	input logic [7:0]  stall_in,

	output logic [15:0] true_PC = 0
);
	always @(posedge clk) begin
		if (|stall_in) begin
			// Do nothing
		end else if (branch_fail) begin
			true_PC <= LBPC;
			// Also clear pipeline (tbd)
		end else begin
			true_PC <= PC_next;
		end
	end
	
endmodule