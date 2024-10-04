module update_psw(
    input logic [15:0] a,
    input logic [15:0] b,
    input logic [15:0] result,
	 input logic enable_psw_msk,
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

    // Combinational logic block for flag calculation
    always_comb begin
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
	 
	 
	 
        // Initialize to zero
        psw_out = 16'b0;
        psw_msk = 16'b0;

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
			  psw_msk[0] = 1'b1;
			  psw_msk[1] = 1'b1;
			  psw_msk[2] = 1'b1;
			  psw_msk[4] = 1'b1;
		  end  
    end

endmodule
