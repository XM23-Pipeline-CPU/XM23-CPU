module program_counter (
	input logic        init,
	input logic [15:0] PC_init,
	input logic 		 init_clk,
	
	input logic [15:0] PC_next,
	input logic [15:0] LBPC,
	input logic [15:0] LR,
	input logic        link_back,
	input logic        branch_fail,
	input logic        clk,
	input logic [7:0]  stall_in,

	output logic [15:0] true_PC = 0,
	output logic        decode_disable
);
	wire internal_clock;
	
	assign internal_clock = clk | (init_clk & init);
	
	reg [1:0] init_state = 2;
	
	always_ff @(posedge internal_clock) begin
		if (init) begin 
			init_state <= 2;
			true_PC <= PC_init;
			
		end else begin
			if (init_state > 0) begin
				init_state <= init_state - 1;
			end else begin
				if (|stall_in) begin
					// Do nothing
					
				end else if (branch_fail) begin
					true_PC <= LBPC;
					
					// Also clear pipeline 
					
				end else if (link_back) begin 
					true_PC <= LR;
					// Also clear pipeline 
					
				end else begin
					true_PC <= PC_next;
				
				end
			end
		end
	end
	
	assign decode_disable = (|init_state);
	
endmodule
