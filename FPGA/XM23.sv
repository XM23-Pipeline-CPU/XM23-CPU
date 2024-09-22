module XM23 (
    input wire clk_in,    // Input clk (50 MHz from the FPGA)
    input wire reset,       // Reset signal
    output reg clk,       // This is the global clk for other modules
    output reg led          // LED output (blinking to confirm clk)
);
    reg [31:0] counter = 0;
    parameter DIVIDER = 50_000_000;  // Divides 50 MHz clk to desired speed

    // clk divider logic
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk <= 0;
            led <= 0;
        end else if (counter == (DIVIDER - 1)) begin
            clk <= ~clk;  // Toggle the clk output
            led <= ~led;      // Toggle the LED (LED will blink)
            counter <= 0;     // Reset the counter
        end else begin
            counter <= counter + 1;
        end
    end
	 
	 
	 // Internal signals
	 logic [15:0] inst;

	 always_comb begin
		  inst <= 16'b0100_0000_0000_1000; // add, (registers), (word size), from reg 000 + 001, save in reg 000
	 end

	 
	 decode_stage decode(.inst(inst));
endmodule
