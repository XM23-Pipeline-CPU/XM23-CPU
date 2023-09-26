#include "memory.h"

unsigned int GLOBAL_CLOCK = 0;	//Initilize global clock

cache_line cache[CACHE_SIZE];
char cache_type = 'A';
unsigned short combined_key;
int div_num;

cex_reg CEX = { 0 };

// Initializes memory array to all zeroes
memory mem;
void init_mem(void)
{
	for (int i = 0; i < WDMEMSZ; i++)
		mem.w[i] = 0;

	for (int j = 0; j < CACHE_SIZE; j++)
	{
		cache[j].addr = 0xFFFF;
		cache[j].wb = BYTE;
	}
		

	//initialize fault PSWs to have priority 7
	mem.b[ILL_INST] = FAULT_PSW_PRI_7;
	mem.b[ILL_ADD] = FAULT_PSW_PRI_7;
	mem.b[DBL_FAULT] = FAULT_PSW_PRI_7;
	mem.b[PRI_FAULT] = FAULT_PSW_PRI_7;

	return;
}

// MAR = address in memory
// MDR = register to edit
// RW = 0 --> READ. RW = 1 --> WRITE
// WB = 0 --> WORD. WB = 1 --> BYTE

/// <summary>
/// Allows for read and write, word/byte communication between the CPU and the memory.
/// </summary>
/// <param name="MAR"></param>
/// <param name="MDR"></param>
/// <param name="RW"></param>
/// <param name="WB"></param>
/// <returns></returns>
inline void bus(unsigned short MAR, unsigned short* MDR, unsigned char RW, unsigned char WB)
{
	// RW = 0 --> READ
	if (RW == READ)
	{
		if (WB == WORD)	//WORD
			*MDR = mem.w[MAR >> 1];
		else			//BYTE
			*MDR = mem.b[MAR];
	}
	// RW = 1 --> WRITE
	else
	{
		if (WB == WORD)		//WORD
			mem.w[MAR >> 1] = *MDR;
		else				//BYTE
			mem.b[MAR] = (*MDR & 0xFF);
	}
	GLOBAL_CLOCK += 3;
	return;
}

inline void cache_func(unsigned short MAR, unsigned short* MDR, unsigned char RW, unsigned char WB)
{
	if (cache_type == 'A')			//associative cache
		cache_associative(MAR, MDR, RW, WB);
	else if (cache_type == 'D')		//direct cache
		cache_direct(MAR, MDR, RW, WB);
	else if (cache_type == 'C')		//combined cache access
		cache_combined(MAR, MDR, RW, WB);	
	else	//normal memory access - no cache (no else if is required as data is checked for correctness prior to this point)
		bus(MAR, MDR, RW, WB);
	return;
}

inline void cache_associative(unsigned short MAR, unsigned short* MDR, unsigned char RW, unsigned char WB)
{
	unsigned short word_addr = MAR >> 1;
	char low_high;
	if (WB == BYTE)
	{
		if (MAR == word_addr << 1)
			low_high = 'L';		//user is trying to access low byte of memory
		else
			low_high = 'H';		//user is trying to access high byte of memory
	}

	//searches through all cache lines for a hit
	for (int i = 0; i < CACHE_SIZE; i++)
	{
		if (word_addr == cache[i].addr)	//if HIT
		{
			//decrement usage of all cache lines with a higher usage than that of the hit line
			for (int j = 0; j < CACHE_SIZE; j++)
			{
				if (cache[j].usage > cache[i].usage)
					cache[j].usage--;
			}

			cache[i].usage = MAX_USAGE;	//set hit line's usage to max
			if (RW == READ)	//read
			{
				if (WB == WORD)
					*MDR = cache[i].data.w;	//read data from cache
				else
				{
					if(low_high == 'L')
						*MDR = cache[i].data.b[0];	//read data from cache (low byte)
					else
						*MDR = cache[i].data.b[1];	//read data from cache (high byte)
				}
			}
				
			else			//write
			{
				if (WB == WORD)		//word
				{
					cache[i].wb = WORD;
					cache[i].data.w = *MDR;	//write data to cache
				}
					
				else				//byte
				{
					if (cache[i].wb != WORD)	//we dont want to later only write the byte because then we wont update the word already in here correctly
					{
						cache[i].wb = BYTE;
						cache[i].lh = low_high;
					}
					if (low_high == 'L')
						cache[i].data.b[0] = *MDR;	//write data to cache (low byte)
					else
						cache[i].data.b[1] = *MDR;	//write data to cache (high byte)
				}
				cache[i].db = 1;		//set dirty bit to 1
			}
			return;
		}
	}

	//if no hit up to this point == MISS
	//need to look for cache with lowest usage:
	int n = 0;
	while (cache[n].usage != 0)
		n++;

	if (RW == READ)
	{
		if (cache[n].db == 0)	//if dirty bit is not set, we can overwrite
			bus(MAR, &cache[n].data.w, READ, WORD);	//read new value from memory to cache
			
		else					//if DB is set
		{
			//if we need to write back entire word, write entire word, else write only lower or upper byte
			if(cache[n].wb == WORD)
				bus(cache[n].addr << 1, &cache[n].data.w, WRITE, WORD);	//write cache line to memory
			else
			{
				if (cache[n].lh == 'L')
					bus(cache[n].addr << 1, &cache[n].data.b[0], WRITE, BYTE);			//write lower byte to mem
				else
					bus((cache[n].addr << 1) + 1, &cache[n].data.b[1], WRITE, BYTE);	//write higher byte to mem
			}
			
			bus(MAR, &cache[n].data.w, READ, WORD);	//read new value from memory to cache
		}

		cache[n].db = 0;	//set data bit of this line to zero
		
		//read data in cache to MDR
		if (WB == WORD)
			*MDR = cache[n].data.w;
		else
		{
			if (low_high == 'L')
				*MDR = cache[n].data.b[0];
			else
				*MDR = cache[n].data.b[1];
		}
	}

	else	//WRITE
	{
		//if need to write entire word to memory, write entire word, else write only part of the cache line
		if (cache[n].db == 1) //if dirty bit is set, write to memory first
		{
			if (cache[n].wb == WORD)
				bus(cache[n].addr << 1, &cache[n].data.w, WRITE, WORD);	//write cache line to memory
			else
			{
				if (cache[n].lh == 'L')
					bus(cache[n].addr << 1, &cache[n].data.b[0], WRITE, BYTE);			//writing lower byte to mem
				else
					bus((cache[n].addr << 1) + 1, &cache[n].data.b[1], WRITE, BYTE);	//writing upper byte to mem
			}
		}

		//writing new value to cache
		if (WB == WORD)
		{
			cache[n].wb = WORD;
			cache[n].data.w = *MDR;	//write data to cache whole word
		}
			
		else
		{
			cache[n].wb = BYTE;
			cache[n].lh = low_high;
			if (low_high == 'L')
				cache[n].data.b[0] = *MDR;	//write data to cache (low byte)
			else
				cache[n].data.b[1] = *MDR;	//write data to cache (high byte)
		}
		
		cache[n].db = 1;	//set dirty bit to 1
	}

	//deceremnt all usages that are greater than zero
	for (int k = 0; k < CACHE_SIZE; k++)
		if (cache[k].usage > 0)
			cache[k].usage--;
	
	cache[n].usage = MAX_USAGE;	//set new cache line's usage to max usage
	cache[n].addr = word_addr;
	return;
}

inline void cache_direct(unsigned short MAR, unsigned short* MDR, unsigned char RW, unsigned char WB)
{
	unsigned short word_addr = MAR >> 1;
	char low_high;
	if (WB == BYTE)
	{
		if (MAR == word_addr << 1)
			low_high = 'L';		//user is trying to access low byte of memory
		else
			low_high = 'H';		//user is trying to access high byte of memory
	}

	unsigned short key;
	key = word_addr & 0x000F;
	if (cache[key].addr == word_addr)	//if HIT
	{
		if (RW == READ)	//if READ
		{
			//read data in cache to MDR
			if (WB == WORD)
				*MDR = cache[key].data.w;	//read word
			else
			{
				if (low_high == 'L')
					*MDR = cache[key].data.b[0];	//read low byte
				else
					*MDR = cache[key].data.b[1];	//read high byte
			}
		}

		else			//if WRITE
		{
			if (WB == WORD)
			{
				cache[key].wb = WORD;
				cache[key].data.w = *MDR;	//write data to cache
			}
				
			else
			{
				if (cache[key].wb != WORD)
				{
					cache[key].wb = BYTE;
					cache[key].lh = low_high;
				}
				if (low_high == 'L')
					cache[key].data.b[0] = *MDR;	//write data to cache (low byte)
				else
					cache[key].data.b[1] = *MDR;	//write data to cache (high byte)
			}
			cache[key].db = 1;		//set dirty bit to 1
		}
	}

	else	//if MISS
	{
		if (RW == READ)	//READ
		{
			if (cache[key].db == 0)	//if dirty bit is not set, we can overwrite
				bus(MAR, &cache[key].data.w, READ, WORD);	//read new value from memory to cache

			else					//if DB is set
			{
				//if we need to write back entire word, write entire word, else write only lower or upper byte
				if (cache[key].wb == WORD)
					bus(cache[key].addr << 1, &cache[key].data.w, WRITE, WORD);	//write cache line to memory
				else
				{
					if (cache[key].lh == 'L')
						bus(cache[key].addr << 1, &cache[key].data.b[0], WRITE, BYTE);			//write lower byte to mem
					else
						bus((cache[key].addr << 1) + 1, &cache[key].data.b[1], WRITE, BYTE);	//write higher byte to mem
				}

				bus(MAR, &cache[key].data.w, READ, WORD);	//read new value from memory to cache
			}

			cache[key].db = 0;	//set data bit of this line to zero

			//read data in cache to MDR
			if (WB == WORD)
				*MDR = cache[key].data.w;
			else
			{
				if (low_high == 'L')
					*MDR = cache[key].data.b[0];
				else
					*MDR = cache[key].data.b[1];
			}
		}

		else			//WRITE
		{
			if (cache[key].db == 0)
			{
				if (WB == WORD)
				{
					cache[key].wb = WORD;
					cache[key].data.w = *MDR;	//write data to cache
				}
					
				else
				{
					if(cache[key].wb != WORD)
					{
						cache[key].wb = BYTE;
						cache[key].lh = low_high;
					}
					if (low_high == 'L')
						cache[key].data.b[0] = *MDR;	//write data to cache (low byte)
					else
						cache[key].data.b[1] = *MDR;	//write data to cache (high byte)
				}
			}

			else		//if DB set
			{
				if (cache[key].wb == WORD)
					bus(cache[key].addr << 1, &cache[key].data.w, WRITE, WORD);	//write cache line to memory
				else
				{
					if (cache[key].lh == 'L')
						bus(cache[key].addr << 1, &cache[key].data.b[0], WRITE, BYTE);			//writing lower byte to mem
					else
						bus((cache[key].addr << 1) + 1, &cache[key].data.b[1], WRITE, BYTE);	//writing upper byte to mem
				}

				if (WB == WORD)
				{
					cache[key].wb = WORD;
					cache[key].data.w = *MDR;	//write data to cache
				}
				else
				{
					cache[key].wb = BYTE;
					cache[key].lh = low_high;
					if (low_high == 'L')
						cache[key].data.b[0] = *MDR;	//write data to cache (low byte)
					else
						cache[key].data.b[1] = *MDR;	//write data to cache (high byte)
				}
			}

			cache[key].db = 1;	//set dirty bit to 1
		}
	}
	
	cache[key].addr = word_addr;
	return;
}

inline void cache_combined(unsigned short MAR, unsigned short* MDR, unsigned char RW, unsigned char WB)
{
	unsigned short word_addr = MAR >> 1;
	unsigned short num_lines_per_div = CACHE_SIZE / div_num;
	unsigned short max_usage = num_lines_per_div - 1;
	unsigned short index;
	char low_high;

	unsigned short div_key;
	if (div_num == 8)
		div_key = COMBINED_KEY_HASH(word_addr, div_num - 1);
	else
		div_key = COMBINED_KEY_HASH(word_addr, div_num);


	if (WB == BYTE)
	{
		if (MAR == word_addr << 1)
			low_high = 'L';		//user is trying to access low byte of memory
		else
			low_high = 'H';		//user is trying to access high byte of memory
	}

	
	for (int i = 0; i < num_lines_per_div; i++)	//this for loop accesses the correct index in the cache, and all cache lines within that division
	{
		index = div_key + i;
		if (cache[index].addr == word_addr)			//if HIT
		{
			//decrement usage of all cache lines with a higher usage than that of the hit line
			for (int j = 0; j < num_lines_per_div; j++)
			{
				if (cache[div_key + j].usage > cache[index].usage)
					cache[div_key + j].usage--;
			}

			cache[index].usage = max_usage;	//set hit line's usage to max
			if (RW == READ)	//read
			{
				if (WB == WORD)
					*MDR = cache[index].data.w;	//read data from cache
				else
				{
					if (low_high == 'L')
						*MDR = cache[index].data.b[0];	//read data from cache (low byte)
					else
						*MDR = cache[index].data.b[1];	//read data from cache (high byte)
				}
			}

			else			//write
			{
				if (WB == WORD)
				{
					cache[index].wb = WORD;
					cache[index].data.w = *MDR;	//write data to cache
				}
				else
				{
					if (cache[index].wb != WORD)
					{
						cache[index].wb = BYTE;
						cache[index].lh = low_high;
					}
					if (low_high == 'L')
						cache[index].data.b[0] = *MDR;	//write data to cache (low byte)
					else
						cache[index].data.b[1] = *MDR;	//write data to cache (high byte)
				}
				cache[index].db = 1;		//set dirty bit to 1
			}
			return;
		}
	}


	//if no hit up to this point ==> MISS
	//need to look for cache with lowest usage:
	int n = 0;
	while (cache[div_key + n].usage != 0)
		n++;

	index = div_key + n;
	if (RW == READ)
	{
		if (cache[index].db == 0)	//if dirty bit is not set, we can overwrite
			bus(MAR, &cache[index].data.w, READ, WORD);	//read new value from memory to cache

		else					//if DB is set
		{
			if (cache[index].wb == WORD)
				bus(cache[index].addr << 1, &cache[index].data.w, WRITE, WORD);	//write cache line to memory
			else
			{
				if (cache[index].lh == 'L')
					bus(cache[index].addr << 1, &cache[index].data.b[0], WRITE, BYTE);			//writing lower byte to mem
				else
					bus((cache[index].addr << 1) + 1, &cache[index].data.b[1], WRITE, BYTE);	//writing upper byte to mem
			}

			bus(MAR, &cache[index].data.w, READ, WORD);	//read new value from memory to cache
		}

		cache[index].db = 0;	//set data bit of this line to zero

		//read data in cache to MDR
		if (WB == WORD)
			*MDR = cache[index].data.w;
		else	//read as byte
		{
			if (low_high == 'L')
				*MDR = cache[index].data.b[0];
			else
				*MDR = cache[index].data.b[1];
		}
	}

	else	//WRITE
	{
		if (cache[index].db == 1) //if dirty bit is set
		{
			if (cache[index].wb == WORD)
				bus(cache[index].addr << 1, &cache[index].data.w, WRITE, WORD);	//write cache line to memory
			else
			{
				if (cache[index].lh == 'L')
					bus(cache[index].addr << 1, &cache[index].data.b[0], WRITE, BYTE);			//writing lower byte to mem
				else
					bus((cache[index].addr << 1) + 1, &cache[index].data.b[1], WRITE, BYTE);	//writing upper byte to mem
			}
		}

		//writing new value to cache
		if (WB == WORD)
		{
			cache[index].wb = WORD;
			cache[index].data.w = *MDR;	//write data to cache whole word
		}
		else
		{
			if (cache[index].wb != WORD)
			{
				cache[index].wb = BYTE;
				cache[index].lh = low_high;
			}
			if (low_high == 'L')
				cache[index].data.b[0] = *MDR;	//write data to cache (low byte)
			else
				cache[index].data.b[1] = *MDR;	//write data to cache (high byte)
		}

		cache[index].db = 1;	//set dirty bit to 1
	}

	//deceremnt all usages that are greater than zero
	for (int k = 0; k < num_lines_per_div; k++)
		if (cache[div_key + k].usage > 0)
			cache[div_key + k].usage--;

	cache[index].usage = max_usage;	//set new cache line's usage to max usage
	cache[index].addr = word_addr;	//save its address
	return;
}


void flush_cache(void)
{
	for (int i = 0; i < CACHE_SIZE; i++)
	{
		if (cache[i].wb == WORD)
			bus(cache[i].addr << 1, &cache[i].data.w, WRITE, WORD);	//write cache line to memory
		else
		{
			if (cache[i].lh == 'L')
				bus(cache[i].addr << 1, &cache[i].data.b[0], WRITE, BYTE);			//writing lower byte to mem
			else
				bus((cache[i].addr << 1) + 1, &cache[i].data.b[1], WRITE, BYTE);	//writing upper byte to mem
		}
	}
}