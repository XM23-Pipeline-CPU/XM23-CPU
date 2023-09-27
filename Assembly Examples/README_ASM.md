# XM23 ASM Introduction
The following contains information about the:
- XM23 assembly files (.asm)
- XM23 executable files (.xme)
- XM23 Assembler
- How to Use
- Recommendations

## XM23 Assembly Files
The XM23 assembly files use the XM23 assembly language detailed in the ISA and invented by Prof. Larry Hughes.
The ISA uses a RISC architecture partially inspired by ARM and other older RISC architectures.
The language is mainly designed to be simple enough to be taught to students yet have enough complexity to be relevant to our studies in 2023.

## XM23 Executable Files
The .xme file represents the XM23's version of an .exe - an executable file.
This file is fed directly to the XM23 emulator as is, and contains all executation information.
The uses the S-records approach to store data in the following manner:
- There are three types of S records:
  - S0: Specifies file name.
  - S1: Specifies all instructions and data to be executed and put into memory (uses Von Neumann architecture).
  - S9: Stores the starting address of the program.
- Each S-record is built as follows:
  - Length of S-record (1 byte) specified in Hex as 0x##. This length does NOT include itself but includes all other parts of the S-record that come after.
  - Address that S-record starts at (2 bytes) specified in Hex as 0x####.
  - Instructions/Data (up to 16 byes) specified in Hex as 0x######....
  - Checksum (1 byte) specified in Hex as 0x## that is the 1's compliment of the sum of all of the preceding (length, address, and data).
The XM23 executable has no size limit and can include an as many S1 records as needed, but must only always have one S0 record (at the start) and one S9 record (at the end).

## XM23 Assembler
Credit to Prof. Larry Hughes for designed the assembler.
The assembler converts all valid XM23 asm code to valid .xme files, as well as creates a .lis file for help in debugging.
The assembler supports multiple pass assembly and so supports lablels.
Exact details about the assembler's source code are not known to me.

## How to Use
To a .asm file found in the repo, or that you have wrote on your own, drag and drop it into the XM23ASSMBLR.exe file provided. The assembler will assemble the code and inform you of any sintax errors or invalid statements.
If assembled correctly, two files will be added to the working directory:
- A .xme file will be the executable that will be fed to the XM23 assembler.
- A .lis file will proivde additional information added to the original .asm file that may be extremely useful when debugging code. The .lis file contains line numbers, memory addresses, instructions translated to hex (very useful for comparing with computer memory during debugging) for each instruction, as well as a symbol table at the end.

## Recomendations
If you are using the emulator for the first time I would recomend starting with the prime sieve example as it is the most visual and "useful" program. Assemble the PRIME_SIEVE.asm file by dragging it into the XM23ASSMBLR.exe file and then drag the newly genrated PRIME_SIEVE.xme file into the emulator. You can run the emulator either in debug mode or in continuous mode, but be sure to look at the memory at the end. The primes will be stored (in HEX) in memory locations 0xA000 and onwards (up to about 0xC###).
All memory locations 0x0000 - 0x7000 will also be marked with either a 0 or a 1. If marked a 0, that memory location is prime, if marked 1, not a prime (eg. memory location 7 will store the value 0x00, while memory location 8 will store 0x01). 

I recommend also running count_strings.asm and modifying the string in the assembly file to whatever you want (note that the string is limited in length due to assembler implementation, but the emulator can in theory handle a string of any size (up to memory constraints)).

There are a few other files that can be ran, such as SVC.asm that involves calling a service routine and pushes variables to the stack, that are useful to execute as well.

I have many more .asm files that can be added upon request.

Most of all, I recommend writing your own assembly file and see what you can create! I am sure some impressive things can be done with eight 16-bit registers and 64kib of memory!
