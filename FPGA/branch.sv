/*---------------------------------------------*\
|	Pipeline Controller - Author: Vlad Chiriac   |
|                              & Roee Omessi    |
|	Module contains logic for: 						|
| 		- Undoing incorrect branches              |
| 		- Setting the Link Register               |
\*---------------------------------------------*/

module branch (
	input logic clk,					   // Clock for storing LR
	input logic [40:0] enable,		   // Mode Select
	input logic [15:0] PSW_in,		   // Input PSW
	input logic [15:0] LBPC_in,	   // LBPC (for setting link register for BL)
	output logic branch_fail_o = 0,	// Output if the branch should not take place
	output logic [15:0] LR_o		   // Link Register (not general purpose)
	
);
	// PSW bits
	parameter C = 0;
	parameter Z = 1;
	parameter N = 2;
	parameter V = 4;
	
	// BL always correct branch prediction (just store the PC)
	always_ff @ (negedge clk) begin
		if (enable[0] == 1'b1) begin
			LR_o <= LBPC_in;
		end
	end

	// Mode Select Logic
	always_comb begin 
		// BEQ
		if ((enable[1] == 1'b1) && !(PSW_in[Z] == 1'b1) ) begin 
			// If NOT equal, branch prediction failed
			branch_fail_o <= 1'b1;
			
		// BNE	
		end else if ((enable[2] == 1'b1) && !(PSW_in[Z] == 1'b0)) begin 
			// If equal, branch prediction failed
			branch_fail_o <= 1'b1;
		
		// BC
		end else if ((enable[3] == 1'b1) && !(PSW_in[C] == 1'b1)) begin
			// If NOT carry, branch prediction failed
			branch_fail_o <= 1'b1;
		
		// BNC
		end else if ((enable[4] == 1'b1) && !(PSW_in[C] == 1'b0)) begin
			// If carry, branch prediction failed
			branch_fail_o <= 1'b1;
		
		// BN
		end else if ((enable[5] == 1'b1) && !(PSW_in[N] == 1'b1)) begin
			// If NOT negative, branch prediction failed
			branch_fail_o <= 1'b1;
		
		// BGE
		end else if ((enable[6] == 1'b1) && !(PSW_in[N] == PSW_in[V])) begin
			// If NOT greater, branch prediction failed
			branch_fail_o <= 1'b1;
		
		// BLT
		end else if ((enable[7] == 1'b1) && !(PSW_in[N] != PSW_in[V])) begin
			// if NOT less than, branch prediction failed
			branch_fail_o <= 1'b1;
	
		// BRA
		end else if ((enable[8] == 1'b1)) begin
			// Do nothing (this was already predicted)
			branch_fail_o <= 1'b0;
		end else begin
			branch_fail_o <= 1'b0;
		end
	end
		
endmodule 