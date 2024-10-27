module update_psw(
	input logic [15:0] a,
	input logic [15:0] b,
	input logic [15:0] result,
	input logic enable_psw_msk,
	input logic [40:0] enable,
	input logic SLP_i,
	input logic N_i,
	input logic Z_i,
	input logic C_i,
	input logic V_i,
	
	output logic [15:0] psw_out,
	output logic [15:0] psw_msk
);

	// Initializing carry array
	logic [1:0][1:0][1:0] carry_arr;

	// Initializing overflow array
	logic [1:0][1:0][1:0] overflow_arr;

	// Defining internal PSW signals
	logic carry_bit;
	logic overflow_bit;
	logic zero_bit;
	logic negative_bit;
	
	parameter C = 0;
	parameter Z = 1;
	parameter N = 2;
	parameter SLP = 3;
	parameter V = 4;
	


	// Combinational logic block for flag calculation
	always_comb begin
		// Initialize to zero
		psw_out = 16'b0;
		psw_msk = 16'b0;
		
		//Credit to Dr. Larry Hughes for defining set conditions array
		carry_arr[0][0][0] = 0;
		carry_arr[0][0][1] = 0;
		carry_arr[0][1][0] = 1;
		carry_arr[0][1][1] = 0;
		carry_arr[1][0][0] = 1;
		carry_arr[1][0][1] = 0;
		carry_arr[1][1][0] = 1;
		carry_arr[1][1][1] = 1;

		//Credit to Dr. Larry Hughes for defining set conditions array
		overflow_arr[0][0][0] = 0;
		overflow_arr[0][0][1] = 1;
		overflow_arr[0][1][0] = 0;
		overflow_arr[0][1][1] = 0;
		overflow_arr[1][0][0] = 0;
		overflow_arr[1][0][1] = 0;
		overflow_arr[1][1][0] = 1;
		overflow_arr[1][1][1] = 0;
		
		carry_bit = 0;
		overflow_bit = 0;
		zero_bit = 0;
		negative_bit = 0;
		
		// If coming from classic alu instructions
		if ((|enable[20:9])) begin
			// Set carry, overflow, zero, and negative bits
			carry_bit = carry_arr[b[15]][a[15]][result[15]];
			overflow_bit = overflow_arr[b[15]][a[15]][result[15]];
			zero_bit = !(|result);
			negative_bit = result[15];

			// Update PSW and mask based on flag values
			psw_out[0] = carry_bit; // Set PSW[0] to carry
			psw_out[1] = zero_bit;
			psw_out[2] = negative_bit;
			psw_out[4] = overflow_bit;

			if(enable_psw_msk == 1'b1) begin
				psw_msk[C] = 1'b1;
				psw_msk[Z] = 1'b1;
				psw_msk[N] = 1'b1;
				psw_msk[V] = 1'b1;
			end
		
		// Unique PSW updating
		end else if ((|enable[24:23])) begin	// SRA or RRC
			psw_msk[C] = 1'b1;
			psw_out[C] = a[0];
		end else if (enable[30]) begin	// SETCC
			psw_msk[C] = C_i;
			psw_msk[Z] = Z_i;
			psw_msk[N] = N_i;
			psw_msk[SLP] = SLP_i;
			psw_msk[V] = V_i;
			
			psw_out[C] = 1'b1;
			psw_out[Z] = 1'b1;
			psw_out[N] = 1'b1;
			psw_out[SLP] = 1'b1;
			psw_out[Z] = 1'b1;
			
		end else if (enable[30]) begin	// CLRCC
			psw_msk[C] = C_i;
			psw_msk[Z] = Z_i;
			psw_msk[N] = N_i;
			psw_msk[SLP] = SLP_i;
			psw_msk[V] = V_i;
			
			psw_out[C] = 1'b0;
			psw_out[Z] = 1'b0;
			psw_out[N] = 1'b0;
			psw_out[SLP] = 1'b0;
			psw_out[Z] = 1'b0;
		end
	end

endmodule
