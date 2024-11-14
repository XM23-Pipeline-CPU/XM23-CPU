#include "cpu.h"
#include "XMPrint.h"
#include "instructions.h"
#include <stdio.h>
#include <stdbool.h>

// regfile[0][#] contains registers R0 - R7
// regfile[1][#] contains predefined constants 0, 1, 2, 4, 8, 16, 32, -1
word_byte_nibble regfile[REG_OR_CONST][REGCOUNT] = { {0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000} \
												 , {0x0000, 0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0xFFFF} };
word_byte_nibble inst_reg = { 0 };


psw_reg PSW;
unsigned short carry[2][2][2];		//How to set carry bit based on SRC, DST, RES
unsigned short overflow[2][2][2];	//How to set overflow bit based on SRC, DST, RES

//Initializes PSW bits to zero and sets the conditions for carry and overflow bits
void init_PSW(void)
{
	PSW.c = 0;
	PSW.cp = 4;
	PSW.v = 0;
	PSW.n = 0;
	PSW.slp = 0;
	PSW.flt = 0;
	PSW.z = 0;
	PSW.pp = 0;
	PSW.reserved = 0;

	//Credit to Dr. Larry Hughes for defining set conditions array
	carry[0][0][0] = 0;
	carry[0][0][1] = 0;
	carry[0][1][0] = 1;
	carry[0][1][1] = 0;
	carry[1][0][0] = 1;
	carry[1][0][1] = 0;
	carry[1][1][0] = 1;
	carry[1][1][1] = 1;

	//Credit to Dr. Larry Hughes for defining set conditions array
	overflow[0][0][0] = 0;
	overflow[0][0][1] = 1;
	overflow[0][1][0] = 0;
	overflow[0][1][1] = 0;
	overflow[1][0][0] = 0;
	overflow[1][0][1] = 0;
	overflow[1][1][0] = 1;
	overflow[1][1][1] = 0;
	
	return;
}

//fetch instruction. Tests for interrupt related checks, and fetches
void fetch(void)
{
	test_for_ISR_exit();
	test_for_cex();
	if (PC.w % 2 != 0)
		ISR(ILL_ADD, FAULT);
	cache_func(PC.w, &IR, READ, WORD);
	return;
}


/// <summary>
/// Will decode opcode to know which instruction was sent
/// Will call the correct function to execute that instruction
/// </summary>
/// <param name="inst"></param>
void decode_inst(unsigned short inst)
{
	// The following switch function decodes instructions using sequential and nested bitmasks
	switch (BITS13TO15(inst))		//mask 3MSBits
	{
	case BITS13TO15(BL_OP):					//BL
		exec_BL(inst);
		return;
	case OTHER_BRANCH:		//Other Branching instructions
		switch (BITS10TO12(inst))	//mask next three MSBits
		{
		case BITS10TO12(BEQ_OP):			//BEQ
			exec_BEQ(inst);
			return;
		case BITS10TO12(BNE_OP):			//BNE
			exec_BNE(inst);
			return;
		case BITS10TO12(BC_OP):				//BC
			exec_BC(inst);
			return;
		case BITS10TO12(BNC_OP):			//BNC
			exec_BNC(inst);
			return;
		case BITS10TO12(BN_OP):				//BN
			exec_BN(inst);
			return;
		case BITS10TO12(BGE_OP):			//BGE
			exec_BGE(inst);
			return;
		case BITS10TO12(BLT_OP):			//BLT
			exec_BLT(inst);
			return;
		case BITS10TO12(BRA_OP):			//BRA
			exec_BRA(inst);
			return;
		default:
			ISR(ILL_INST, FAULT);	//illegal instruction detected - exception handler called
		}
		return;
	case TWO_REG_ARITH:		//Two register arithmetic and logic instructions
		switch (BITS8TO12(inst))	//Mask bits 7 - 11
		{
		case BITS8TO12(ADD_OP):				//ADD
			exec_ADD(inst);
			return;
		case BITS8TO12(ADDC_OP):			//ADDC
			exec_ADDC(inst);
			return;
		case BITS8TO12(SUB_OP):				//SUB
			exec_SUB(inst);
			return;
		case BITS8TO12(SUBC_OP):			//SUBC
			exec_SUBC(inst);
			return;
		case BITS8TO12(DADD_OP):			//DADD
			exec_DADD(inst);
			return;
		case BITS8TO12(CMP_OP):				//CMP
			exec_CMP(inst);
			return;
		case BITS8TO12(XOR_OP):				//XOR
			exec_XOR(inst);
			return;
		case BITS8TO12(AND_OP):				//AND
			exec_AND(inst);
			return;
		case BITS8TO12(OR_OP):				//OR
			exec_OR(inst);
			return;
		case BITS8TO12(BIT_OP):				//BIT
			exec_BIT(inst);
			return;
		case BITS8TO12(BIC_OP):				//BIC
			exec_BIC(inst);
			return;
		case BITS8TO12(BIS_OP):				//BIS
			exec_BIS(inst);
			return;
		case MOV_SWAP_INST:			//Goes into MOV and SWAP
			switch (BIT7(inst))
			{
			case BIT7(MOV_OP):				//MOV
				exec_MOV(inst);
				return;
			case BIT7(SWAP_OP):				//SWAP
				exec_SWAP(inst);
				return;
			default:
				ISR(ILL_INST, FAULT);	//illegal instruction detected - exception handler called
			}
			return;
		case SRA_THRU_CLRCC:			//Goes into SRA - CLRCC
			switch (BITS7_5_4_3(inst))	
			{
			case BITS7_5_4_3(SRA_OP):		//SRA
				exec_SRA(inst);
				return;
			case BITS7_5_4_3(RRC_OP):		//RRC
				exec_RRC(inst);
				return;
			case BITS7_5_4_3(COMP_OP):		//COMP
				exec_COMP(inst);
				return;
			case BITS7_5_4_3(SWPB_OP):		//SWPB
				exec_SWPB(inst);
				return;
			case BITS7_5_4_3(SXT_OP):		//SXT
				exec_SXT(inst);
				return;
			default:		// SETPRI to CLRCC
				switch (BITS5TO6(inst))
				{
				case SETPRI_OR_SVC:
					switch (BIT4(inst))
					{
					case BIT4(SETPRI_OP):
						exec_SETPRI(inst);
						return;
					case BIT4(SVC_OP):
						exec_SVC(inst);
						return;
					default:
						ISR(ILL_INST, FAULT);	//illegal instruction detected - exception handler called
					}
					return;
				case BITS5TO6(SETCC_OP):	//SETCC
					exec_SETCC(inst);
					return;
				case BITS5TO6(CLRCC_OP):	//CLRCC
					exec_CLRCC(inst);
					return;
				default:
					ISR(ILL_INST, FAULT);	//illegal instruction detected - exception handler called
				}
			}
			return;
		default:					//Goes into remaining instructions with Bits 15 to 13 at 010 (CEX, LD, ST).
			switch (BITS10TO12(inst))
			{
			case BITS10TO12(CEX_OP):		//CEX
				exec_CEX(inst);
				return;
			case BITS10TO12(LD_OP):			//LD
				exec_LD(inst);
				return;
			case BITS10TO12(ST_OP):			//ST
				exec_ST(inst);
				return;
			default:
				ISR(ILL_INST, FAULT);	//illegal instruction detected - exception handler called
			}
		}
		return;
	case MOVE_INST:			//MOVE INSTUCTIONS
		switch (BITS11TO12(inst))
		{
		case BITS11TO12(MOVL_OP):
			exec_MOVL(inst);				//MOVL
			return;
		case BITS11TO12(MOVLZ_OP):
			exec_MOVLZ(inst);				//MOVLZ
			return;
		case BITS11TO12(MOVLS_OP):
			exec_MOVLS(inst);				//MOVLS
			return;
		case BITS11TO12(MOVH_OP):
			exec_MOVH(inst);				//MOVH
			return;
		default:
			ISR(ILL_INST, FAULT);	//illegal instruction detected - exception handler called
		}
		return;
	case LDR_DONTCARE0:				//LDR with a dont care in the 13th bit
	case LDR_DONTCARE1:				//LDR with a dont care in the 13th bit
		exec_LDR(inst);
		return;
	case STR_DONTCARE0:				//STR with a dont care in the 13th bit
	case STR_DONTCARE1:				//STR with a dont care in the 13th bit
		exec_STR(inst);
		return;
	default:
		ISR(ILL_INST, FAULT);	//illegal instruction detected - exception handler called
	}
	return;
}

//BL calculates its own offset without a function as its the only instructions with 13 offset bits
void exec_BL(unsigned short inst)
{
	CEX.on = 0;
	if (inst == 0)	//Either BL with offset 0 or no instruction, either way we can return
		return;
	
	//printf("PC: %04x    INST: %04x    TYPE: BL\n", PC.w - 2, inst);
	print_inst(BL_INFO, inst);
	unsigned short offset;
	//perform sign extension
	if (BIT12(inst))	//if 12th bit is 1
		offset = BL_SET_NEG(inst);
	else							//if 12th bit is 0
		offset = BL_SET_POS(inst);
	
	offset <<= 1;	//shift offset by 1 bit to left (multiply by 2)
	LR.w = PC.w;	//set link register to program counter before changing PC
	PC.w += offset;
	return;
}

void exec_BEQ(unsigned short inst)
{
	CEX.on = 0;
	//printf("PC: %04x    INST: %04x    TYPE: BEQ\n", PC.w - 2, inst);
	print_inst(BEQ_INFO, inst);
	if (PSW.z == 1)				//if zero bit is set
		branch_offset(inst);
	return;
}

void exec_BNE(unsigned short inst)
{
	CEX.on = 0;
	//printf("PC: %04x    INST: %04x    TYPE: BNE\n", PC.w - 2, inst);
	print_inst(BNE_INFO, inst);
	if (PSW.z == 0)				//if zero bit is not set
		branch_offset(inst);
	return;
}

void exec_BC(unsigned short inst)
{
	CEX.on = 0;
	//printf("PC: %04x    INST: %04x    TYPE: BC\n", PC.w - 2, inst);
	print_inst(BC_INFO, inst);

	if (PSW.c == 1)				//if carry bit is set
		branch_offset(inst);
	return;
}

void exec_BNC(unsigned short inst)
{
	CEX.on = 0;
	//printf("PC: %04x    INST: %04x    TYPE: BNC\n", PC.w - 2, inst);
	print_inst(BNC_INFO, inst);

	if (PSW.c == 0)				//if carry bit is not set
		branch_offset(inst);
	return;
}

void exec_BN(unsigned short inst)
{
	CEX.on = 0;
	//printf("PC: %04x    INST: %04x    TYPE: BN\n", PC.w - 2, inst);
	print_inst(BN_INFO, inst);

	if (PSW.n == 1)				//if negative bit is set
		branch_offset(inst);
	return;
}

void exec_BGE(unsigned short inst)
{
	CEX.on = 0;
	//printf("PC: %04x    INST: %04x    TYPE: BGE\n", PC.w - 2, inst);
	print_inst(BGE_INFO, inst);

	if ((PSW.n ^ PSW.v) == 0)	//if negative and overflow bits are the same
		branch_offset(inst);
	return;
}

void exec_BLT(unsigned short inst)
{
	CEX.on = 0;
	//printf("PC: %04x    INST: %04x    TYPE: BLT\n", PC.w - 2, inst);
	print_inst(BLT_INFO, inst);

	if ((PSW.n ^ PSW.v) == 1)	//if negative and overflow bits are different
		branch_offset(inst);
	return;
}

void exec_BRA(unsigned short inst)
{
	CEX.on = 0;
	//printf("PC: %04x    INST: %04x    TYPE: BRA\n", PC.w - 2, inst);
	print_inst(BRA_INFO, inst);

	branch_offset(inst);		//branches always
	return;
}

void exec_ADD(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: ADD\n", PC.w - 2, inst);
	print_inst(ADD_INFO, inst);

		
	//destination = exec_Addition(destination, source, carry, wordbyte);
	word_byte_nibble result;
	word_byte_nibble dst = regfile[0][DST(inst)];
	word_byte_nibble src = regfile[RC(inst)][SRC(inst)];

	result = exec_ADDITION(dst, src, 0, WB(inst));		//calls function that performs all addition of form res = dst + src + carry

	if (WB(inst) == WORD)	//WORD
		regfile[0][DST(inst)] = result;
	else				//BYTE
		regfile[0][DST(inst)].b[0] = result.b[0];

	update_PSW(result, dst, src, WB(inst));				//called to update PSW bits
	return;
}

void exec_ADDC(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: ADDC\n", PC.w - 2, inst);
	print_inst(ADDC_INFO, inst);

	word_byte_nibble result;
	word_byte_nibble dst = regfile[0][DST(inst)];
	word_byte_nibble src = regfile[RC(inst)][SRC(inst)];

	result = exec_ADDITION(dst, src, PSW.c, WB(inst));	//calls function that performs all addition of form res = dst + src + carry
	
	if (WB(inst) == WORD)	//WORD
		regfile[0][DST(inst)] = result;
	else				//BYTE
		regfile[0][DST(inst)].b[0] = result.b[0];

	update_PSW(result, dst, src, WB(inst));				//called to update PSW bits
	return;
}

void exec_SUB(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: SUB\n", PC.w - 2, inst);
	print_inst(SUB_INFO, inst);

		
	word_byte_nibble compsrc;
	word_byte_nibble dst = regfile[0][DST(inst)];
	word_byte_nibble src = regfile[RC(inst)][SRC(inst)];
	word_byte_nibble result;

	compsrc.w = ~regfile[RC(inst)][SRC(inst)].w;
	result = exec_ADDITION(dst, compsrc, 1, WB(inst));		//Add function takes in 1's compliment of SRC

	if (WB(inst) == WORD)	//WORD
		regfile[0][DST(inst)] = result;
	else				//BYTE
		regfile[0][DST(inst)].b[0] = result.b[0];

	compsrc.w += 1;		//sending in the two's compliment

	update_PSW(result, dst, compsrc, WB(inst));				//Update PSW bits
	return;
}

void exec_SUBC(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: SUBC\n", PC.w - 2, inst);
	print_inst(SUBC_INFO, inst);

		
	word_byte_nibble compsrc;
	word_byte_nibble dst = regfile[0][DST(inst)];
	word_byte_nibble src = regfile[RC(inst)][SRC(inst)];
	word_byte_nibble result;

	compsrc.w = ~regfile[RC(inst)][SRC(inst)].w;
	result = exec_ADDITION(dst, compsrc, PSW.c, WB(inst));

	if (WB(inst) == WORD)	//WORD
		regfile[0][DST(inst)] = result;
	else				//BYTE
		regfile[0][DST(inst)].b[0] = result.b[0];

	compsrc.w += PSW.c;

	update_PSW(result, dst, compsrc, WB(inst));				//Update PSW bits
	return;
}

void exec_DADD(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: DADD\n", PC.w - 2, inst);
	print_inst(DADD_INFO, inst);

	int temp = 0;		//temp variable used to avoid overflow when doing nibble arithmatics
	word_byte_nibble res, dst, src;
	dst = regfile[0][DST(inst)];
	src = regfile[RC(inst)][SRC(inst)];
	unsigned short HC = 0;
	if (WB(inst) == WORD)		//WORD
	{
		temp = dst.nib.n0 + src.nib.n0 + HC;	//temp = addition of least sig Nibbles
		if (temp > 9)	//if greater than 9 (because in BCD)
		{
			temp -= 10;	//decrement by 10
			HC = 1;		//set half carry
		}
		else
			HC = 0;		//clear half carry
		res.nib.n0 = temp;	//set lowest sig nibble of result to temp variable
		temp = 0;

		temp = dst.nib.n1 + src.nib.n1 + HC;	//addition of 1st nibbles
		if (temp > 9)
		{
			temp -= 10;
			HC = 1;
		}
		else
			HC = 0;
		res.nib.n1 = temp;
		temp = 0;

		temp = dst.nib.n2 + src.nib.n2 + HC;	//addition of 2nd nibbles
		if (temp > 9)
		{
			temp -= 10;
			HC = 1;
		}
		else
			HC = 0;
		res.nib.n2 = temp;
		temp = 0;

		temp = dst.nib.n3 + src.nib.n3 + HC;	//addition of most sig nibbles
		if (temp > 9)
		{
			temp -= 10;
			HC = 1;
		}
		else
			HC = 0;

		res.nib.n3 = temp;

		PSW.c = HC;								//set total carry to last half carry
		regfile[0][DST(inst)] = res;			//set register equal to result
		
	}
	else					//BYTE
	{
		temp = dst.nib.n0 + src.nib.n0 + HC;	//addition of least sig nibbles
		if (temp > 9)
		{
			temp -= 10;
			HC = 1;
		}
		else
			HC = 0;
		res.nib.n0 = temp;
		temp = 0;

		temp = dst.nib.n1 + src.nib.n1 + HC;	//addition of most sig nibbles
		if (temp > 9)
		{
			temp -= 10;
			HC = 1;
		}
		else
			HC = 0;
		res.nib.n1 = temp;

		PSW.c = HC;								//set total carry to last half carry
		regfile[0][DST(inst)].b[0] = res.b[0];	//set register equal to result
	}

	update_PSW_other(res.w, WB(inst));			//update PSW (non arithmetic format function)
	return;
}

void exec_CMP(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: CMP\n", PC.w - 2, inst);
	print_inst(CMP_INFO, inst);

	word_byte_nibble compsrc;
	word_byte_nibble dst = regfile[0][DST(inst)];
	//word_byte_nibble src = regfile[RC(inst)][SRC(inst)];
	word_byte_nibble result;

	compsrc.w = ~regfile[RC(inst)][SRC(inst)].w;		//set variable to 1's compliment of src
	result = exec_ADDITION(dst, compsrc, 1, WB(inst));	//addition with 1's comp of src

	compsrc.w += 1;
	
	update_PSW(result, dst, compsrc, WB(inst));
	return;
}

void exec_XOR(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: XOR\n", PC.w - 2, inst);
	print_inst(XOR_INFO, inst);

	unsigned short dst = DST(inst);	//used for optimization
	word_byte_nibble result;
	if (WB(inst) == WORD)		//WORD
	{
		result.w = regfile[0][dst].w ^ regfile[RC(inst)][SRC(inst)].w;			//XOR words
		update_PSW(result, regfile[0][dst], regfile[RC(inst)][SRC(inst)], 0);	//update PSW
		regfile[0][dst].w = result.w;											//set dst register to result
	}
	else					//BYTE
	{
		result.b[0] = regfile[0][dst].b[0] ^ regfile[RC(inst)][SRC(inst)].b[0];	//XOR bytes
		update_PSW(result, regfile[0][dst], regfile[RC(inst)][SRC(inst)], 1);	//update PSW
		regfile[0][dst].b[0] = result.b[0];										//set dst register to result
	}
	return;
}

void exec_AND(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: AND\n", PC.w - 2, inst);
	print_inst(AND_INFO, inst);

	unsigned short dst = DST(inst);	//used for optimization
	word_byte_nibble result;
	if (WB(inst) == WORD)		//WORD
	{
		result.w = regfile[0][dst].w & regfile[RC(inst)][SRC(inst)].w;			//bitwise AND words
		update_PSW(result, regfile[0][dst], regfile[RC(inst)][SRC(inst)], 0);	//update PSW
		regfile[0][dst].w = result.w;											//set dst register to result
	}
	else					//BYTE
	{
		result.b[0] = regfile[0][dst].b[0] & regfile[RC(inst)][SRC(inst)].b[0];	//bitwise AND bytes
		update_PSW(result, regfile[0][dst], regfile[RC(inst)][SRC(inst)], 1);	//update PSW
		regfile[0][dst].b[0] = result.b[0];										//set dst register to result
	}
	return;
}

void exec_OR(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: OR\n", PC.w - 2, inst);
	print_inst(OR_INFO, inst);

	unsigned short dst = DST(inst);	//used for optimization
	word_byte_nibble result;
	if (WB(inst) == WORD)		//WORD
	{
		result.w = regfile[0][dst].w | regfile[RC(inst)][SRC(inst)].w;			//bitwise OR words
		update_PSW(result, regfile[0][dst], regfile[RC(inst)][SRC(inst)], 0);	//update PSW
		regfile[0][dst].w = result.w;											//set dst register to result
	}
	else					//BYTE
	{
		result.b[0] = regfile[0][dst].b[0] | regfile[RC(inst)][SRC(inst)].b[0];	//bitwise OR bytes
		update_PSW(result, regfile[0][dst], regfile[RC(inst)][SRC(inst)], 1);	//update PSW
		regfile[0][dst].b[0] = result.b[0];										//set dst register to result
	}
	return;
}

void exec_BIT(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: BIT\n", PC.w - 2, inst);
	print_inst(BIT_INFO, inst);

	word_byte_nibble result;
	if (WB(inst) == WORD)		//WORD
		result.w = regfile[0][DST(inst)].w & regfile[RC(inst)][SRC(inst)].w;	//result is dst anded with src bit mask
	else					//BYTE
		result.b[0] = regfile[0][DST(inst)].b[0] & regfile[RC(inst)][SRC(inst)].b[0];
	
	update_PSW_other(result.w, WB(inst));	//update PSW (non arith format)
	return;
}

void exec_BIC(unsigned short inst)
{
	//If we clear the MSB we can also clear psw.n
	//If we clear any other bit then we have to check if the result is zero and if so set the psw.z bit
	//printf("PC: %04x    INST: %04x    TYPE: BIC\n", PC.w - 2, inst);
	print_inst(BIC_INFO, inst);

	if (WB(inst) == WORD)		//WORD
		regfile[0][DST(inst)].w &= ~(1 << regfile[RC(inst)][SRC(inst)].w);	//result is anded with the compliment of (0x01 shifted by src)
	else					//BYTE
		regfile[0][DST(inst)].b[0] &= ~(1 << regfile[RC(inst)][SRC(inst)].b[0]);
	
	update_PSW_other(regfile[0][DST(inst)].w, WB(inst)); //update PSW (non arith format)
	return;
}

void exec_BIS(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: BIS\n", PC.w - 2, inst);
	print_inst(BIS_INFO, inst);

	//if we set the msb then we can set the psw.n bit.
	//if we set any other bit then we can clear the psw.z bit.
	if (WB(inst) == WORD)		//WORD
	{
		regfile[0][DST(inst)].w |= (1 << regfile[RC(inst)][SRC(inst)].w);	//result is ored with (0x01 shifted by src)
		if (BIT15(regfile[0][DST(inst)].w) == 0)	//if result's MSB is 0
			PSW.n = 0;	//"non negative" flag
		else										//if result's MSB is 1
			PSW.n = 1;	//negative flag
	}
	else			//BYTE
	{
		regfile[0][DST(inst)].b[0] |= (1 << regfile[RC(inst)][SRC(inst)].b[0]);
		if (BIT7(regfile[0][DST(inst)].b[0]) == 0)	//if result's MSB is 0
			PSW.n = 0;
		else										//if result's MSB is 1
			PSW.n = 1;
	}
	PSW.z = 0;		//clear zero bit no matter what
	return;
}

void exec_MOV(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: MOV\n", PC.w - 2, inst);
	print_inst(MOV_INFO, inst);

	if (WB(inst) == WORD)	//WORD
		regfile[0][DST(inst)].w = regfile[0][SRC(inst)].w;		//set DST to SRC
	else				//BYTE
		regfile[0][DST(inst)].b[0] = regfile[0][SRC(inst)].b[0];
	return;
}

void exec_SWAP(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: SWAP\n", PC.w - 2, inst);
	print_inst(SWAP_INFO, inst);

	word_byte_nibble temp;
	temp = regfile[0][DST(inst)];	//temp set to DST
	regfile[0][DST(inst)] = regfile[0][SRC(inst)];	//DST set to SRC
	regfile[0][SRC(inst)] = temp;	//SRC set to temp
	return;
}

void exec_SRA(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: SRA\n", PC.w - 2, inst);
	print_inst(SRA_INFO, inst);

	unsigned short dst = DST(inst);	//used for optimization
	if (WB(inst) == WORD)	//WORD
	{
		PSW.c = LSB(regfile[0][dst].w);		//save LSB in carry bit
		regfile[0][dst].w >>= 1;			//shift right
		if (BIT14(regfile[0][dst].w) != 0)	//if MSB (shifted) is 1, sign extend
			regfile[0][dst].w |= 0x8000;	//sign extension
		//if 0 is implied because that bit is set to 0 by the shift
	}
	else				//BYTE
	{
		PSW.c = LSB(regfile[0][dst].b[0]);	//save LSB in carry bit
		regfile[0][dst].b[0] >>= 1;			//shift right
		if (BIT6(regfile[0][dst].b[0]) != 0)//if MSB (shifted) is 1, sign extend
			regfile[0][dst].w |= 0x0080;	//sign extension
		//if 0 is implied because that bit is set to 0 by the shift
	}
	return;
}

void exec_RRC(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: RRC\n", PC.w - 2, inst);
	print_inst(RRC_INFO, inst);

	unsigned short dst = DST(inst);	//used for optimization
	word_byte_nibble temp;
	temp.w = LSB(PSW.c);	//save current carry into temp register
	if (WB(inst) == WORD)		//word
	{
		PSW.c = LSB(regfile[0][dst].w);		//save LSB into carry.
		regfile[0][dst].w >>= 1;			//shift all bits right 1
		temp.w <<= 15;						//Make the saved carry the MSBit
		temp.w |= 0x7FFF;					//Force all bits to one other than carry
		regfile[0][dst].w &= temp.w;		//save the MSBit in regfile
	}
	else
	{
		PSW.c = LSB(regfile[0][dst].w);		//save LSB into carry.
		regfile[0][dst].b[0] >>= 1;			//shift all bits in lower byte right 1
		temp.b[0] <<= 7;					//Make the saved carry the MSBit
		temp.b[0] |= 0x007F;				//Force all bits in lower byte to one other than carry
		regfile[0][dst].b[0] &= temp.b[0];	//save the MSBit in regfile
	}
	return;
}

void exec_COMP(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: COMP\n", PC.w - 2, inst);
	print_inst(COMP_INFO, inst);

	if(WB(inst) == WORD)	//WORD
		regfile[0][DST(inst)].w = ~regfile[0][DST(inst)].w;	//DST set to 1's compliment of DST
	else				//BYTE
		regfile[0][DST(inst)].b[0] = ~regfile[0][DST(inst)].b[0];
	return;
}

void exec_SWPB(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: SWPB\n", PC.w - 2, inst);
	print_inst(SWPB_INFO, inst);

	unsigned short dst = DST(inst);	//used for optimization
	word_byte_nibble temp;
	temp.b[0] = regfile[0][dst].b[0];				//temp byte = dst byte
	regfile[0][dst].b[0] = regfile[0][dst].b[1];	//dst byte = src byte
	regfile[0][dst].b[1] = temp.b[0];				//src byte = temp byte
	return;
}

void exec_SXT(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: SXT\n", PC.w - 2, inst);
	print_inst(SXT_INFO, inst);

	if (BIT7(regfile[0][DST(inst)].w) == 0)
		regfile[0][DST(inst)].b[1] = BYTE_CLEARED;	//set MSByte to 0
	else
		regfile[0][DST(inst)].b[1] = BYTE_SET;		//set MSByte to 1
	return;
}

void exec_SETPRI(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: SETPRI\n", PC.w - 2, inst);
	print_inst(SETPRI_INFO, inst);

	unsigned short new_prio = MS3BITS(inst);
	if (new_prio > PSW.cp || new_prio < PSW.pp)
		ISR(PRI_FAULT, FAULT);
	else
		PSW.cp = new_prio;
	return;
}

void exec_SVC(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: SVC\n", PC.w - 2, inst);
	print_inst(SVC_INFO, inst);

	unsigned short shift = MS4BITS(inst);
	unsigned short vector = BASE_IVT + (4 * shift);
	ISR(vector, NOT_FAULT);
	return;
}

//set PSW bits as specified by instruction. If sleep is 7, clear it, else, set it
void exec_SETCC(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: SETCC\n", PC.w - 2, inst);
	print_inst(SETCC_INFO, inst);

	PSW.c |= inst & 0x01;
	PSW.z |= (inst >> 1) & 0x01;
	PSW.n |= (inst >> 2) & 0x01;
	if (PSW.cp != 7) PSW.slp |= (inst >> 3) & 0x01;
	else PSW.slp = 0;
	PSW.v |= (inst >> 4) & 0x01;
	return;
}

//clear PSW bits as specified by instruction. Sleep can always be cleared regardless of priority
void exec_CLRCC(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: CLRCC\n", PC.w - 2, inst);
	print_inst(CLRCC_INFO, inst);

	PSW.c &= ~inst & 0x01;
	PSW.z &= ~(inst >> 1) & 0x01;
	PSW.n &= ~(inst >> 2) & 0x01;
	PSW.slp &= ~(inst >> 3) & 0x01;
	PSW.v &= ~(inst >> 4) & 0x01;
	return;
}

void exec_CEX(unsigned short inst)
{
	CEX.on = 1;
	CEX.cond = 0;
	CEX.tru = (inst >> 3) & 0x07;
	CEX.fls = inst & 0x07;
	unsigned short code = (inst >> 6) & 0x0F;
	//printf("PC: %04x    INST: %04x    TYPE: CEX\n", PC.w - 2, inst);
	print_inst(CEX_INFO, inst);

		
	switch (code)
	{
	case EQ:
		if (PSW.z == 1)
			CEX.cond = 1;
		break;
	case NE:
		if (PSW.z == 0)
			CEX.cond = 1;
		break;
	case CS:
		if (PSW.c == 1)
			CEX.cond = 1;
		break;
	case CC:
		if (PSW.c == 0)
			CEX.cond = 1;
		break;
	case MI:
		if (PSW.n == 1)
			CEX.cond = 1;
		break;
	case PL:
		if (PSW.n == 0)
			CEX.cond = 1;
		break;
	case VS:
		if (PSW.v == 1)
			CEX.cond = 1;
		break;
	case VC:
		if (PSW.v == 0)
			CEX.cond = 1;
		break;
	case HI:
		if (PSW.c == 1 && PSW.z == 0)
			CEX.cond = 1;
		break;
	case LS:
		if (PSW.c == 0 || PSW.z == 1)
			CEX.cond = 1;
		break;
	case GE:
		if (PSW.n == PSW.v)
			CEX.cond = 1;
		break;
	case LT:
		if (PSW.n != PSW.v)
			CEX.cond = 1;
		break;
	case GT:
		if (PSW.z == 0 && PSW.n == PSW.v)
			CEX.cond = 1;
		break;
	case LE:
		if (PSW.z == 1 || PSW.n != PSW.v)
			CEX.cond = 1;
		break;
	case TR:
		CEX.cond = 1;
		break;
	case FL:
		break;
	default:
		__assume(false);
	}
		
	return;
}

void exec_LD(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: LD\n", PC.w - 2, inst);
	print_inst(LD_INFO, inst);

	unsigned short src = SRC(inst);		//used for optimization
	if (WB(inst) == WORD)	//WORD
	{
		// Pre increments or decrements if necessary -- DATA DRIVEN
		regfile[0][src].w += (2 * PRPO(inst) * (INC(inst) - DEC(inst)));
		// Loads data into DST register.
		//regfile[0][DST(inst)].w = mem.w[regfile[0][src].w >> 1];
		cache_func(regfile[0][src].w, &regfile[0][DST(inst)].w, READ, WORD);
		// Post incremements or decrements if necessary -- DATA DRIVEN
		regfile[0][src].w += (2 * PRPO(~inst) * (INC(inst) - DEC(inst)));
	}
	else				//BYTE
	{
		regfile[0][src].w += (PRPO(inst) * (INC(inst) - DEC(inst)));
		//regfile[0][DST(inst)].b[0] = mem.b[regfile[0][src].w];
		cache_func(regfile[0][src].w, &regfile[0][DST(inst)].b[0], READ, BYTE);
		regfile[0][src].w += (PRPO(~inst) * (INC(inst) - DEC(inst)));
	}
	return;
}

void exec_ST(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: ST\n", PC.w - 2, inst);
	print_inst(ST_INFO, inst);

	unsigned short dst = DST(inst);		//used

	if (WB(inst) == WORD)	//WORD
	{
		// Pre increments or decrements if necessary -- DATA DRIVEN
		regfile[0][dst].w += (2 * PRPO(inst) * (INC(inst) - DEC(inst)));
		// Loads data into DST register.
		//mem.w[regfile[0][dst].w >> 1] = regfile[0][SRC(inst)].w;
		cache_func(regfile[0][dst].w, &regfile[0][SRC(inst)].w, WRITE, WORD);
		// Post incremements or decrements if necessary -- DATA DRIVEN
		regfile[0][dst].w += (2 * PRPO(~inst) * (INC(inst) - DEC(inst)));
	}
	else				//BYTE
	{
		regfile[0][dst].w += (PRPO(inst) * (INC(inst) - DEC(inst)));
		//mem.b[regfile[0][dst].w] = regfile[0][SRC(inst)].b[0];
		cache_func(regfile[0][dst].w, &regfile[0][SRC(inst)].b[0], WRITE, BYTE);
		regfile[0][dst].w += (PRPO(~inst) * (INC(inst) - DEC(inst)));
	}
	return;
}

void exec_MOVL(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: MOVL\n", PC.w - 2, inst);
	print_inst(MOVL_INFO, inst);

	regfile[0][DST(inst)].b[0] = MVBYTE(inst);	//set lower byte to encoded data, ignore high byte
	return;
}

void exec_MOVLZ(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: MOVLZ\n", PC.w - 2, inst);
	print_inst(MOVLZ_INFO, inst);

	regfile[0][DST(inst)].w = MVBYTE(inst);		//set lower byte to encoded data, clear higher byte
	return;
}

void exec_MOVLS(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: MOVLS\n", PC.w - 2, inst);
	print_inst(MOVLS_INFO, inst);

	regfile[0][DST(inst)].b[0] = MVBYTE(inst);	//set lower byte to encoded data
	regfile[0][DST(inst)].b[1] = BYTE_SET;		//set high byte
	return;
}

void exec_MOVH(unsigned short inst)
{
	//printf("PC: %04x    INST: %04x    TYPE: MOVH\n", PC.w - 2, inst);
	print_inst(MOVH_INFO, inst);

	regfile[0][DST(inst)].b[1] = MVBYTE(inst);	//set high byte to encoded data, ignore low byte
	return;
}

void exec_LDR(unsigned short inst)
{
	unsigned short offset = LDOFFSET(inst);

	//printf("PC: %04x    INST: %04x    TYPE: LDR\n", PC.w - 2, inst);
	print_inst(LDR_INFO, inst);

	if (WB(inst) == WORD)	//WORD
	{
		offset >>= 1;
		if (BIT5(offset))					//if 5th bit is 1
			OFF_SETNEG_W(offset);			//sign extend offset to negative
		else								//if 5th bit is 0
			OFF_SETPOS_W(offset);			//sign extend offset to positive
		// Loads data into DST register.
		//regfile[0][DST(inst)].w = mem.w[(regfile[0][SRC(inst)].w >> 1) + offset];
		cache_func((regfile[0][SRC(inst)].w >> 1) + offset << 1, &regfile[0][DST(inst)].w, READ, WORD);
	}
	else					//BYTE
	{
		if (BIT6(offset))					//if 6th bit is 1
			OFF_SETNEG_B(offset);			//sign extend offset to negative
		else								//if 6th bit is 0
			OFF_SETPOS_B(offset);			//sign extend offset to positive
		//regfile[0][DST(inst)].b[0] = mem.b[regfile[0][SRC(inst)].w + offset];
		cache_func(regfile[0][SRC(inst)].w + offset, &regfile[0][DST(inst)].b[0], READ, BYTE);
	}
	return;
}

void exec_STR(unsigned short inst)
{
	unsigned short offset = LDOFFSET(inst);
	//printf("PC: %04x    INST: %04x    TYPE: STR\n", PC.w - 2, inst);
	print_inst(STR_INFO, inst);

	if (WB(inst) == WORD)	//WORD
	{
		offset >>= 1;
		if (BIT5(offset))					//if 5th bit is 1
			OFF_SETNEG_W(offset);			//sign extend offset to negative
		else								//if 5th bit is 0
			OFF_SETPOS_W(offset);			//sign extend offset to positive
		// Loads data into DST register.
		//mem.w[(regfile[0][DST(inst)].w >> 1) + offset] = regfile[0][SRC(inst)].w;
		cache_func((regfile[0][DST(inst)].w) + offset << 1, &regfile[0][SRC(inst)].w, WRITE, WORD);
	}
	else				//BYTE
	{
		if (BIT6(offset))					//if 6th bit is 1
			OFF_SETNEG_B(offset);			//sign extend offset to negative
		else								//if 6th bit is 0
			OFF_SETPOS_B(offset);			//sign extend offset to positive
		//mem.b[regfile[0][DST(inst)].w + offset] = regfile[0][SRC(inst)].b[0];
		cache_func(regfile[0][DST(inst)].w + offset, &regfile[0][SRC(inst)].b[0], WRITE, BYTE);
	}
	return;
}

// Performs "Addition" for all functions that use the format [RES] <- [DST] [+/-] [SRC] + [Carry]
word_byte_nibble exec_ADDITION(word_byte_nibble dst, word_byte_nibble src, unsigned short carry, unsigned short wb)
{
	word_byte_nibble res;
	if (wb == 0)	//WORD
		res.w = dst.w + src.w + carry; //[RES] <- [DST] [+/ -] [SRC] + [Carry]
	else			//BYTE
		res.b[0] = dst.b[0] + src.b[0] + carry;
	return res;
}

// Updates the PSW when called by all arithmetic functions and all other functions
// that use the format of [RES] <- [DST] [+/-] [SRC] + [Carry]
void update_PSW(word_byte_nibble res, word_byte_nibble dst, word_byte_nibble src, unsigned short wb)
{
	//used for optimization
	if (wb == 0)	//word
	{
		unsigned short bit15_src = BIT15(src.w);	//MSBit of src
		unsigned short bit15_dst = BIT15(dst.w);	//MSBit of dst
		unsigned short bit15_res = BIT15(res.w);	//MSBit of res
		PSW.v = overflow[bit15_src][bit15_dst][bit15_res];	//data driven, see tables
		PSW.n = bit15_res;		//if MSB == 1 then set
		PSW.z = (res.w == 0);	//if result == 0, then set
		PSW.c = carry[bit15_src][bit15_dst][bit15_res];		//data driven, see tables
	}
	else
	{
		unsigned short bit7_src = BIT7(src.w);		//MSBit of low byte of src
		unsigned short bit7_dst = BIT7(dst.w);		//MSBit of low byte of dst
		unsigned short bit7_res = BIT7(res.w);		//MSBit of low byte of res
		PSW.v = overflow[bit7_src][bit7_dst][bit7_res];	//data driven, see tables
		PSW.n = bit7_res;			//if MSB == 1 then set
		PSW.z = (res.b[0] == 0);	//if result == 0, then set
		PSW.c = carry[bit7_src][bit7_dst][bit7_res];	//data driven, see tables
	}
	return;
}

//This function is called for all instructions that need to update the PSW but do
//not use the arithmetic format of [RES] <- [DST] [+/-] [SRC] + [Carry]
void update_PSW_other(unsigned short res, unsigned short wb)
{
	if (wb == 0)	//WORD
	{
		if (res == 0)					//if result is zero
		{
			PSW.z = 1;					//set zero bit
			PSW.n = 0;					//clear negative bit
		}
		else if (BIT15(res) == 0)		//if MSBit is 0 (but overall result is not zero)
		{
			PSW.z = 0;					//clear zero bit
			PSW.n = 0;					//clear negative bit
		}
		else							//if overall result is not zero and MSBit is set
		{
			PSW.z = 0;					//clear zero bit
			PSW.n = 1;					//set negative bit
		}
	}
	else			//BYTE
	{
		CLR_MSBYTE(res);				//if result is zero
		if (res == 0)
		{
			PSW.z = 1;					//set zero bit
			PSW.n = 0;					//clear negative bit
		}
		else if (BIT7(res) == 0)		//if MSBit of low byte is 0 (but overall result is not zero)
		{
			PSW.z = 0;					//clear zero bit
			PSW.n = 0;					//clear negative bit
		}
		else							//if overall result is not zero and MSBit of low byte is set
		{
			PSW.z = 0;					//clear zero bit
			PSW.n = 1;					//set negative bit
		}
	}
	return;
}


// Calculates offset of all branches other than BL
void branch_offset(unsigned short inst)
{
	unsigned short offset;
	//perform sign extension
	if (BIT9(inst))		//if 9th bit is 1
		offset = BRNCH_SETNEG(inst);	//sign extend offset to negative
	else							//if 9th bit is 0
		offset = BRNCH_SETPOS(inst);	//sign extend offset to positive

	offset <<= 1;	//shift offset by 1 bit to left.
	PC.w += offset;	//set new program counter
	return;
}

//function to convert PSW struct to 16 bit word
unsigned short psw_to_word(void)
{
	unsigned short conv = 0;
	conv = PSW.pp << PP_SHIFT;
	conv |= PSW.flt << FLT_SHIFT;
	conv |= PSW.cp << CP_SHIFT;
	conv |= PSW.v << V_SHIFT;
	conv |= PSW.slp << SLP_SHIFT;
	conv |= PSW.n << N_SHIFT;
	conv |= PSW.z << Z_SHIFT;
	conv |= PSW.c;
	return conv;
}

//function to convert CEX struct to 16 bit word
unsigned short cex_to_word(void)
{
	unsigned short conv = 0;
	conv = CEX.on << ON_SHIFT;
	conv |= CEX.cond << COND_SHIFT;
	conv |= CEX.tru << TRU_SHIFT;
	conv |= CEX.fls;
	return conv;
}

//function to convert 16 bit word to PSW struct
void word_to_psw(unsigned short conv)
{
	PSW.c = conv & 0x01;
	PSW.z = (conv >> Z_SHIFT) & LOW_BIT;
	PSW.n = (conv >> N_SHIFT) & LOW_BIT;
	PSW.slp = (conv >> SLP_SHIFT) & LOW_BIT;
	PSW.v = (conv >> V_SHIFT) & LOW_BIT;
	PSW.cp = (conv >> CP_SHIFT) & LOW_3_BITS;
	PSW.flt = (conv >> FLT_SHIFT) & LOW_BIT;
	PSW.pp = (conv >> PP_SHIFT) & LOW_3_BITS;
	return;
}

//function to convert 16 bit word to CEX struct
void word_to_cex(unsigned short conv)
{
	CEX.fls = conv & LOW_3_BITS;
	CEX.tru = (conv >> TRU_SHIFT) & LOW_3_BITS;
	CEX.cond = (conv >> COND_SHIFT) & LOW_BIT;
	CEX.on = (conv >> ON_SHIFT) & LOW_BIT;
	return;
}

void test_for_cex(void)
{
	if (CEX.on)		//if CEX instruction is currently active
	{
		if (CEX.cond)	//if condition is true
		{
			if (CEX.tru)	//if remaining true instructions
				CEX.tru--;
			else
			{
				PC.w += (CEX.fls << 1);	//skip all false instructions
				CEX.on = 0;
			}
		}
		else
		{
			PC.w += (CEX.tru << 1);	//skip all true instructions
			CEX.on = 0;
		}
	}
}

//pushes all required information onto the stack before an ISR
void push_interrupt(void)
{
	push(PC.w);
	push(LR.w);
	push(psw_to_word(PSW));		//push the psw as a word
	push(cex_to_word(CEX));		//push the cex as a word
	return;
}

//pushes a single value onto the stack
void push(unsigned short arg)
{
	cache_func(SP.w, &arg, WRITE, WORD);	//push into memory
	SP.w -= 2;								//decrement stack pointer
	return;
}

//pops all required information off the stack after an ISR
void pop_interrupt(void)
{
	word_to_cex(pop());			//pop cex and convert to struct
	word_to_psw(pop());			//pop psw and convert to struct
	LR.w = pop();
	PC.w = pop();
	return;
}

//pops single value off of the stack
unsigned short pop(void)
{
	unsigned short arg;
	SP.w += 2;								//increment program counter
	cache_func(SP.w, &arg, READ, WORD);		//pop from stack
	return arg;
}

//interrupt service routine
void ISR(unsigned short arg, unsigned short fault)
{
	if (fault)				//print out fault message
		print_flt(arg);

	if (PSW.flt == 1)				//if psw already shows fault
		double_fault_handler();		//double fault, need to terminate all;

	unsigned short prev_prio = PSW.cp;
	unsigned short temp_psw;
	
	push_interrupt();							//push required information into stack
	cache_func(arg, &temp_psw, READ, WORD);		//load new psw
	word_to_psw(temp_psw);						//convert to struct
	
	//if fault handler called, set fault bit
	if(fault)
		PSW.flt = 1;								//set fault bit to 1
	PSW.pp = prev_prio;	//save previous priority
	PSW.slp = 0;
	LR.w = 0xFFFF;				//set link register high to exit ISR
	CEX.on = 0;					//reset cex
	if (prev_prio >= PSW.cp)	//can only trap to higher priority
		ISR(PRI_FAULT, FAULT);
	else
		cache_func((arg + 2), &PC.w, READ, WORD);	//load vector entry point, stored in arg + 2, to PC
	return;
}

//only called if a double fault has occured. Lets user view memory and registers, forces CPU termination
void double_fault_handler(void)
{
	fprintf(printDest, "\n\n*********************DOUBLE FAULT HAS OCCURED, CPU WILL BE TERMINATED*********************");
	int choice;
	int mem_mod_start, mem_mod_end;
	while (1)
	{
		do
		{
			printf("\n\nCurrent Clock: %d\n", GLOBAL_CLOCK);
			printf("Current Non-pipelined FPGA Clock: %d\n", GLOBAL_CLOCK_FPGA);
			printf("Choose one of the following:\n");
			printf("TERMINATE CPU     : (0)\n");
			printf("View Registers    : (1)\n");
			printf("View Memory       : (2)\n");
			scanf_s("%d", &choice);
			printf("\n");
		} while (choice != 0 && choice != 1 && choice != 2);

		if (choice == 0)		//terminate CPU
		{
			terminate_print_files();
			flush_cache();
			printf("\nTo print memory into file, press (1): ");
			if (getchar() == '1')
				print_mem();
			exit(-1);
		}

		else if (choice == 1)	//view registers
		{
			for (int i = 0; i < 8; i++)
				printf("\R%01d: %04x\n", i, regfile[0][i].w);
			printf("C:   %01x    N:  %01x    V:   %01x    Z:  %01x\n", PSW.c, PSW.n, PSW.v, PSW.z);	//print PSW register
			printf("SLP: %01x    CP: %01x    FLT: %01x    PP: %01x\n", PSW.slp, PSW.cp, PSW.flt, PSW.pp);	//print PSW register

			printf("Instruction Register: %04x\n", IR.w);
		}

		else					//view memory
		{
			printf("Specify memory range to view (0x#### - 0x####): ");
			scanf_s("%04x - %04x", &mem_mod_start, &mem_mod_end);	//read start and end of memory to view
			printf("        0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f         0123456789abcdef\n\n");
			for (int i = mem_mod_start; i <= mem_mod_end; i += 16)		//print memory in words
			{
				printf("%04x    %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x        ", \
					i, mem.b[i], mem.b[i + 1], mem.b[i + 2], mem.b[i + 3], mem.b[i + 4], mem.b[i + 5], mem.b[i + 6], mem.b[i + 7], \
					mem.b[i + 8], mem.b[i + 9], mem.b[i + 10], mem.b[i + 11], mem.b[i + 12], mem.b[i + 13], mem.b[i + 14], mem.b[i + 15]);

				//printf("%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c\n", \
					mem.b[i], mem.b[i + 1], mem.b[i + 2], mem.b[i + 3], mem.b[i + 4], mem.b[i + 5], mem.b[i + 6], mem.b[i + 7], \
					mem.b[i + 8], mem.b[i + 9], mem.b[i + 10], mem.b[i + 11], mem.b[i + 12], mem.b[i + 13], mem.b[i + 14], mem.b[i + 15]);
				printf("\n");
			}
		}
	} 
	return;
}

//check to see if ISR was exited (happens at fetch time)
void test_for_ISR_exit(void)
{
	if (PC.w == 0xFFFF)	//checks if PC is FFFF
	{
		unsigned short prev_prio = PSW.cp;
		pop_interrupt();	//retrieve data from stack
		PSW.pp = prev_prio;	//save previous priority
		PSW.slp = 0;
	}
	return;
}
