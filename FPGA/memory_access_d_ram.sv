module memory_access_d_ram (
	input logic [2:0][40:0] enable,
	input logic [1:0][7:0][15:0] gprc,
	input logic [2:0][12:0] off,
	input logic [2:0] pre,
	input logic [2:0] inc,
	input logic [2:0] dec,
	input logic [2:0][2:0] src_i,
	input logic [2:0][2:0] dst_i,
	
	output logic write_enable,
	output logic [15:0] output_address,
	output logic [15:0] output_data
);

	parameter R = 0; // Register index
	parameter mem_access_stage = 1; // Memory access stage index
	parameter LD = 33; // LD instruction 
	parameter ST = 34; // LD instruction 
	parameter LDR = 39; // LD instruction 
	parameter STR = 40; // LD instruction 

	always_comb begin 
	
		// Default
		write_enable = 1'b0;
		output_address = 16'b0;
		output_data = 16'b0;
		
		// LD
		if (enable[mem_access_stage][LD]) begin
			
			// Get the output address without offsets
			output_address = gprc[R][src_i[mem_access_stage]];
			
			// If increments or decrements are needed do them here
			if (pre[mem_access_stage] == 1'b1) begin
				if (inc[mem_access_stage] == 1'b1) begin
					output_address = gprc[R][src_i[mem_access_stage]] + 16'b1;
				end else if (dec[mem_access_stage] == 1'b1) begin
					output_address = gprc[R][src_i[mem_access_stage]] - 16'b1;
				end
			end
		
		// ST	
		end else if (enable[mem_access_stage][ST] || enable[mem_access_stage][STR]) begin
			
			// Enable writing
			write_enable = 1'b1;
			
			// Output Data
			output_data = gprc[R][src_i[mem_access_stage]];
			
			// Get the output address without offsets
			output_address = gprc[R][dst_i[mem_access_stage]];
			
			// If increments or decrements are needed do them here
			if (pre[mem_access_stage] == 1'b1) begin
				if (inc[mem_access_stage] == 1'b1) begin
					output_address = gprc[R][dst_i[mem_access_stage]] + 16'b1;
				end else if (dec[mem_access_stage] == 1'b1) begin
					output_address = gprc[R][dst_i[mem_access_stage]] - 16'b1;
				end
			end	 
			
		// LDR
		end else if (enable[mem_access_stage][LDR]) begin
			
			// Get the output address with offset and sign extension
			output_address = gprc[R][src_i[mem_access_stage]] + { {9{off[mem_access_stage][7]}}, off[mem_access_stage][7:0]}; 
			
		// STR
		end else if (enable[mem_access_stage][STR]) begin
			
			// Enable writing
			write_enable = 1'b1;
			
			// Output Data
			output_data = gprc[R][src_i[mem_access_stage]];
			
			// Get the output address with offset and sign extension
			output_address = gprc[R][dst_i[mem_access_stage]] + { {9{off[mem_access_stage][7]}}, off[mem_access_stage][7:0]}; 		
			
		end	
		
	end
	
endmodule