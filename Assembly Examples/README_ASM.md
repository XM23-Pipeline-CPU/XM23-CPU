# XM23 ASM Introduction
The following contains information about the:
- XM23 assembly files (.asm)
- XM23 executable files (.xme)
- XM23 Assembler

## XM23 Assembly Files
The XM23 assembly files use the XM23 assembly language detailed in the ISA and invented by Prof. Larry Hughes.
The ISA uses a RISC architecture partially inspired by ARM and other older RISC architectures.
The language is mainly designed to be simple enough to be taught to students yet have enough complexity to be relevant to our studies in 2023.

## XM23 Executable Files
The .xme file represents the XM23's version of an .exe - an executable file.
This file is fed directly to the XM23 emulator as is, and contains all executation information.
The uses the S-records approach to store data in the following manner:
- There are three types of S records:
  - S0: Specifies file name
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
