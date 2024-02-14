/*
 * Emulator sotware written by Roee Omessi - B00871023
 * ECED 3403 - Computer Architecture
 * Summer term - 2023
 */

#include "XMPrint.h"
#include "debugger.h"
#include <stdio.h>
#include <time.h>

int print_verbosity = STANDARD;
int print_destination = STDOUT;

int main(int argc, char *argv[])
{
	init_mem();					// Initialize 64 kib of memory to 0
	init_PSW();					// Initializes PSW register to 0
	init_print();				// Initialize the print settings


	printf("--------------------------------LOADER REPORT--------------------------------\n\n");
	int exit = loader(argc, argv);			// parse S-Records
	if (exit == 1 || exit == -1)			// quit if S-record is incorrect
	{
		getchar();
		return 1;
	}
		

	printf("-------------------------------RUNNING INTERFACE------------------------------\n\n");
	int mode = 0;
	//Main menu
	do
	{
		printf("Choose the following:\n");
		printf("0 - QUIT\n");
		printf("1 - Run until end of memory\n");
		printf("2 - Run in Debug Mode\n");
		printf("3 - Modify print settings\n");
		scanf_s("%d", &mode);

		if (mode == 3)
		{
			printf("\nCurrent print settings: Standard verbosity to stdout\n");
			do
			{
				printf("Entery verbosity level (0 - clean, 1 - standard, 2 - verbose, 3 - verbose plus): ");
				scanf_s("%d", &print_verbosity);
			} while (print_verbosity != 0 && print_verbosity != 1 && print_verbosity != 2 && print_verbosity != 3);
			
			do
			{
				printf("Enter output destination (0 - stdout, 1 - external file): ");
				scanf_s("%d", &print_destination);
			} while (print_destination != 0 && print_destination != 1);


			init_print();				// Initialize the print settings
			printf("\n");
		}
	} while (mode != 0 && mode != 1 && mode != 2);

	clock_t start = clock();	//start clock from this point on
	if (mode == 0)
		return 0;
	if (mode == 1)				//continuous mode runs from memory address 0x0000 to 0xFFFE
	{
		cont_mode(ENDMEM);		//run through memory
		if(PC.w == ENDMEM)
			printf("\nEnd of memory reached.\n");
		for (int i = 0; i < 8; i++)
			printf("\R%01d: %04x\n", i, regfile[0][i].w);
		
		printf("C:   %01x    N:  %01x    V:   %01x    Z:  %01x\n", PSW.c, PSW.n, PSW.v, PSW.z);	//print PSW register
		printf("SLP: %01x    CP: %01x    FLT: %01x    PP: %01x\n", PSW.slp, PSW.cp, PSW.flt, PSW.pp);	//print PSW register

		printf("Instruction Register: 0x%04x\n", IR.w);	//print most recent instruction read
	}
		
	else		//allows user to access additional functionality
		debug_mode();
	

	clock_t end = clock();		//end timer
	terminate_print_files();
	flush_cache();
	printf("Clock Cycles: %d\n", GLOBAL_CLOCK);
	printf("Time: %d ms\n", end - start);	//print total run time
	printf("\nPress (1) to print memory into file, or any other key to quit.");
	setvbuf(stdin, NULL, _IONBF, 0);		//clear stdin to allow getchar to work
	if (getchar() == '1')
		print_mem();
	return 0;
}
