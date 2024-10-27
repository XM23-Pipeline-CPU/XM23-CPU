module pipeline_registers(
    // Clock
    input logic clk,
	 
	 // Stalling input (if any bit is set then stall)
	 input logic [7:0] stall_in,
	 
	 // Actual Instruction Registers input (need to update top level to actually use this)
	 input logic [15:0] fetch_in,
	 
    // Input Decoder
    input logic WB, SLP, N, Z, C, V, PRPO, DEC, INC, RC,
    input logic [2:0] D, S, PR, F, T,
    input logic [3:0] SA,
    input logic [12:0] OFF,
    input logic [7:0] B,
    input logic [40:0] enable, 
    
    // Input PSW, CEX, General Purpose Registers, and Constants
    input logic [15:0] PSW_mask,
    input logic [15:0] PSW,
    input logic [15:0] CEX,
	 
	 // Input to store alu result
	 input logic [15:0] alu_result,
	 
	 // Input to store moves result
	 input logic [15:0] moves_result,
	 
	 // Input to store memory access result
	 input logic [15:0] mem_access_result,
    
	 
	 // Actual Instruction Registers output (need to update top level to actually use this)
	 output logic [4:0][15:0] p_reg,
	 // Output previous decoder values
    // index [0] for execute stage
    // index [1] for memory access stage
    // index [2] for register writeback stage
    output logic [2:0] WB_o, SLP_o, N_o, Z_o, C_o, V_o, PRPO_o, DEC_o, INC_o, RC_o,
    output logic [2:0][2:0] D_o, S_o, PR_o, F_o, T_o,
    output logic [2:0][3:0] SA_o,
    output logic [2:0][12:0] OFF_o,
    output logic [2:0][7:0] B_o,
    output logic [2:0][40:0] enable_o, 
    
    // Output PSW
    output logic [15:0] PSW_o,
    
    // Output General purpose registers and constants
    output logic [1:0][7:0][15:0] gprc_o,
	 
	 // Writing alu results out
	 output logic [15:0] exec_result_o
);

    // Parameters
    localparam NUM_STORED_STAGES = 3;
    localparam NUM_REGISTERS = 8;
    localparam SELECT_REG = 0;
    localparam SELECT_CON = 1;
    localparam logic signed [15:0] CONSTANTS [7:0] = '{
        16'sd0,
        16'sd1,
        16'sd2,
        16'sd4,
        16'sd8,
        16'sd16,
        16'sd32,
        -16'sd1
    };
    
	// Internal signals

	// Scalar signals initialized to zero
	logic [2:0] WB_i     = 3'b0,
					SLP_i    = 3'b0,
					N_i      = 3'b0,
					Z_i      = 3'b0,
					C_i      = 3'b0,
					V_i      = 3'b0,
					PRPO_i   = 3'b0,
					DEC_i    = 3'b0,
					INC_i    = 3'b0,
					RC_i     = 3'b0;

	// Arrays of 3 elements, each initialized to zero
	logic [2:0][2:0] D_i      = '{default: 3'b0},
						  S_i      = '{default: 3'b0},
						  PR_i     = '{default: 3'b0},
						  F_i      = '{default: 3'b0},
						  T_i      = '{default: 3'b0};

	// Array of 3 elements, each 4 bits wide, initialized to zero
	logic [2:0][3:0] SA_i     = '{default: 4'b0};

	// Array of 3 elements, each 13 bits wide, initialized to zero
	logic [2:0][12:0] OFF_i   = '{default: 13'b0};

	// Array of 3 elements, each 8 bits wide, initialized to zero
	logic [2:0][7:0] B_i      = '{default: 8'b0};

	// Array of 3 elements, each 41 bits wide, initialized to zero
	logic [2:0][40:0] enable_i = '{default: 41'b0};

	// Initialize PSW_i to zero
	logic [15:0] PSW_i = 16'b0;

	// Initialize exec_result_i to zero
	logic [1:0][15:0] exec_result_i = '{default: 16'b0};
	
	// Initialize mem_access_result_i to zero
	logic [15:0] mem_access_result_i = 16'b0;
    	
	// Corrected declaration and initialization of gprc_i
	logic [1:0][7:0][15:0] gprc_i = '{
	 '{-16'sd1, 16'sd32, 16'sd16, 16'sd8, 16'sd4, 16'sd2, 16'sd1, 16'sd0},    	// CONSTANTS gprc_i[1]
    '{16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0, 16'b0}  // REGISTERS gprc_i[0]
	 };
	
    // Shift register logic
    always_ff @(posedge clk) begin
		  // Bubble insertion if pipeline controller and decoder found stall dependancies
		  if (!(|stall_in)) begin 
				 
				 // If no stall propagate decode info
		       WB_i[0] <= WB;
				 SLP_i[0] <= SLP;
				 N_i[0] <= N;
				 Z_i[0] <= Z;
				 C_i[0] <= C;
				 V_i[0] <= V;
				 PRPO_i[0] <= PRPO;
				 DEC_i[0] <= DEC;
				 INC_i[0] <= INC;
				 RC_i[0] <= RC;
				 D_i[0] <= D;
				 S_i[0] <= S;
				 PR_i[0] <= PR;
				 F_i[0] <= F;
				 T_i[0] <= T;
				 SA_i[0] <= SA;
				 OFF_i[0] <= OFF;
				 B_i[0] <= B;
				 enable_i[0] <= enable;
				 
		  end else begin
		  
				 // If stall then disable decode propagation.
				 // Setting 0 to enable should disable all 
				 // subsequent CPU functionality on the next shifted value
			    enable_i[0] <= 41'b0;
				 
		  end
		  
		  // Shift all pipeline stages on the positive edge of the clock
		  WB_i[2:1]    <= WB_i[1:0];
        SLP_i[2:1]   <= SLP_i[1:0];
        N_i[2:1]     <= N_i[1:0];
        Z_i[2:1]     <= Z_i[1:0];
        C_i[2:1]     <= C_i[1:0];
        V_i[2:1]     <= V_i[1:0];
        PRPO_i[2:1]  <= PRPO_i[1:0];
        DEC_i[2:1]   <= DEC_i[1:0];
        INC_i[2:1]   <= INC_i[1:0];
        RC_i[2:1]    <= RC_i[1:0];
        D_i[2:1]     <= D_i[1:0];
        S_i[2:1]     <= S_i[1:0];
        PR_i[2:1]    <= PR_i[1:0];
        F_i[2:1]     <= F_i[1:0];
        T_i[2:1]     <= T_i[1:0];
        SA_i[2:1]    <= SA_i[1:0];
        OFF_i[2:1]   <= OFF_i[1:0];
        B_i[2:1]     <= B_i[1:0];
        enable_i[2:1] <= enable_i[1:0];
		  exec_result_i[1] <= exec_result_i[0];  
		  mem_access_result_i <= mem_access_result;
		  
        // Update the exec result wire with the correct input from either ALU or MOVES module
		  if(!(|enable_i[0][38:35])) begin // if NOT moves
				exec_result_i[0] <= alu_result; // take from alu
		  end else begin
				exec_result_i[0] <= moves_result; // take from moves
		  end
		  
		  // Update PSW
        // If mask bit is high, update that bit; otherwise, retain old value
        PSW_i <= (PSW_i & ~PSW_mask) | (PSW & PSW_mask);
		  
		  // Handling register writeback
		  // If any of the instructions that modify the register are present from the execute stage, do
		  if ((|enable_i[2][13:9]) || (|enable_i[2][17:15]) || (|enable_i[2][27:19]) || (|enable_i[2][38:35])) begin
				// Execute result from two clock cycles ago goes into correct register
				// Correct register is defined by decode from three clock cycles ago
				
				// If any instruction that is not SWAP, insert result
				if (!enable_i[2][22]) begin
					gprc_i[SELECT_REG][D_i[2]] <= exec_result_i[1];
				end else begin		// If SWAP, SWAP
					gprc_i[SELECT_REG][D_i[2]] <= gprc_i[SELECT_REG][S_i[2]];
					gprc_i[SELECT_REG][S_i[2]] <= gprc_i[SELECT_REG][D_i[2]];
				end
		  // If any of the instructions that modify the register are present from the memory access stage, do
		  end else if (enable_i[2][33] || enable_i[2][39]) begin
				// Memory access result from one clock cycle ago goes into correct register
				// Correct register is defined by decode from three clock cycles ago
				gprc_i[SELECT_REG][D_i[2]] <= mem_access_result_i;
		  end
    end

    // Assign outputs from internal signals
    assign WB_o     = WB_i[2:0];
    assign SLP_o    = SLP_i[2:0];
    assign N_o      = N_i[2:0];
    assign Z_o      = Z_i[2:0];
    assign C_o      = C_i[2:0];
    assign V_o      = V_i[2:0];
    assign PRPO_o   = PRPO_i[2:0];
    assign DEC_o    = DEC_i[2:0];
    assign INC_o    = INC_i[2:0];
    assign RC_o     = RC_i[2:0];
    assign D_o      = D_i[2:0];
    assign S_o      = S_i[2:0];
    assign PR_o     = PR_i[2:0];
    assign F_o      = F_i[2:0];
    assign T_o      = T_i[2:0];
    assign SA_o     = SA_i[2:0];
    assign OFF_o    = OFF_i[2:0];
    assign B_o      = B_i[2:0];
    assign enable_o = enable_i[2:0];
    	
    assign PSW_o    = PSW_i;
    	
    assign gprc_o   = gprc_i;
	 
	 assign exec_result_o = exec_result_i[1];
    
endmodule