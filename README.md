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
    2. Main Instruction Execution
       1. Fetch
       2. Decode
       3. Execute
    4. Memory Access
        1. Direct Memory Access
        2. Direct Cache Access
        3. Associative Cache Access
        4. Combined Cache Access
    5. Instructions
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

### The Debugger
The debugger allows the user a much higher degree of control over the execution of the code and the visualization of the data. The debugger menu is shown below:

Choose one of the following:
QUIT              : (0)
CONTINUE          : (1)
Change PC         : (2)
Set new breakpoint: (3)
View Registers    : (4)
Modify Registers  : (5)
View Memory       : (6)
Modify cache type : (7)

#### The "Continue" Statement
The Continue statement allows you to progress one step in the code execution. This essentially runs the fetch-decode-execute cycle once, and finishes by progressing the program counter by 2 unless otherwise controlled by an instruction.

#### Change PC
Change PC allows the user to change the program counter to any "valid" value, regardless of the state of the machine at the moment. A valid value for the program counter would be a non-negative (zero is allowed), even number, up to and including #FFFE. Once the program is resumed, or the next cycle is requested through the "Continue" statement, the next instruction fetched will be the one that lies where the program counter was set.

#### Set New Breakpoint
Set new breakpoint allows the user to run the code continuously untill the program counter hits the breakpoint or reaches end of memory. The breakpoint is limited to valid PC values, and is allowed to be set at a lower PC value than the current PC value. After a breakpoint is set, the continuous execution function will be called and ran. Note that when a breakpoint is hit, that instruction will NOT execute, meaning that the next fetch-decode-execute cycle will fetch and use that instruction. This is similar to how breakpoints work in modern IDEs.

#### View Registers
Shows a list of all registers as well as the Program Status Word (PSW) bits (see XM23 Architecture - Registers), and the current value in the instruction register. Note that the program counter is simply register 7 (R7), so that is the value of the program counter.

#### Modify Registers
Allows you to set any valid (#0000 - #FFFF) value to any register and it will be changed imidietly and be used when the program is continued.

#### View Memory
Prompts the user to enter a memory range that they are interested in viewing the contents of.

#### Modify Cache Type
This option allows the user to change, on the fly, between direct memory access (no cache), direct cache access, associative cache access, or combined cache access. See "XM23 Architecure - Cache" for more details about each cachce type. Note that if "combined cache" is chosen, an additional choice will be presented to the user, prompting them to choose the number of divisions the combined cache should have (2, 4, or 8).

Note that the debugger menu reapears after a choice has been selected and performed.

With the features outlined above, the debugger acts as a powerful tool for debugging not only the ASM code written, but the emulator itself. Viewing memory and register values is extremely beneficial, especially when done side by side with the .LIS file that shows the memory address, and value of each instruction.

### Output and Print Settings
As outlined above, the user has some choice on the output of the XM23 emulator. The user can choose both the verbosity of the output and the destination location. Some output, such as menus and debugging information cannot be modified, and will always be printed to STDOUT with one defined verbosity. Some (rare) errors raised by interrupts are also printed to STDOUT and not the specified destination.

A user can choose to print the remaining data (eg. information streamed by the emulator during its excution) either to STDOUT or to a file. At the end of program execution, the user can choose to empty the entire memory into a file in the working directory. Note that a Cache Dump is performed prior to this to ensure memory coherence.

Lastly, as mentioned above, the destination and verbosity of your prints do have a significant impact on performance, with increasing verbosity being (slightly) slower, and printing to STDOUT rather than to a file being orders of magnitudes slower. Not printing anything at all (verbosity set to 0) is the fastest. Note that this is not an issue with the implementation of the emulator itself but just a general property of printing to STDOUT which prints to the screan, rather than to a file stored in your computer's memory, or more likely  CPU's cahce.

## Emulator Architecure
The following presents the general approach taken when developing some of the key features of the program. This is intended to give a brief overview of how the code is structured and where main modules are located.

### The Loader
The loader.c and loader.h files constitute a module for processing S-record files within the application. The loader function is the main interface, designed to handle command line inputs specifying the S-record file to be processed. Within the loader function, each line of the provided file is read and classified based on its S-record type, initiating tailored extraction processes for each type.

The extract_header_type function processes S0 record type, presenting the file name and verifying the checksum for data integrity. For the S1 record type, extract_data_type function is called, performing the task of loading instructions into the defined memory address and conducting a checksum verification. Handling the S9 record type, the extract_address_type sets the Program Counter's starting address in alignment with the S-record. Each of these functions returns 0 upon successful completion, and 1 in the event of a checksum error. In a scenario where no file is provided, or it fails to open, the loader function will return -1. This robust error handling ensures smooth operation and ease of troubleshooting, aiding in the effective utilization of the module in your application. Including loader.h in your program allows seamless access to these functionalities, enhancing the handling and processing of S-record files within your application environment.

Note that the loader is NOT meant to check the validity of your code. If you are to enter data that is valid in length and style, and the checksum matches, the loader will input it into memory. Once must relay on the assembler and their assembly skills to write correct code.

### Main Instruction Execution
Whether called through the debugger or through the continuous execution mode, the fetch-(increment)-decode-execute cycle remains the same, and is the core of the emulated CPU's computing loop.

#### Fetch
The fetch() function is does more than just fetch the instruction pointed to by the program counter. When the fetch function is called, a few crucial checks must occur before the emulator determines that it is acceptible to fetch the instruction. First, the test_for_ISR_exit() function is called to ensure that it is not currently attempting to exit an interrupt service routine. This is expanded upon more in the XM23 Architecture section, but in short, due to the XM23 being a RISC architecture, there exists no "ret" instruction meaning that we must find another way to signal to the CPU that program execution should be handed back to the main routine. This is done by setting the PC to the invalid value of #FFFF. When this is detected, the program exists the service routine.
Next, the fetch function calls the test_for_cex() function which determines if we are to skip any incoming instruction due to the CEX's conditional execution fields. This is explained more in depth in the full ISA, but in short, the CEX instruction allows some branch-like PC control embedded in the instruction data itself.
Lastly, the fetch function checks for an illegal program counter, and raises the illegal address fault if it encounters it.
Once all of the above has been verified, the fetch function calls the cache_func() which in turn loads the instsruction register with the data pointed to by the program counter (more on this in the Memory section).

#### Decode
In the main execution cycle there is no "decode" function, rather a decode_inst() which acts as a "decode + execute" function. This function does both the decoding, and then without returning to the main loop, executes the desired instruction. This is purely to save overhead when calling the function, and removing the need to return a function pointer to the main loop just to use it again the next line.

The decode portion of the function is essentially a large switch statement that covers all viable opcode possibilites. The function recieves the instruction register as input and provides it as the switch statement's argument. The switch statement then bitwise ANDs the instruction register with a mask of the appropriate opcode length in each case and compares it to the masked opcode defined in the "instructions.h" header file. Through a series of nested switch-cases the function is able to decode the instruction and call the correct function to execute it.

Note that if the opcode does not match into any of the cases, the default case is to call the illegal instruction interrupt service routine.

#### Execute
As explained above, there is no individual "execute" function. Once an instruction is decoded, the appropriate function to execute that specific instruction is called, and is provided with the instruction register as the argument. Nothing other than the contents of the instruction register is provided in the function call.

While most instructions have a unique function, some share nested common functions. For example, the ADD function and the SUB function both call the exec_ADDITION() function when they are called but provide it with different function arguments derived from the contents of the instruction register. More on this can be found in the complete ISA or by looking through the code. Additional functions are often shared such as updating the PSW or branching to a different location in the code.
