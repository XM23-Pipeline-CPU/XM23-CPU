// alu_top_level.sv
module alu_top_level (
    input  logic [15:0] switches,       // 16 switches for input values
    input  logic [1:0] selector,        // 2 switches to select SRC, DST, mode_select, carry_in
    input  logic push_button,           // Button to push the input into memory
    input  logic start_button,          // Button to start the ALU operation
    output logic [15:0] result,         // ALU result
    output logic carry_out              // Output for carry out
);

    // Internal signals
    logic [15:0] src, dst;
    logic [3:0] mode_select;
    logic carry_in;
    logic [15:0] result_internal;
    logic carry_out_internal;

    // ALU instantiation
    alu alu_inst (
        .a(src),
        .b(dst),
        .mode_select(mode_select),
        .carry_in(carry_in),
        .result(result_internal),
        .carry_out(carry_out_internal)
    );

    // Edge detection for push_button
    always_ff @(posedge push_button) begin
        case (selector)
            2'b00: src <= switches;                // Load SRC
            2'b01: dst <= switches;                // Load DST
            2'b10: mode_select <= switches[3:0];   // Load mode_select (only lower 4 bits)
            2'b11: carry_in <= switches[0];        // Load carry_in (only lower 1 bit)
        endcase
    end

    // Edge detection for start_button
    always_ff @(posedge start_button) begin
        result <= result_internal;  // Capture the ALU result
        carry_out <= carry_out_internal;  // Capture the ALU carry out
    end


endmodule
