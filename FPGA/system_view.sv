module system_view (
	input logic clk,
	input logic [1:0][7:0][15:0] gprc,
	input logic [15:0] psw,
	input logic [15:0] pc,
	input logic [15:0] inst
);
	
	logic [7:0][15:0] gprc_regs;
	assign gprc_regs = gprc[0];
	
	logic [175:0] data;
	assign data = {
		gprc_regs,
		psw,
		pc,
		inst
	};
	
	reg_view regview(
		// INPUT FROM TOP LEVEL
		.clock(clk),
		.address(1'b1),
		.data(data),
		.wren(1'b1)
	);

endmodule
