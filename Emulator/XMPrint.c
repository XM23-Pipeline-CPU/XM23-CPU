#include "XMPrint.h"
#include "cpu.h"
#include <stdio.h>

FILE* printDest;

void init_print(void)
{
	static int first = 1;
	if (print_destination == STDOUT)
		printDest = stdout;
	else if (first)
	{
		fopen_s(&printDest, "XM23_Output.txt", "w");
		first = 0;
	}
		
	
	return;
}

void terminate_print_files(void)
{
	if (print_destination == EXTERNAL)
		fclose(printDest);
	return;
}

void print_mem(void)
{
	FILE* mem_file;
	fopen_s(&mem_file, "XM23_memory.txt", "w");

	fprintf(mem_file, "        0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f         0123456789abcdef\n\n");
	for (int i = 0; i < 0xFFFE; i += 16)		//print memory in words
	{
		fprintf(mem_file, "%04x    %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x        ", \
			i, mem.b[i], mem.b[i + 1], mem.b[i + 2], mem.b[i + 3], mem.b[i + 4], mem.b[i + 5], mem.b[i + 6], mem.b[i + 7], \
			mem.b[i + 8], mem.b[i + 9], mem.b[i + 10], mem.b[i + 11], mem.b[i + 12], mem.b[i + 13], mem.b[i + 14], mem.b[i + 15]);

		//fprintf(mem_file, "%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c\n", \
			mem.b[i], mem.b[i + 1], mem.b[i + 2], mem.b[i + 3], mem.b[i + 4], mem.b[i + 5], mem.b[i + 6], mem.b[i + 7], \
			mem.b[i + 8], mem.b[i + 9], mem.b[i + 10], mem.b[i + 11], mem.b[i + 12], mem.b[i + 13], mem.b[i + 14], mem.b[i + 15]);
		fprintf(mem_file, "\n");
	}
	
	fclose(mem_file);
	return;
}


void print_flt(unsigned short flt_type)
{
	switch (flt_type)
	{
	case PRI_FAULT:
		fprintf(printDest, "\n\n*********************PRIORITY FAULT - ENTERING FAULT HANDLER*********************\n\n");
		break;
	case ILL_INST:
		fprintf(printDest, "\n\n*********************ILLEGAL INSTRUCTION FAULT - ENTERING FAULT HANDLER*********************\n\n");
		break;
	case ILL_ADD:
		fprintf(printDest, "\n\n*********************ILLEGAL ADDRESS FAULT - ENTERING FAULT HANDLER*********************\n\n");
		break;
	}
	return;
}

void print_inst(int choice, unsigned int inst)
{
	static int first = 1;
	if (print_verbosity == CLEAN) return;

	if (first)
	{
		if (print_verbosity == STANDARD)
			fprintf(printDest, "\n\nPC      INST    TYPE\n");
		else if(print_verbosity == VERBOSE)
			fprintf(printDest, "\n\nPC      INST    TYPE    CEX     PSW     R0      R1      R2      R3      R4      R5      SP\n");
		else
			fprintf(printDest, "\n\nPC      INST    TYPE    CEX.C   CEX.T   CEX.F   C    Z    N    SLP  CP   FLT  PP   R0      R1      R2      R3      R4      R5      SP\n");
		first = 0;
	}
		
	switch (choice)
	{
		case BL_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BL      ", PC.w - 2, inst);
			break;
		case BEQ_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BEQ     ", PC.w - 2, inst);
			break;
		case BNE_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BNE     ", PC.w - 2, inst);
			break;
		case BC_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BC      ", PC.w - 2, inst);
			break;
		case BNC_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BNC     ", PC.w - 2, inst);
			break;
		case BN_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BN      ", PC.w - 2, inst);
			break;
		case BGE_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BGE     ", PC.w - 2, inst);
			break;
		case BLT_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BLT     ", PC.w - 2, inst);
			break;
		case BRA_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BRA     ", PC.w - 2, inst);
			break;
		case ADD_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    ADD     ", PC.w - 2, inst);
			break;
		case ADDC_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    ADDC    ", PC.w - 2, inst);
			break;
		case SUB_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    SUB     ", PC.w - 2, inst);
			break;
		case SUBC_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    SUBC    ", PC.w - 2, inst);
			break;
		case DADD_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    DADD    ", PC.w - 2, inst);
			break;
		case CMP_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    CMP     ", PC.w - 2, inst);
			break;
		case XOR_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    XOR     ", PC.w - 2, inst);
			break;
		case AND_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    AND     ", PC.w - 2, inst);
			break;
		case OR_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    OR      ", PC.w - 2, inst);
			break;
		case BIT_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BIT     ", PC.w - 2, inst);
			break;
		case BIC_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BIC     ", PC.w - 2, inst);
			break;
		case BIS_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    BIS     ", PC.w - 2, inst);
			break;
		case MOV_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    MOV     ", PC.w - 2, inst);
			break;
		case SWAP_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    SWAP    ", PC.w - 2, inst);
			break;
		case SRA_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    SRA     ", PC.w - 2, inst);
			break;
		case RRC_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    RRC     ", PC.w - 2, inst);
			break;
		case COMP_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    COMP    ", PC.w - 2, inst);
			break;
		case SWPB_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    SWPB    ", PC.w - 2, inst);
			break;
		case SXT_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    SXT     ", PC.w - 2, inst);
			break;
		case SETPRI_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    SETPRI   ", PC.w - 2, inst);
			break;
		case SVC_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    SVC     ", PC.w - 2, inst);
			break;
		case SETCC_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    SETCC   ", PC.w - 2, inst);
			break;
		case CLRCC_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    CLRCC   ", PC.w - 2, inst);
			break;
		case CEX_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    CEX     ", PC.w - 2, inst);
			break;
		case LD_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    LD      ", PC.w - 2, inst);
			break;
		case ST_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    ST      ", PC.w - 2, inst);
			break;
		case MOVL_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    MOVL    ", PC.w - 2, inst);
			break;
		case MOVLZ_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    MOVLZ   ", PC.w - 2, inst);
			break;
		case MOVLS_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    MOVLS   ", PC.w - 2, inst);
			break;
		case MOVH_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    MOVH    ", PC.w - 2, inst);
			break;
		case LDR_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    LDR     ", PC.w - 2, inst);
			break;
		case STR_INFO:
			//print function goes here
			fprintf(printDest, "%04x    %04x    STR     ", PC.w - 2, inst);
			break;
	}


	//fprintf(              CEX     PSW     R0      R1      R2      R3      R4      R5      SP\n");
	
	if (print_verbosity == VERBOSE)
	{
		fprintf(printDest, "%04x    %04x    %04x    %04x    %04x    %04x    %04x    %04x    %04x",
			cex_to_word(CEX),
			psw_to_word(PSW),
			regfile[0][0].w,
			regfile[0][1].w,
			regfile[0][2].w,
			regfile[0][3].w,
			regfile[0][4].w,
			regfile[0][5].w,
			regfile[0][6].w);
	}

	//fprintf(              CEX.C   CEX.T   CEX.F   C   Z   N   SLP CP  FLT PP  R0      R1      R2      R3      R4      R5      SP\n");
	else if (print_verbosity == VERBOSE_PLUS)
	{
		fprintf(printDest, "%04x    %04x    %04x    %01x    %01x    %01x    %01x    %01x    %01x    %01x    %04x    %04x    %04x    %04x    %04x    %04x    %04x",
			CEX.cond,
			CEX.tru,
			CEX.fls,
			PSW.c,
			PSW.z,
			PSW.n,
			PSW.slp,
			PSW.cp,
			PSW.flt,
			PSW.pp,
			regfile[0][0].w,
			regfile[0][1].w,
			regfile[0][2].w,
			regfile[0][3].w,
			regfile[0][4].w,
			regfile[0][5].w,
			regfile[0][6].w);
	}

	fprintf(printDest, "\n");
	return;
}
