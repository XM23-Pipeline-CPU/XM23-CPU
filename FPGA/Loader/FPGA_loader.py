import sys, os
from datetime import datetime

# Constants
MAX_LEN = 256
DATA_START = 8  # Start index of data in the S-record

# Function to write MIF file headers
def write_mif_header(file):
    # Get the current date and time
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Write the date and time as a comment at the top
    file.write("-- XM23 ASM to FPGA MIF File Conversion\n")
    file.write("-- Roee Omessi and Vlad Chiriac\n")
    file.write(f"-- MIF File generated on {current_time}\n\n\n")
    
    # Write the MIF header details
    file.write("WIDTH=16;\n")
    file.write("DEPTH=32768;\n")
    file.write("ADDRESS_RADIX=HEX;\n")
    file.write("DATA_RADIX=HEX;\n")
    file.write("CONTENT BEGIN\n")

# Function to close MIF file properly
def close_mif(file):
    file.write("END;\n")
    file.close()

# Function to extract S-record type 0 (header type)
def extract_header_type(buffer):
    calc_CS = 0
    print("Record type: S0    File name: ", end="")

    s_length = int(buffer[2:4], 16)     # Parses as hex
    s_addH = int(buffer[4:6], 16)       # Parses as hex
    s_addL = int(buffer[6:8], 16)       # Parses as hex
    calc_CS += s_length + s_addH + s_addL

    for i in range(DATA_START, s_length * 2 + 1, 2):
        s_data = int(buffer[i:i+2], 16)         # Extract next two hex digits
        calc_CS += s_data                       # Add to the checksum
        print(chr(s_data), end="")

    CS_index = (s_length+1)*2
    s_checksum = int(buffer[CS_index:CS_index+2], 16) # Extract as hex
    calc_CS += s_checksum

    if (calc_CS % 256) != 0xFF:
        print("\nChecksum does not compute, error in data transmission.")
        return 1
    else:
        print("\nChecksum computes, no errors in data transmission.")
    print("\n")
    return 0

# Function to extract and write data/instruction type to program memory MIF
def extract_program_type(buffer, program_file):
    calc_CS = 0
    print("Record type: S1    ")

    s_length = int(buffer[2:4], 16)
    s_addH = int(buffer[4:6], 16)
    s_addL = int(buffer[6:8], 16)
    calc_CS += s_length + s_addH + s_addL

    # Translating byte starting address to words
    s_address = ((s_addH << 8) | s_addL) >> 1
    offset = 0

    first = True
    wide_data = 0
    for i in range(DATA_START, s_length * 2 + 1, 2):
        s_data = int(buffer[i:i+2], 16)
        calc_CS += s_data
        if first:
            wide_data = s_data
            first = False
        else: # Write to program MIF file
            wide_data += (s_data << 8)
            program_file.write(f"{s_address + offset:04X} : {wide_data:04X};\n")
            offset += 1
            first = True
        

    print("Written to program MIF file")

    CS_index = (s_length + 1)*2
    s_checksum = int(buffer[CS_index:CS_index+2], 16) # Extract as hex
    calc_CS += s_checksum

    if (calc_CS % 256) != 0xFF:
        print("Checksum does not compute, error in data transmission.")
        return 1
    else:
        print("Checksum computes, no errors in data transmission.")
    print("\n")
    return 0

# Function to extract and write data type to data memory MIF
def extract_data_type(buffer, data_file):
    calc_CS = 0
    print("Record type: S2    ")

    s_length = int(buffer[2:4], 16)
    s_addH = int(buffer[4:6], 16)
    s_addL = int(buffer[6:8], 16)
    calc_CS += s_length + s_addH + s_addL

    # Translating byte starting address to words
    s_address = ((s_addH << 8) | s_addL) >> 1
    offset = 0

    first = True
    wide_data = 0
    for i in range(DATA_START, s_length * 2 + 1, 2):
        s_data = int(buffer[i:i+2], 16)
        calc_CS += s_data
        if first:
            wide_data = s_data
            first = False
        else: # Write to program MIF file
            wide_data += (s_data << 8)
            data_file.write(f"{s_address + offset:04X} : {wide_data:04X};\n")
            offset += 1
            first = True

    print("Written to data MIF file")

    CS_index = (s_length + 1)*2
    s_checksum = int(buffer[CS_index:CS_index+2], 16) # Extract as hex
    calc_CS += s_checksum

    if (calc_CS % 256) != 0xFF:
        print("Checksum does not compute, error in data transmission.")
        return 1
    else:
        print("Checksum computes, no errors in data transmission.")
    print("\n")
    return 0

# Function to extract S-record type 9 (starting address type)
def extract_address_type(buffer, program_file):
    calc_CS = 0
    print("Record type: S9    Start Address: ", end="")

    s_length = int(buffer[2:4], 16)
    s_addH = int(buffer[4:6], 16)
    s_addL = int(buffer[6:8], 16)
    calc_CS += s_length + s_addH + s_addL

    # Convert byte address to Word address
    start_addr = ((s_addH << 8) | s_addL)

    # Write starting address into reserved spot in data_file
    program_file.write(f"{0x7FFF:04X} : {start_addr:04X};\n")

    print(f"{start_addr:04x}")
    CS_index = (s_length + 1)*2
    s_checksum = int(buffer[CS_index:CS_index+2], 16)
    calc_CS += s_checksum

    if (calc_CS % 256) != 0xFF:
        print("Checksum does not compute, error in data transmission.")
        return 1
    else:
        print("Checksum computes, no errors in data transmission.")
    print("\n")
    return 0

# Loader function to handle the main logic of reading the S-record file
def loader(argv):
    if len(argv) < 2:
        print("No file inputted. Press any key to quit.")
        input()
        return -1

    file_name = argv[1]

    # Open two MIF files for writing
    program_mif = open("program_memory.mif", "w")
    data_mif = open("data_memory.mif", "w")

    # Write headers to both MIF files
    write_mif_header(program_mif)
    write_mif_header(data_mif)

    try:
        with open(file_name, "r") as file:
            for line in file:
                buffer = line.strip()
                s_type = int(buffer[1])  # Read S-record type
                if s_type == 0:
                    if extract_header_type(buffer):     # Handle header
                        return 1
                elif s_type == 1:
                    if extract_program_type(buffer, program_mif):    # Handle program memory
                        return 1
                elif s_type == 2:
                    if extract_data_type(buffer, data_mif):       # Handle data memory
                        return 1
                elif s_type == 9:
                    if extract_address_type(buffer, program_mif):    # Handle starting address
                        return 1
                else:
                    print("Invalid record type. Press any key to quit.")
                    input()
                    return 1
    except FileNotFoundError:
        print(f"Failed to open file: {file_name}")
        return -1
    finally:
        # Close the MIF files
        close_mif(program_mif)
        close_mif(data_mif)

    return 0

# Main function
# Main function
if __name__ == "__main__":
    result = loader(sys.argv)

    if result == 1:
        # If any function returned 1, delete the MIF files
        try:
            os.remove("program_memory.mif")
            os.remove("data_memory.mif")
            print("MIF files deleted due to an error.")
        except FileNotFoundError:
            print("Failed to delete MIF files. They might not have been created.")
    sys.exit(result)