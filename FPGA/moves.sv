module moves (
	input logic [40:0] enable,
	input logic [1:0][7:0][15:0] gprc,
	input logic [2:0][2:0] dst_i,
	input logic [7:0] b_i,
	
	output logic [15:0] result
);
	
	// Mode Select Logic
	always_comb begin
		if (enable[35] == 1'b1) begin //MOVL
			result = {gprc[0][dst_i[0]][15:8], b_i};
		end else if (enable[36] == 1'b1) begin //MOVLZ
			result = {8'b00000000, b_i};
		end else if (enable[37] == 1'b1) begin //MOVLS
			result = {8'b11111111, b_i};
		end else if (enable[38] == 1'b1) begin //MOVH
			result = {b_i, gprc[0][dst_i[0]][7:0]};
		end else begin
			result[15:0] = 16'b0;
		end
	end
	
endmodule
