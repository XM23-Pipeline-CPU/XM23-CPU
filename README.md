# XM23-Emulator
A built from the ground up emulator for the XM23 RISC architecture featuring full support of the XM23 assembly language.

## ReadMe contents
The following readme provides all the basic information one must know to use, operate, or develop for the XM23 emulator. The following outlines the contents of the document.

1. Introduction and Background
2. Important Information
    1. Must Knows
    2. Most Important Files
3. Developing Code
    1. ASM Files
    2. XME Files
    3. The XM23 Assembler
    4. How to Use
    5. Recommendations
4. Executing Code
5. Emulator Features
    1. The Main Menu
    2. The Debugger
        1. The "Continue" Statement
        2. Change PC
        3. Set New Breakpoint
        4. View Registers
        5. Modify Registers
        6. View Memory
        7. Modify Cache Type
    3. Output and Print Settings
6. Emulator Architecture
    1. The Loader
    2. Emulater Interface
    3. The Debugger
    4. Main Instruction Execution
    5. Memory Access
        1. Direct Memory Access
        2. Direct Cache Access
        3. Associative Cache Access
        4. Combined Cache Access
    6. Instructions
7. XM23 Architecture
    1. RISC Architecture
    2. Registers
    3. Memory
    4. Cache
    5. Instructions

## Introduction and Background
The XM23 emulator was developed from the ground up in native C for the Computer Architecture course provided by Dalhousie University and led by Prof. Larry Hughes. This was an individual project that spanned the length of the entire semester (3+ months). The XM23 is a small power efficient RISC chip being developed by Dalhousie University. Third year Computer Engineering students were tasked with creating a fully functioning emulator for the chip that will support the entirety of the ISA. The ISA was provided to students at the start of the semester, and a significant portion of the development was done independently.

After the complition of the semester, I have added to, and optimized my implementation of the emulator. Additional features not required by the course are in the work and will be added with time.

## Important Information
This section outlines some important information regarding the emulator itself, as well as other important files and documents.

### Must Knows
The XM23 Emulator is based on the ISA developed by Prof. Larry Hughes. The most important features of the architecture are outlined in this README file, but for the full, detailed, specifics please refer to "XM-23 - ISA.pdf" Under "Full ISA". This document is over 100 pages long and outlines all the information about the architecture. Additionally, an up to date instruction set is available in "Revised XM23 Instruction Set.xlsx" under the same folder. Please refer to this instruction set and not the one outlined on the last page of the ISA. They have slight differences, and the emulator follows the "Revised XM23 Instruction Set.xlsx".

### Important Files
The emulator was built fully from the ground up with native C and does not have any external dependencies other than those in the C standard library. The following explains the file structure in the code base:
- emulator.c: Main menu, calls debugger.c for all execution related matters.
- loader.c + loader.h: this file is responsible for loading the .XME file into memory and reporting for any issues. Issues such as unexpected output, or an invalid checksum (see "XME Files") will result in program termination before the main menu is presented to the user.
- debugger.c + debugger.h: Allows for all debugging and execution functionality. This file runs the fetch, decode, execute cycle and determines the flow of the program. This file, along with CPU.c and memory.c is the most important to take a close look at when reading through the code.
- CPU.c + CPU.h: this is by far the longest and most dense file in the repo. This file contains all execution functions for all instructions. The decode function is called by debugger.c and is executed in CPU.c. Once the instruction has been decoded, the corrisponding execution function is called and is executed in CPU.c. Control is given back to debugger.c after the instruction has done executing, or the user hit CTRL_C.
- memory.c + memory.h: this file is responsible for all memory and cache operations. Whenever a call to the memory is made, the "bus" function is called and executed. The bus function is the only way in the code that memory is accessed, and memory is never accessed directly through the array (eg. mem[###] = ? is never used outside of the bus function itself). This is crutial and is by design to stay true to real CPU execution even though it adds a lot of theoretically unnecessary overhead.
- XMPrint.c + XMPrint.h: this file is simply responsible for printing anything to the screan that may have more than one verbosity setting that can be set by the user.
- instructions.h: This defines all instruction opcodes to be used by the decoder.

## Developing Code
The following section outlines how can develop their own XM23 ASM to be ran by the emulator.

### ASM Files
The XM23 assembly files use the XM23 assembly language detailed in the ISA and invented by Prof. Larry Hughes. The ISA uses a RISC architecture partially inspired by ARM and other older RISC architectures. The language is mainly designed to be simple enough to be taught to students yet have enough complexity to be relevant to our studies in 2023.

### XME Files
The .xme file represents the XM23's version of an .exe - an executable file. This file is fed directly to the XM23 emulator as is, and contains all executation information. The uses the S-records approach to store data in the following manner:

- There are three types of S records:
    - S0: Specifies file name.
    - S1: Specifies all instructions and data to be executed and put into memory (uses Von Neumann architecture).
    - S9: Stores the starting address of the program.
- Each S-record is built as follows:
    - Length of S-record (1 byte) specified in Hex as 0x##. This length does NOT include itself but includes all other parts of the S-record that come after.
    - Address that S-record starts at (2 bytes) specified in Hex as 0x####.
    - Instructions/Data (up to 16 byes) specified in Hex as 0x######....
    - Checksum (1 byte) specified in Hex as 0x## that is the 1's compliment of the sum of all of the preceding (length, address, and data). The XM23 executable has no size limit and can include an as many S1 records as needed, but must only always have one S0 record (at the start) and one S9 record (at the end).

### XM23 Assembler
Credit to Prof. Larry Hughes for designed the assembler. The assembler converts all valid XM23 asm code to valid .xme files, as well as creates a .lis file for help in debugging. The assembler supports multiple pass assembly and so supports lablels. Exact details about the assembler's source code are not known to me.

### How to Use
To a .asm file found in the repo, or that you have wrote on your own, drag and drop it into the XM23ASSMBLR.exe file provided. The assembler will assemble the code and inform you of any sintax errors or invalid statements. If assembled correctly, two files will be added to the working directory:
- A .xme file will be the executable that will be fed to the XM23 assembler.
- A .lis file will proivde additional information added to the original .asm file that may be extremely useful when debugging code. The .lis file contains line numbers, memory addresses, instructions translated to hex (very useful for comparing with computer memory during debugging) for each instruction, as well as a symbol table at the end.

### Recomendations
If you are using the emulator for the first time I would recomend starting with the prime sieve example as it is the most visual and "useful" program. Assemble the PRIME_SIEVE.asm file by dragging it into the XM23ASSMBLR.exe file and then drag the newly genrated PRIME_SIEVE.xme file into the emulator. You can run the emulator either in debug mode or in continuous mode, but be sure to look at the memory at the end. The primes will be stored (in HEX) in memory locations 0xA000 and onwards (up to about 0xC###). All memory locations 0x0000 - 0x7000 will also be marked with either a 0 or a 1. If marked a 0, that memory location is prime, if marked 1, not a prime (eg. memory location 7 will store the value 0x00, while memory location 8 will store 0x01).

I recommend also running count_strings.asm and modifying the string in the assembly file to whatever you want (note that the string is limited in length due to assembler implementation, but the emulator can in theory handle a string of any size (up to memory constraints)).

There are a few other files that can be ran, such as SVC.asm that involves calling a service routine and pushes variables to the stack, that are useful to execute as well.

I have many more .asm files that can be added upon request.

Most of all, I recommend writing your own assembly file and see what you can create! I am sure some impressive things can be done with eight 16-bit registers and 64kib of memory!

## Executing Code
As briefly mentioned above, to execute code one must drag and drop a single (added functionality coming soon) XME file onto the emulator executable. If the file has been loaded correctly (all checksums match up and there are no unexpected characters) you will be prompted with the main menu and will be able to execute your code as desired. Please read the following section for explenations as to the methods and options you have in executing your code.

## Emulator Features
The emulator boasts a number of ways in which you can interact with and execute your code, view the CPU memory and registers, modify values as needed, debug, output, and save information. This section outlines such features.

### The Main Menu
Once your file has been loaded onto the emulator and the loader has confirmed a successful upload of its contents onto the CPU memory, you will be prompted with the emulator's main menu. You may be underwhelmed by the somewhat limited number of options that first appear on screan, but fear not, most extended features are available in debug mode if you require them. In the main menu you will see the below:
Choose the following:
0 - QUIT
1 - Run until end of memory
2 - Run in Debug Mode
3 - Modify print settings

"Run until end of memory" will execute all instructions (or data if you have written poor code), starting from the address specified in the S9 record of your XME, all the way to address location #FFBE. The reason that this function does not execute up to #FFFE is learned about more "XM23 Architecture - Memory" but has to do with those memory locations being reserved for interrupt handlers.

"Run in Debug Mode" will prompt the user with a new, much more extensive menu for running the code with all debugger options available. This will be expanded upon more soon.

"Modify print settings" will allow the user to choose the verbosity of the emulator output, as well as if they want it to be printed to STDOUT or to an output file. Note that printing to an output file (and not printing at all) is orders of magnitudes faster than printing to STDOUT, so if you are bencharking your system, that is the way to go.

## The Debugger
asdasd
