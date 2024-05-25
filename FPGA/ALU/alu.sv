// alu.sv
module alu (
    input logic [15:0] a,         // Operand A
    input logic [15:0] b,         // Operand B
    input logic [3:0] mode_select, // Mode Select
    input logic carry_in,         // Carry In for Add/Sub/Dadd
    output logic [15:0] result,   // ALU Result
    output logic carry_out        // Carry Out for Add/Sub/Dadd
);

    // Internal signals
    logic [15:0] and_result;
	 logic [15:0] or_result;
	 logic [15:0] xor_result;
	 
	 logic [15:0] bit_result;
	 logic [15:0] bic_result;
	 logic [15:0] bis_result;
	 
    logic [15:0] add_result;
	 logic [15:0] sub_result;
	 logic [15:0] dadd_result;
	 
    logic add_carry_out;
	 logic sub_carry_out;
	 logic dadd_carry_out;

    // Instantiate operation modules
    alu_AND and_op (.a(a), .b(b), .result(and_result));
    alu_OR or_op (.a(a), .b(b), .result(or_result));
    alu_XOR xor_op (.a(a), .b(b), .result(xor_result));
	 
	 alu_BIT bit_op (.a(a), .b(b), .result(bit_result));
    alu_BIC bic_op (.a(a), .b(b), .result(bic_result));
    alu_BIS bis_op (.a(a), .b(b), .result(bis_result));
	 
	 alu_ADD add_op (.a(a), .b(b), .carry_in(carry_in), .result(add_result), .carry_out(add_carry_out));
	 alu_SUB sub_op (.a(a), .b(b), .carry_in(carry_in), .result(sub_result), .carry_out(sub_carry_out));
	 alu_DADD dadd_op (.a(a), .b(b), .carry_in(carry_in), .result(dadd_result), .carry_out(dadd_carry_out));

    // Mode Select Logic
    always_comb begin
		  carry_out = 1'b0;	//default value for carry out unless we have add/sub/dadd
        case (mode_select)
            4'b0000: result = and_result;
            4'b0001: result = or_result;
            4'b0010: result = xor_result;
				
				4'b0011: result = bit_result;
            4'b0100: result = bic_result;
            4'b0101: result = bis_result;
				
            4'b0110: begin
					result = add_result;
					carry_out = add_carry_out;
				end
				
				4'b0111: begin
					result = sub_result;
					carry_out = sub_carry_out;
				end
				
				4'b1000: begin
					result = dadd_result;
					carry_out = dadd_carry_out;
				end
            
            default: result = 16'b0;
        endcase
    end

endmodule