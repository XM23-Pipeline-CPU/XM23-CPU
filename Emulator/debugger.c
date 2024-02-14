#include "debugger.h"
#include <stdio.h>
#include <signal.h> /* Signal handling software */
#include <stdbool.h>
#include <ctype.h>

//Credit to Dr. Larry Hughes for all CTRL_C software interrupt code//

volatile sig_atomic_t ctrl_c_fnd; /* T|F - indicates whether ^C detected */


/// <summary>
/// Runs all instructions from starting address intill the end of memory.
/// </summary>
/// <param name=""></param>
void cont_mode(unsigned short breakpoint)
{
	ctrl_c_fnd = false;
	signal(SIGINT, (_crt_signal_t)sigint_hdlr);
	//while not at breakpoint
	//read and execute instructions repeatedly
	while (PC.w != breakpoint && PC.w != ENDMEM && !ctrl_c_fnd)	
	{
		fetch();
		PC.w += 2;				//increment
		decode_inst(IR.w);		//decode + execute
		GLOBAL_CLOCK += 3;		// Increment 1 for fetch, decode, and execute
	}
	if (breakpoint == ENDMEM)	//executes last instruction
	{
		fetch();
		decode_inst(IR.w);
		GLOBAL_CLOCK += 3;
	}
	return;
}

/// <summary>
/// Lets user run instructions one by one from starting address
/// and change the program counter to any location at any point.
/// </summary>
/// <param name=""></param>
void debug_mode(void)
{
	int choice;
	int breakpoint;
	int change_PC;
	int mod_reg_index;
	int mem_mod_start, mem_mod_end;
	int edit_reg;
	char temp_cache_type;

	//while not at the end of memory
	//run instructions as specified by user
	while (PC.w <= 0xFFFE)	
	{
		do
		{
			printf("\n\nCurrent Clock: %d\n", GLOBAL_CLOCK);
			printf("Choose one of the following:\n");
			printf("QUIT              : (0)\n");
			printf("CONTINUE          : (1)\n");
			printf("Change PC         : (2)\n");
			printf("Set new breakpoint: (3)\n");
			printf("View Registers    : (4)\n");
			printf("Modify Registers  : (5)\n");
			printf("View Memory       : (6)\n");
			printf("Modify cache type : (7)\n");
			scanf_s("%d", &choice);
			printf("\n");
			if (choice == 4)
			{
				for (int i = 0; i < 8; i++)
					printf("\R%01d: %04x\n", i, regfile[0][i].w);
				printf("C:   %01x    N:  %01x    V:   %01x    Z:  %01x\n", PSW.c, PSW.n, PSW.v, PSW.z);	//print PSW register
				printf("SLP: %01x    CP: %01x    FLT: %01x    PP: %01x\n", PSW.slp, PSW.cp, PSW.flt, PSW.pp);	//print PSW register

				printf("Instruction Register: %04x\n", IR.w);
			}

			else if (choice == 5)		//modify registers
			{
				do
				{
					printf("Specify register to modify: (0 - 7): ");
					scanf_s("%d", &mod_reg_index);	//scan which register to modify
				} while (mod_reg_index < 0 || mod_reg_index > 7);
				printf("Current value: %04x\n", regfile[0][mod_reg_index].w);
				printf("New value: ");
				scanf_s("%04x", &edit_reg);	//scan new value for register
				regfile[0][mod_reg_index].w = (unsigned short)edit_reg;
			}
			else if (choice == 6)		//view memory
			{
				flush_cache();	//alligns cache and memory so user can view up to date memory.
				printf("Specify memory range to view (0x#### - 0x####): ");
				scanf_s("%04x - %04x", &mem_mod_start, &mem_mod_end);	//read start and end of memory to view
				printf("        0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f         0123456789abcdef\n\n");
				for (int i = mem_mod_start; i <= mem_mod_end; i+=16)		//print memory in words
				{
					printf("%04x    %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x  %02x        ", \
						i, mem.b[i], mem.b[i + 1], mem.b[i + 2], mem.b[i + 3], mem.b[i + 4], mem.b[i + 5], mem.b[i + 6], mem.b[i + 7], \
						mem.b[i + 8], mem.b[i + 9], mem.b[i + 10], mem.b[i + 11], mem.b[i + 12], mem.b[i + 13], mem.b[i + 14], mem.b[i + 15]);

					//printf("%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c", \
						mem.b[i], mem.b[i + 1], mem.b[i + 2], mem.b[i + 3], mem.b[i + 4], mem.b[i + 5], mem.b[i + 6], mem.b[i + 7], \
						mem.b[i + 8], mem.b[i + 9], mem.b[i + 10], mem.b[i + 11], mem.b[i + 12], mem.b[i + 13], mem.b[i + 14], mem.b[i + 15]);
					printf("\n");
				}
			}
			else if (choice == 7)	//change caching algorithm
			{
				do //continue prompting for cache type until user gives valid type (A || D || C)
				{
					printf("Please select the following:\n");
					printf("(A) Associative cache access\n");
					printf("(D) Direct cache access\n");
					printf("(C) Combined cache access (direct and associative)\n");
					printf("(N) No cache (directly access memory)\n");
					printf("Note that the default uses associative caching\n");
					printf("Choice: ");
					scanf_s(" %c", &temp_cache_type);
					(char)temp_cache_type = toupper((char)temp_cache_type);
				} while ((char)temp_cache_type != 'A' && (char)temp_cache_type != 'D' && (char)temp_cache_type != 'C' && (char)temp_cache_type != 'N');
				cache_type = (char)temp_cache_type;
				if (cache_type == 'C')
				{
					do
					{
						printf("Specify number of divisions: ");
						scanf_s(" %d", &div_num);
					} while (div_num < 2 || div_num > CACHE_SIZE - 1 || CACHE_SIZE % div_num != 0);
				}
			}
		} while (choice != 0 && choice != 1 && choice != 2 && choice != 3);	//continue prompting for the menu unless quit, continue, change PC, or set new breakpoint

		if (choice == 0)	//if QUIT chosen
		{
			printf("Quitting program.\n");
			return;
		}
		else if (choice == 1)	//if CONTINUE chosen execute one instruction
		{
			fetch();
			PC.w += 2;
			decode_inst(IR.w);
			GLOBAL_CLOCK += 3;
		}
		else if (choice == 2)	//if CHANGE PC chosen
		{
			do
			{
				printf("Enter new address for Program Counter: ");
				scanf_s("%04x", &change_PC);
			} while (change_PC % 2 != 0);	//continue prompting for PC while invalid
			
			PC.w = (unsigned short)change_PC;	//if valid, set as new PC
			printf("Program counter set to %04x\n", PC.w);
		}
		else			//set new breakpoint
		{
			printf("Current PC: %04x\n", PC.w);
			do
			{
				printf("Set breakpoint: ");
				scanf_s("%04x", &breakpoint);
			} while ((unsigned short)breakpoint % 2);		//needs to be even PC and greater than current PC
			cont_mode((unsigned short)breakpoint);		//run in continuous mode until breakpoint is reached (does not execute instruction at breakpoint)
			printf("PC: %04x\n", PC.w);					//print program counter once breakpoint has been reached
		}
	}

	return;
}

void sigint_hdlr()
{
	/*
	- Invoked when SIGINT (control-C) is detected
	- changes state of waiting_for_signal
	- signal must be reinitialized
	*/
	ctrl_c_fnd = true;
	signal(SIGINT, (_crt_signal_t)sigint_hdlr); /* Reinitialize SIGINT */
}
