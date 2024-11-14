#ifndef MEMORY_H
#define MEMORY_H

#define CACHE_SIZE	16			//cache can hold up to 16 cache lines
#define MAX_USAGE	CACHE_SIZE - 1			//maximum cache usage (for 16 line cache)
//#define DIV_COUNT	4			//number of divisions for combined N-way caching (can only be 2, 4, or 8)

//defines hashing function for user selected number of cache divisions for combined cache system
//#define COMBINED_KEY_HASH(inst, div_num) (inst & (~((CACHE_SIZE/div_num) - 1)) >> ((((CACHE_SIZE - 1) ^ div_num) >> 2) & (div_num - 1))) & (div_num - 1)
#define COMBINED_KEY_HASH(addr, div_num) (addr & (~((CACHE_SIZE >> (div_num >> 1)) - 1)) & (CACHE_SIZE - 1))
extern int div_num;

#define WDMEMSZ		0x7FFF		// 64kib in words
#define BYMEMSZ		0xFFFF		// 64kib in bytes


#define BASE_IVT 0xFFC0
#define ILL_INST (BASE_IVT + (4 * 8))
#define ILL_ADD (BASE_IVT + (4 * 9))
#define PRI_FAULT (BASE_IVT + (4 * 10))
#define DBL_FAULT (BASE_IVT + (4 * 11))
#define FAULT_PSW_PRI_7 0x00E0



#define READ		0
#define WRITE		1
#define WORD		0
#define BYTE		1

extern unsigned int GLOBAL_CLOCK;
extern unsigned int GLOBAL_CLOCK_FPGA;

//defines type for accessing array of four nibbles
typedef struct nibbles
{
	unsigned n0 : 4;
	unsigned n1 : 4;
	unsigned n2 : 4;
	unsigned n3 : 4;
}nibbles;

// Defines union type for accessing registers and cache as words, bytes or nubbles
typedef union word_byte_nibble
{
	unsigned short w;
	unsigned char b[2];
	nibbles nib;
}word_byte_nibble;

/// Defines union type for main memory array
typedef union memory
{
	unsigned short w[WDMEMSZ];	//Word array
	unsigned char b[BYMEMSZ];	//Byte array
}memory;

//cache line data type (address, data, dirty bit, usage)
typedef struct cache_line
{
	unsigned short addr;	//address of data
	word_byte_nibble data;	
	unsigned db	: 1;		//dirty bit
	unsigned usage : 4;		//cache usage (supports up to 16 cache lines)
	unsigned wb : 1;		//tells if what is stored is a word or a byte
	unsigned char lh;		//tells if the byte is stored high or low
}cache_line;

extern memory mem;	// main memory array
extern cache_line cache[CACHE_SIZE];	//cache is comprised of 16 cache lines
extern char cache_type;

//CEX structure
typedef struct CEX_reg
{
	unsigned short on : 1;
	unsigned short cond : 1;
	unsigned short tru : 3;
	unsigned short fls : 3;
}cex_reg;

extern cex_reg CEX;

void init_mem(void);
//bus function externed to ensure optimizations by compiler (is called frequently)
extern inline void bus(unsigned short MAR, unsigned short* MDR, unsigned char RW, unsigned char WB);

//multiple cache functions allow the user to change the desired caching method on the fly
extern inline void cache_func(unsigned short MAR, unsigned short* MDR, unsigned char RW, unsigned char WB);
extern inline void cache_associative(unsigned short MAR, unsigned short* MDR, unsigned char RW, unsigned char WB);
extern inline void cache_direct(unsigned short MAR, unsigned short* MDR, unsigned char RW, unsigned char WB);
extern inline void cache_combined(unsigned short MAR, unsigned short* MDR, unsigned char RW, unsigned char WB);

//function that allows memory completness when quiting program
void flush_cache(void);
#endif
