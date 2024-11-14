module decode_stage(
    input logic [15:0] inst,
	 input logic        decode_disable,
	 
	 output logic WB, SLP, N, Z, C, V, PRPO, DEC, INC, RC,
    output logic [2:0] D, S, PR, F, T,
    output logic [3:0] SA,
    output logic [12:0] OFF,
    output logic [7:0] B,
	 
	 output logic [40:0] enable, // 41-bit enable variable
	 
	 output logic [7:0] async_set,
	 output logic [7:0] async_dep
);

	 localparam IS_REG = 1'b0;
	 
	 
    // Define masks and expected values for each instruction
    localparam logic [15:0] MASK_BL    =  16'b1110000000000000;
    localparam logic [15:0] EXPECTED_BL = 16'b0000000000000000;

    localparam logic [15:0] MASK_BEQ   =   16'b1111110000000000;
    localparam logic [15:0] EXPECTED_BEQ = 16'b0010000000000000;

    localparam logic [15:0] MASK_BNE   =   16'b1111110000000000;
    localparam logic [15:0] EXPECTED_BNE = 16'b0010010000000000;

    localparam logic [15:0] MASK_BC    =  16'b1111110000000000;
    localparam logic [15:0] EXPECTED_BC = 16'b0010100000000000;

    localparam logic [15:0] MASK_BNC   =   16'b1111110000000000;
    localparam logic [15:0] EXPECTED_BNC = 16'b0010110000000000;

    localparam logic [15:0] MASK_BN    =  16'b1111110000000000;
    localparam logic [15:0] EXPECTED_BN = 16'b0011000000000000;

    localparam logic [15:0] MASK_BGE   =   16'b1111110000000000;
    localparam logic [15:0] EXPECTED_BGE = 16'b0011010000000000;

    localparam logic [15:0] MASK_BLT   =   16'b1111110000000000;
    localparam logic [15:0] EXPECTED_BLT = 16'b0011100000000000;

    localparam logic [15:0] MASK_BRA   =   16'b1111110000000000;
    localparam logic [15:0] EXPECTED_BRA = 16'b0011110000000000;

    localparam logic [15:0] MASK_ADD   =   16'b1111111100000000;
    localparam logic [15:0] EXPECTED_ADD = 16'b0100000000000000;

    localparam logic [15:0] MASK_ADDC  =    16'b1111111100000000;
    localparam logic [15:0] EXPECTED_ADDC = 16'b0100000100000000;

    localparam logic [15:0] MASK_SUB   =   16'b1111111100000000;
    localparam logic [15:0] EXPECTED_SUB = 16'b0100001000000000;

    localparam logic [15:0] MASK_SUBC  =    16'b1111111100000000;
    localparam logic [15:0] EXPECTED_SUBC = 16'b0100001100000000;

    localparam logic [15:0] MASK_DADD  =    16'b1111111100000000;
    localparam logic [15:0] EXPECTED_DADD = 16'b0100010000000000;

    localparam logic [15:0] MASK_CMP   =   16'b1111111100000000;
    localparam logic [15:0] EXPECTED_CMP = 16'b0100010100000000;

    localparam logic [15:0] MASK_XOR   =   16'b1111111100000000;
    localparam logic [15:0] EXPECTED_XOR = 16'b0100011000000000;

    localparam logic [15:0] MASK_AND   =   16'b1111111100000000;
    localparam logic [15:0] EXPECTED_AND = 16'b0100011100000000;

    localparam logic [15:0] MASK_OR    =  16'b1111111100000000;
    localparam logic [15:0] EXPECTED_OR = 16'b0100100000000000;

    localparam logic [15:0] MASK_BIT   =   16'b1111111100000000;
    localparam logic [15:0] EXPECTED_BIT = 16'b010010010000000;

    localparam logic [15:0] MASK_BIC   =   16'b1111111100000000;
    localparam logic [15:0] EXPECTED_BIC = 16'b0100101000000000;

    localparam logic [15:0] MASK_BIS   =   16'b1111111100000000;
    localparam logic [15:0] EXPECTED_BIS = 16'b0100101100000000;

    localparam logic [15:0] MASK_MOV   =   16'b1111111110000000;
    localparam logic [15:0] EXPECTED_MOV = 16'b0100110000000000;

    localparam logic [15:0] MASK_SWAP  =    16'b1111111110000000;
    localparam logic [15:0] EXPECTED_SWAP = 16'b0100110010000000;

    localparam logic [15:0] MASK_SRA   =   16'b1111111110111000;
    localparam logic [15:0] EXPECTED_SRA = 16'b01001101000000000;

    localparam logic [15:0] MASK_RRC   =   16'b1111111110111000;
    localparam logic [15:0] EXPECTED_RRC = 16'b0100110100001000;

    localparam logic [15:0] MASK_COMP  =    16'b1111111110111000;
    localparam logic [15:0] EXPECTED_COMP = 16'b0100110100010000;

    localparam logic [15:0] MASK_SWPB  =    16'b1111111110111000;
    localparam logic [15:0] EXPECTED_SWPB = 16'b0100110100011000;

    localparam logic [15:0] MASK_SXT   =   16'b1111111110111000;
    localparam logic [15:0] EXPECTED_SXT = 16'b0100110100100000;

    localparam logic [15:0] MASK_SETPRI =     16'b1111111111110000;
    localparam logic [15:0] EXPECTED_SETPRI = 16'b0100110110000000;

    localparam logic [15:0] MASK_SVC   =   16'b1111111111110000;
    localparam logic [15:0] EXPECTED_SVC = 16'b0100110110010000;

    localparam logic [15:0] MASK_SETCC =     16'b1111111111100000;
    localparam logic [15:0] EXPECTED_SETCC = 16'b0100110110100000;

    localparam logic [15:0] MASK_CLRCC =     16'b1111111111100000;
    localparam logic [15:0] EXPECTED_CLRCC = 16'b0100110111000000;

    localparam logic [15:0] MASK_CEX   =   16'b1111110000000000;
    localparam logic [15:0] EXPECTED_CEX = 16'b0101000000000000;

    localparam logic [15:0] MASK_LD    =  16'b1111110000000000;
    localparam logic [15:0] EXPECTED_LD = 16'b0101100000000000;

    localparam logic [15:0] MASK_ST    =  16'b1111110000000000;
    localparam logic [15:0] EXPECTED_ST = 16'b0101110000000000;

    localparam logic [15:0] MASK_MOVL  =    16'b1111100000000000;
    localparam logic [15:0] EXPECTED_MOVL = 16'b0110000000000000;

    localparam logic [15:0] MASK_MOVLZ =     16'b1111100000000000;
    localparam logic [15:0] EXPECTED_MOVLZ = 16'b0110100000000000;

    localparam logic [15:0] MASK_MOVLS =     16'b1111100000000000;
    localparam logic [15:0] EXPECTED_MOVLS = 16'b0111000000000000;

    localparam logic [15:0] MASK_MOVH  =    16'b1111100000000000;
    localparam logic [15:0] EXPECTED_MOVH = 16'b0111100000000000;

    localparam logic [15:0] MASK_LDR   =   16'b1100000000000000;
    localparam logic [15:0] EXPECTED_LDR = 16'b1000000000000000;

    localparam logic [15:0] MASK_STR   =   16'b1100000000000000;
    localparam logic [15:0] EXPECTED_STR = 16'b1100000000000000;


	// Decode the instruction as soon as it comes in
	always_comb begin
		 // Default values for extracted signals

		 WB = 1'b0;
		 SLP = 1'b0;
		 N = 1'b0;
		 Z = 1'b0;
		 C = 1'b0;
		 V = 1'b0;
		 PRPO = 1'b0;
		 DEC = 1'b0;
		 INC = 1'b0;
		 RC = 1'b0;
		 D = 3'b0;
		 S = 3'b0;
		 PR = 3'b0;
		 F = 3'b0;
		 T = 3'b0;
		 SA = 4'b0;
		 OFF = 13'b0;
		 B = 8'b0;
		 enable = 41'b0; // Initialize all enable bits to 0
		 async_set = 8'b0;
		 async_dep = 8'b0;

		 // the following assigns variables to the correct bits
		 // in the instruction depending on what is decoded.
		 if (~decode_disable) begin
			 if ((inst & MASK_BL) == EXPECTED_BL) begin
				  OFF = inst[12:0];
				  enable[0] = 1'b1;
			 end else if ((inst & MASK_BEQ) == EXPECTED_BEQ) begin
				  OFF = inst[9:0];
				  enable[1] = 1'b1;
			 end else if ((inst & MASK_BNE) == EXPECTED_BNE) begin
				  OFF = inst[9:0];
				  enable[2] = 1'b1;
			 end else if ((inst & MASK_BC) == EXPECTED_BC) begin
				  OFF = inst[9:0];
				  enable[3] = 1'b1;
			 end else if ((inst & MASK_BNC) == EXPECTED_BNC) begin
				  OFF = inst[9:0];
				  enable[4] = 1'b1;
			 end else if ((inst & MASK_BN) == EXPECTED_BN) begin
				  OFF = inst[9:0];
				  enable[5] = 1'b1;
			 end else if ((inst & MASK_BGE) == EXPECTED_BGE) begin
				  OFF = inst[9:0];
				  enable[6] = 1'b1;
			 end else if ((inst & MASK_BLT) == EXPECTED_BLT) begin
				  OFF = inst[9:0];
				  enable[7] = 1'b1;
			 end else if ((inst & MASK_BRA) == EXPECTED_BRA) begin
				  OFF = inst[9:0];
				  enable[8] = 1'b1;
			 end else if ((inst & MASK_ADD) == EXPECTED_ADD) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[9] = 1'b1;

				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_set[D] = 1'b1;    //set dependency
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_ADDC) == EXPECTED_ADDC) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[10] = 1'b1;
				  
				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_set[D] = 1'b1;    //set dependency
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_SUB) == EXPECTED_SUB) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[11] = 1'b1;

				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_set[D] = 1'b1;    //set dependency
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_SUBC) == EXPECTED_SUBC) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[12] = 1'b1;

				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_set[D] = 1'b1;    //set dependency
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_DADD) == EXPECTED_DADD) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[13] = 1'b1;
				  
				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_set[D] = 1'b1;    //set dependency
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_CMP) == EXPECTED_CMP) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[14] = 1'b1;
				  
				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_XOR) == EXPECTED_XOR) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[15] = 1'b1;
				  
				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_set[D] = 1'b1;    //set dependency
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_AND) == EXPECTED_AND) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[16] = 1'b1;
				  
				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_set[D] = 1'b1;    //set dependency
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_OR) == EXPECTED_OR) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[17] = 1'b1;
				  
				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_set[D] = 1'b1;    //set dependency
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_BIT) == EXPECTED_BIT) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[18] = 1'b1;
				  
				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_BIC) == EXPECTED_BIC) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[19] = 1'b1;
				  
				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_set[D] = 1'b1;    //set dependency
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_BIS) == EXPECTED_BIS) begin
				  RC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[20] = 1'b1;
				  
				  if(RC == IS_REG) begin
					  async_dep[S] = 1'b1; //be added as dependency
				  end
				  async_set[D] = 1'b1;    //set dependency
				  async_dep[D] = 1'b1;    //be added as dependency
				  
			 end else if ((inst & MASK_MOV) == EXPECTED_MOV) begin
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[21] = 1'b1;
				  
				  async_dep[S] = 1'b1; //be added as dependency
				  async_set[D] = 1'b1; //set dependency
				  
			 end else if ((inst & MASK_SWAP) == EXPECTED_SWAP) begin
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[22] = 1'b1;
				  
				  async_set[S] = 1'b1; //set dependency
				  async_dep[S] = 1'b1; //be added as dependency

				  async_set[D] = 1'b1; //set dependency
				  async_dep[D] = 1'b1; //be added as dependency
				  
			 end else if ((inst & MASK_SRA) == EXPECTED_SRA) begin
				  WB = inst[6];
				  D = inst[2:0];
				  enable[23] = 1'b1;
				  
				  async_set[D] = 1'b1; //set dependency
				  async_dep[D] = 1'b1; //be added as dependency
				  
			 end else if ((inst & MASK_RRC) == EXPECTED_RRC) begin
				  WB = inst[6];
				  D = inst[2:0];
				  enable[24] = 1'b1;
				  
				  async_set[D] = 1'b1; //set dependency
				  async_dep[D] = 1'b1; //be added as dependency
				  
			 end else if ((inst & MASK_COMP) == EXPECTED_COMP) begin
				  WB = inst[6];
				  D = inst[2:0];
				  enable[25] = 1'b1;
				  
				  async_set[D] = 1'b1; //set dependency
				  async_dep[D] = 1'b1; //be added as dependency
				  
			 end else if ((inst & MASK_SWPB) == EXPECTED_SWPB) begin
				  D = inst[2:0];
				  enable[26] = 1'b1;
				  
				  async_set[D] = 1'b1; //set dependency
				  async_dep[D] = 1'b1; //be added as dependency
				  
			 end else if ((inst & MASK_SXT) == EXPECTED_SXT) begin
				  D = inst[2:0];
				  enable[27] = 1'b1;

				  async_set[D] = 1'b1; //set dependency
				  async_dep[D] = 1'b1; //be added as dependency
				  
			 end else if ((inst & MASK_SETPRI) == EXPECTED_SETPRI) begin
				  PR = inst[2:0];
				  enable[28] = 1'b1;
			 end else if ((inst & MASK_SVC) == EXPECTED_SVC) begin
				  SA = inst[3:0];
				  enable[29] = 1'b1;
			 end else if ((inst & MASK_SETCC) == EXPECTED_SETCC) begin
				  V = inst[4];
				  SLP = inst[3];
				  N = inst[2];
				  Z = inst[1];
				  C = inst[0];
				  enable[30] = 1'b1;
			 end else if ((inst & MASK_CLRCC) == EXPECTED_CLRCC) begin
				  V = inst[4];
				  SLP = inst[3];
				  N = inst[2];
				  Z = inst[1];
				  C = inst[0];
				  enable[31] = 1'b1;
			 end else if ((inst & MASK_CEX) == EXPECTED_CEX) begin
				  C = inst[9:6];
				  T = inst[5:3];
				  F = inst[2:0];
				  enable[32] = 1'b1;
			 end else if ((inst & MASK_LD) == EXPECTED_LD) begin
				  PRPO = inst[9];
				  DEC = inst[8];
				  INC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[33] = 1'b1;
				 
				  //set dependency only if PRE/POST INC/DEC
				  if (DEC == 1'b1 || INC == 1'b1) begin
					  async_set[S] = 1'b1;    
				  end
					  
				  async_dep[S] = 1'b1; //be added as dependency
				  
				  async_set[D] = 1'b1; //set dependency
				  
			 end else if ((inst & MASK_ST) == EXPECTED_ST) begin
				  PRPO = inst[9];
				  DEC = inst[8];
				  INC = inst[7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[34] = 1'b1;
				  
				  async_dep[S] = 1'b1; //be added as dependency

				  if (DEC == 1'b1 || INC == 1'b1) begin
					  async_set[D] = 1'b1; //set dependency
				  end
				  
				  async_dep[D] = 1'b1; //be added as dependency
				  
			 end else if ((inst & MASK_MOVL) == EXPECTED_MOVL) begin
				  B = inst[10:3];
				  D = inst[2:0];
				  enable[35] = 1'b1;
				  
				  async_set[D] = 1'b1; //set dependency
				  async_dep[D] = 1'b1; //be added as dependency
				  
			 end else if ((inst & MASK_MOVLZ) == EXPECTED_MOVLZ) begin
				  B = inst[10:3];
				  D = inst[2:0];
				  enable[36] = 1'b1;
				  
				  async_set[D] = 1'b1; //set dependency
				  
			 end else if ((inst & MASK_MOVLS) == EXPECTED_MOVLS) begin
				  B = inst[10:3];
				  D = inst[2:0];
				  enable[37] = 1'b1;
				  
				  async_set[D] = 1'b1; //set dependency
				  
			 end else if ((inst & MASK_MOVH) == EXPECTED_MOVH) begin
				  B = inst[10:3];
				  D = inst[2:0];
				  enable[38] = 1'b1;

				  async_set[D] = 1'b1; //set dependency
				  async_dep[D] = 1'b1; //be added as dependency
				  
			 end else if ((inst & MASK_LDR) == EXPECTED_LDR) begin
				  OFF = inst[13:7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[39] = 1'b1;
				  
				  async_dep[S] = 1'b1; //be added as dependency

				  async_set[D] = 1'b1; //set dependency
				  
			 end else if ((inst & MASK_STR) == EXPECTED_STR) begin
				  OFF = inst[13:7];
				  WB = inst[6];
				  S = inst[5:3];
				  D = inst[2:0];
				  enable[40] = 1'b1;
				  
				  async_dep[S] = 1'b1; //be added as dependency

				  async_dep[D] = 1'b1; //be added as dependency
				  
			 end
		 end else begin
		    enable = 41'b0;
		 end
	end
endmodule
