#ifndef LOADER_H
#define LOADER_H

#define MAX_LEN 256								// Max record length
#define DATA_START 8							// Start reading data after 8th nibble in S-record

int loader(int argc, char* argv[]);
int extract_header_type(char buffer[MAX_LEN]);
int extract_data_type(char buffer[MAX_LEN]);
int extract_address_type(char buffer[MAX_LEN]);

#endif
