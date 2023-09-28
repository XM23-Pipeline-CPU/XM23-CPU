# XM23-Emulator
A built from the ground up emulator for the XM23 RISC architecture featuring full support of the XM23 assembly language.

## ReadMe contents
The following readme provides all the basic information one must know to use, operate, or develop for the XM23 emulator. The following outlines the contents of the document.

1. Introduction and Background
2. Important Information
    1. Must Knows
    2. Most Important Files
3. Developing Code
    1. The Assembler
    2. ASM Files
    3. LIS Files
    4. XME Files
4. Executing Code
5. Emulator Features
    1. Main Menu
    2. Methods of Execution
    3. Debugging
        1. The "Continue" Statement
        2. Change PC
        3. Set New Breakpoint
        4. View Registers
        5. Modify Registers
        6. View Memory
        7. Modify Cache Type
    4. Output and Print Settings
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
