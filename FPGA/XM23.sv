module XM23 (
    input wire clock_in,    // Input clock (50 MHz from the FPGA)
    input wire reset,       // Reset signal
    output reg clock,       // This is the global clock for other modules
    output reg led          // LED output (blinking to confirm clock)
);
    reg [31:0] counter = 0;
    parameter DIVIDER = 50_000_000;  // Divides 50 MHz clock to desired speed

    // Clock divider logic
    always @(posedge clock_in or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clock <= 0;
            led <= 0;
        end else if (counter == (DIVIDER - 1)) begin
            clock <= ~clock;  // Toggle the clock output
            led <= ~led;      // Toggle the LED (LED will blink)
            counter <= 0;     // Reset the counter
        end else begin
            counter <= counter + 1;
        end
    end
	 
	 
	 // Internal signals
    logic [15:0] inst;
	 inst <= 0100_0000_0000_1000;	// add, (registers), (word size), from reg 000 + 001, save in reg 000

	 
	 decode_stage decode(.inst(inst));
endmodule
