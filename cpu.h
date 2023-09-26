#ifndef CPU_H
#define CPU_H

#include "loader.h"
#include "memory.h"

#define REGCOUNT 8				// 8 registers
#define REG_OR_CONST 2			// Either registers or constants
#define R0 regfile[0][0]		// R0
#define R1 regfile[0][1]		// R1
#define R2 regfile[0][2]		// R2
#define R3 regfile[0][3]		// R3
#define BP regfile[0][4]		// Defines register 4 as the back pointer
#define LR regfile[0][5]		// Defines register 7 as the link register
#define SP regfile[0][6]		// Defines register 7 as the stach pointer
#define PC regfile[0][7]		// Defines register 7 as the program counter
#define IR inst_reg				// Defines inst_reg as IR

#define DST(x)		(x & 0x07)					// Macro for extracting destination bits from instruction
#define SRC(x)		((x>>3) & 0x07)				// Macro for extracting source bits from instruction
#define WB(x)		(x & 0b0000000001000000)	// Macro for extracting W/B bit from instruction
#define RC(x)		((x>>7) & 0x01)				// Macro for extracting R/C bit from instruction
#define INC(x)		((x>>7) & 0x01)				// Macro for extracting INC bit from instruction
#define DEC(x)		((x>>8) & 0x01)				// Macro for extracting DEC bit from instruction
#define PRPO(x)		((x>>9) & 0x01)				// Macro for extracting PRPO bit from instruction
#define MVBYTE(x)	((x >> 3) & 0xFF)			// Macro for extracting byte in move instructions
#define LDOFFSET(x) ((x >> 7) & 0x7F)			// Macro for extracting offset bits in LDR and STR instructions

//Macros and constants for accessing specific bits for decoding opcodes
#define BITS14TO15(x)	(x & 0b1100000000000000)
#define BITS13TO15(x)	(x & 0b1110000000000000)
#define BITS10TO12(x)	(x & 0b0001110000000000)
#define BITS8TO12(x)	(x & 0b0001111100000000)
#define BITS11TO12(x)	(x & 0b0001100000000000)
#define BITS7_5_4_3(x)	(x & 0b0000000010111000)
#define BITS5TO11(x)	(x & 0b0000111111100000)
#define BITS5TO6(x)		(x & 0b0000000001100000)
#define OTHER_BRANCH	0b0010000000000000
#define TWO_REG_ARITH	0b0100000000000000
#define MOV_SWAP_INST	0b0000110000000000
#define SRA_THRU_CLRCC	0b0000110100000000
#define SETPRI_OR_SVC	0b0000000000000000
#define MOVE_INST		0b0110000000000000
#define LDR_DONTCARE0	0b1000000000000000
#define LDR_DONTCARE1	0b1010000000000000
#define STR_DONTCARE0	0b1100000000000000
#define STR_DONTCARE1	0b1110000000000000

//Marcros for accessing specific bits for use by functions
#define BIT5(x)			(x &  0b0000000000100000)
#define BIT4(x)			(x &  0b0000000000010000)
#define BIT12(x)		(x & 0b0001000000000000)
#define BIT7(x)			((x >> 7) & 0x01)		//used to set PSW if byte
#define BIT15(x)		((x >> 15) & 0x01)		//used to set PSW if word
#define BIT14(x)		(x & 0b0100000000000000)
#define BIT6(x)			(x & 0b0000000001000000)
#define BIT9(x)			(x & 0b0000001000000000)
#define LSB(x)			(x & 0x01)				//extract least significant bit
#define MS3BITS(x)		(x & 0x07)				//least significant three bits
#define MS4BITS(x)		(x & 0x0F)				//least significant four bits

//Macros for sign extension in branching instructions
#define BL_SET_NEG(x)	(x | 0b1110000000000000)
#define BL_SET_POS(x)	(x & 0b0001111111111111)
#define BRNCH_SETNEG(x) (x | 0b1111110000000000)
#define BRNCH_SETPOS(x) (x & 0b0000001111111111)

//Macros for setting correct OFFSET in LDR and STR instructions
#define OFF_SETNEG_W(x)	(x |= 0b1111111111000000)
#define OFF_SETPOS_W(x)	(x &= 0b0000000000111111)
#define OFF_SETNEG_B(x)	(x |= 0b1111111110000000)
#define OFF_SETPOS_B(x)	(x &= 0b0000000001111111)

//constants for the CEX instruction code
#define EQ	0b0000
#define NE	0b0001
#define CS	0b0010
#define CC	0b0011
#define MI	0b0100
#define PL	0b0101
#define VS	0b0110
#define VC	0b0111
#define HI	0b1000
#define LS	0b1001
#define GE	0b1010
#define LT	0b1011
#define GT	0b1100
#define LE	0b1101
#define TR	0b1110
#define FL	0b1111

//Constants for psw and cex conversions between struct and word
#define PP_SHIFT	13
#define FLT_SHIFT	8
#define CP_SHIFT	5
#define V_SHIFT		4
#define SLP_SHIFT	3
#define N_SHIFT		2
#define Z_SHIFT		1
#define ON_SHIFT	7
#define COND_SHIFT	6
#define TRU_SHIFT	3
#define LOW_BIT		0x01
#define LOW_3_BITS	0x07

//Other Macros and constants
#define CLR_MSBYTE(x)	(x &= 0xFF)		//Used to clear MSByte when setting PSW bits for non arithmetic instructions
#define BYTE_SET		0xFF
#define BYTE_CLEARED	0x00
#define FAULT			1
#define NOT_FAULT		0

extern unsigned short carry[2][2][2];			//Used to define conditions for the PSW.c bit (Credit to Dr. Larry Hughes)
extern unsigned short overflow[2][2][2];		//Used to define conditions for the PSW.v bit (Credit to Dr. Larry Hughes)



// PSW structure credited to Dr. Larry Hughes
typedef struct psw_reg
{
	unsigned short c : 1;
	unsigned short z : 1;
	unsigned short n : 1;
	unsigned short slp : 1;
	unsigned short v : 1;
	unsigned short cp : 3;
	unsigned short flt : 1;
	unsigned short reserved : 4;
	unsigned short pp : 3;
}psw_reg;

// 2D array to define all constants and registers
// RC[0][#] refers to registers
// RC[1][#] refers to constants
extern word_byte_nibble regfile[REG_OR_CONST][REGCOUNT];
extern word_byte_nibble inst_reg;
extern psw_reg PSW;

// Init PSW code Credit to Dr. Larry Hughes
void init_PSW(void);

//fetch
void fetch(void);

// Function used to decode instruction opcodes and call execution functions
void decode_inst(unsigned short inst);

//All execution functions for all instructions
void exec_BL(unsigned short inst);
void exec_BEQ(unsigned short inst);
void exec_BNE(unsigned short inst);
void exec_BC(unsigned short inst);
void exec_BNC(unsigned short inst);
void exec_BN(unsigned short inst);
void exec_BGE(unsigned short inst);
void exec_BLT(unsigned short inst);
void exec_BRA(unsigned short inst);
void exec_ADD(unsigned short inst);
void exec_ADDC(unsigned short inst);
void exec_SUB(unsigned short inst);
void exec_SUBC(unsigned short inst);
void exec_DADD(unsigned short inst);
void exec_CMP(unsigned short inst);
void exec_XOR(unsigned short inst);
void exec_AND(unsigned short inst);
void exec_OR(unsigned short inst);
void exec_BIT(unsigned short inst);
void exec_BIC(unsigned short inst);
void exec_BIS(unsigned short inst);
void exec_MOV(unsigned short inst);
void exec_SWAP(unsigned short inst);
void exec_SRA(unsigned short inst);
void exec_RRC(unsigned short inst);
void exec_COMP(unsigned short inst);
void exec_SWPB(unsigned short inst);
void exec_SXT(unsigned short inst);
void exec_SETPRI(unsigned short inst);
void exec_SVC(unsigned short inst);
void exec_SETCC(unsigned short inst);
void exec_CLRCC(unsigned short inst);
void exec_CEX(unsigned short inst);
void exec_LD(unsigned short inst);
void exec_ST(unsigned short inst);
void exec_MOVL(unsigned short inst);
void exec_MOVLZ(unsigned short inst);
void exec_MOVLS(unsigned short inst);
void exec_MOVH(unsigned short inst);
void exec_LDR(unsigned short inst);
void exec_STR(unsigned short inst);

// Other functions used by instruction execution functions
word_byte_nibble exec_ADDITION(word_byte_nibble dst, word_byte_nibble src, unsigned short carry, unsigned short wb);
void update_PSW(word_byte_nibble res, word_byte_nibble dst, word_byte_nibble src, unsigned short wb);
void update_PSW_other(unsigned short res, unsigned short wb);
void branch_offset(unsigned short inst);

//Functions that convert structs to unsigned shorts 16 bits
unsigned short psw_to_word(void);
unsigned short cex_to_word(void);
void word_to_psw(unsigned short);
void word_to_cex(unsigned short);
void test_for_cex(void);

//push and pop from stack functions
void push_interrupt(void);
void push(unsigned short);
void pop_interrupt(void);
unsigned short pop(void);

//interrupt functions
void ISR(unsigned short arg, unsigned short called_by_fault);
void double_fault_handler(void);
void test_for_ISR_exit(void);
#endif