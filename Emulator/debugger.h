#ifndef DEBUGGER_H
#define DEBUGGER_H

#include "cpu.h"
#define ENDMEM 0xFFBE		//defines End of Memory that a program counter can reach in contiuous mode
void cont_mode(unsigned short breakpoint);
void debug_mode(void);
void sigint_hdlr();

#endif
