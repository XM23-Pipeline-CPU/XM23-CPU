// alu_DADD.sv
module alu_DADD (
    input logic [15:0] a,         // 16-bit BCD input A
    input logic [15:0] b,         // 16-bit BCD input B
    input logic carry_in,         // Carry In
    output logic [15:0] result   // 16-bit BCD result
);

    // Internal signals for digit sums and carries
    logic [3:0] digit_sum[3:0];   // Sum of each BCD digit
    logic [3:0] digit_a[3:0];     // Each BCD digit of a
    logic [3:0] digit_b[3:0];     // Each BCD digit of b
    logic [3:0] digit_result[3:0]; // Corrected BCD digit result
    logic bcd_carry;              // Carry for the entire operation
    logic temp_carry;             // Temporary carry for digit-wise addition

    // Splitting 16-bit inputs into 4-bit BCD digits
    assign digit_a[0] = a[3:0];
    assign digit_a[1] = a[7:4];
    assign digit_a[2] = a[11:8];
    assign digit_a[3] = a[15:12];

    assign digit_b[0] = b[3:0];
    assign digit_b[1] = b[7:4];
    assign digit_b[2] = b[11:8];
    assign digit_b[3] = b[15:12];

    // Perform digit-wise addition and correction
    always_comb begin
        bcd_carry = carry_in; // Initialize with carry_in
        for (int i = 0; i < 4; i++) begin
            // Calculate sum of the current digit plus carry
            digit_sum[i] = digit_a[i] + digit_b[i] + bcd_carry;
            if (digit_sum[i] > 4'd9) begin
                digit_result[i] = digit_sum[i] + 4'd6; // BCD correction factor
                temp_carry = 1'b1;
            end else begin
                digit_result[i] = digit_sum[i];
                temp_carry = 1'b0;
            end
            bcd_carry = temp_carry; // Update carry for the next digit
        end
    end

    // Combine the corrected digits back into the 16-bit result
    assign result = {digit_result[3], digit_result[2], digit_result[1], digit_result[0]};
    // Generate carry out for the overall result
    assign carry_out = bcd_carry;

endmodule
