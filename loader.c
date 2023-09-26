#include "cpu.h"
#include <stdio.h>
#include <stdint.h>

#define RELEASE
						
//S-records format
//S# ## #### #......
//01 23 4567 8......

/// <summary>
/// Takes in the command line arguments from the main function and loades the s-record file
/// according to the record types inside of it.
/// </summary>
/// <param name="argc"></param>
/// <param name="argv"></param>
/// <returns></returns>
int loader(int argc, char* argv[])
{
#ifdef RELEASE
	if (argc < 2)	//if no input file
	{
		printf("No file inputed. Press any key to quit.");
		getchar();
		return -1;
	}
#endif
	FILE* fin = NULL;
	int s_type;
	char buffer[MAX_LEN];					//array to read in s-records
#ifdef RELEASE
	fopen_s(&fin, argv[1], "r");
#endif
#ifdef DEBUG
	fopen_s(&fin, "PRIME_SIEVE.xme", "r");
#endif // DEBUG
	if (fin == NULL)						//if failed to open
		return -1;

	while (fgets(buffer, MAX_LEN, fin) != NULL) //reading new line from file into buffer
	{
		sscanf_s(&buffer[1], "%1x", &s_type);	//read S record type into variable.
		if (s_type == 0)		//header type
		{
			if (extract_header_type(buffer))
				return 1;
		}
		else if (s_type == 1)	//Data/Instruction type
		{
			if (extract_data_type(buffer))
				return 1;
		}
		else if (s_type == 9)	//Starting address type
		{
			if (extract_address_type(buffer))
				return 1;
		}
		else
		{
			printf("Invalid record type. Press any key to quit.");
			getchar();
			return 1;
		}
	}
	fclose(fin);
	return 0;
}

/// <summary>
/// Extracts S-record type 0
/// Prints file name on screen.
/// </summary>
/// <param name="buffer"></param>
int extract_header_type(char buffer[MAX_LEN])
{
	unsigned int s_length;
	unsigned int s_addL, s_addH;
	unsigned int s_data;
	unsigned int s_checksum;
	uint8_t calc_CS = 0;						//saved as uint8 so that data can overflow and wrap back to zero	
	printf("Record type: S0    File name: ");
	sscanf_s(&buffer[2], "%02x", &s_length);	//gets length of remaining 
	sscanf_s(&buffer[4], "%02x", &s_addH);		//gets starting address of record high
	sscanf_s(&buffer[6], "%02x", &s_addL);		//gets starting address of record low
	calc_CS += s_length + s_addH + s_addL;

	for (int i = DATA_START; i <= s_length*2; i += 2)	//extracts data byte by byte upto checksum (exclusive)
	{
		sscanf_s(&buffer[i], "%02x", &s_data);
		calc_CS += s_data;
		printf("%c", s_data);
	}
	sscanf_s(&buffer[(s_length+1)*2], "%02x", &s_checksum);		//extract checksum byte
	calc_CS += s_checksum;
	if (calc_CS != 0xFF)
	{
		printf("\nChecksum does not compute, error in data transmission.");
		printf("\n\nPress any key to quit.");
		return 1;
	}
	else
		printf("\nChecksum computes, no errors in data transmission.");
	printf("\n\n");
	return 0;
}

/// <summary>
/// Extarcts S-record type 1
/// Loads instructions into memory specified by address at start of record
/// </summary>
/// <param name="buffer"></param>
int extract_data_type(char buffer[MAX_LEN])
{
	printf("Record type: S1    ");
	unsigned int s_length;
	unsigned int s_address, s_addL, s_addH;
	unsigned int s_data;
	unsigned int s_checksum;
	uint8_t calc_CS = 0;						//saved as uint8 so that data can overflow and wrap back to zero
	sscanf_s(&buffer[2], "%02x", &s_length);	//gets length of remaining characters
	sscanf_s(&buffer[4], "%02x", &s_addH);		//gets starting address of record high
	sscanf_s(&buffer[6], "%02x", &s_addL);		//gets starting address of record low
	calc_CS += s_length + s_addH + s_addL;
	s_address = (s_addH << 8) | s_addL;			//save low and high address bytes into one word sized variable 
												//shifting high byte 8 bits to the left and "oring" with low byte

	int offset = 0;
	for (int i = DATA_START; i <= s_length * 2; i += 2)	//extracts data byte by byte upto checksum (exclusive)
	{
		sscanf_s(&buffer[i], "%02x", &s_data);
		calc_CS += s_data;
		mem.b[s_address + offset] = s_data;
		//print function bitwise ands with 0xFF to avoid sign extension
		//printf("Memory: %04x    Data: %02x\n", (s_address + offset), mem.b[s_address + offset] & 0xFF); 
		offset++;
	}
	printf("Loaded into memory\n");
	sscanf_s(&buffer[(s_length + 1) * 2], "%02x", &s_checksum);		//extract checksum byte
	calc_CS += s_checksum;
	if (calc_CS != 0xFF)
	{
		printf("Checksum does not compute, error in data transmission.");
		printf("\n\nPress any key to quit.");
		return 1;
	}
	else
		printf("Checksum computes, no errors in data transmission.");
	printf("\n\n");
	return 0;
}

/// <summary>
/// Extracts S-record type 9
/// Specifies the Program counter's starting address from the s-record
/// </summary>
/// <param name="buffer"></param>
int extract_address_type(char buffer[MAX_LEN])
{
	unsigned int s_length;
	unsigned int start_addr, s_addH, s_addL;
	unsigned int s_checksum;
	uint8_t calc_CS = 0;						//saved as uint8 so that data can overflow and wrap back to zero
	printf("Record type: S9    Start Address: ");
	sscanf_s(&buffer[2], "%02x", &s_length);	//gets length of remaining characters
	sscanf_s(&buffer[4], "%02x", &s_addH);		//gets starting address of record high
	sscanf_s(&buffer[6], "%02x", &s_addL);		//gets starting address of record low
	calc_CS += s_length + s_addH + s_addL;
	start_addr = (s_addH << 8) | s_addL;
	PC.w = (unsigned short)start_addr;
	printf("%04x", start_addr);
	sscanf_s(&buffer[(s_length + 1) * 2], "%02x", &s_checksum);		//extract checksum byte
	calc_CS += s_checksum;
	if (calc_CS != 0xFF)
	{
		printf("\nChecksum does not compute, error in data transmission.");
		printf("\n\nPress any key to quit.");
		return 1;
	}
	else
		printf("\nChecksum computes, no errors in data transmission.");
	printf("\n\n");
	return 0;
}