// alu_SUB.sv
module alu_SUB (
    input logic [15:0] a,    // Operand A - DST
    input logic [15:0] b,    // Operand B - SRC
    output logic [15:0] result // Result
);
	logic [15:0] src;
	assign src = ~b;
	assign result = a + src + 1'b1;
    
endmodule 