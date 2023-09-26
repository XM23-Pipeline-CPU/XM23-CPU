#ifndef XMPRINT_H
#define XMPRINT_H

#include <stdio.h>

void print_inst(int choice, unsigned int inst);
void print_mem(void);
void print_flt(unsigned short flt_type);
void init_print(void);
void terminate_print_files (void);
extern int print_verbosity;
extern int print_destination;

#define CLEAN 0
#define STANDARD 1
#define VERBOSE 2
#define VERBOSE_PLUS 3
#define STDOUT 0
#define EXTERNAL 1

extern FILE* printDest;

enum print_codes
{
	BL_INFO,
	BEQ_INFO,
	BNE_INFO,
	BC_INFO,
	BNC_INFO,
	BN_INFO,
	BGE_INFO,
	BLT_INFO,
	BRA_INFO,
	ADD_INFO,
	ADDC_INFO,
	SUB_INFO,
	SUBC_INFO,
	DADD_INFO,
	CMP_INFO,
	XOR_INFO,
	AND_INFO,
	OR_INFO,
	BIT_INFO,
	BIC_INFO,
	BIS_INFO,
	MOV_INFO,
	SWAP_INFO,
	SRA_INFO,
	RRC_INFO,
	COMP_INFO,
	SWPB_INFO,
	SXT_INFO,
	SETPRI_INFO,
	SVC_INFO,
	SETCC_INFO,
	CLRCC_INFO,
	CEX_INFO,
	LD_INFO,
	ST_INFO,
	MOVL_INFO,
	MOVLZ_INFO,
	MOVLS_INFO,
	MOVH_INFO,
	LDR_INFO,
	STR_INFO,
};

#endif