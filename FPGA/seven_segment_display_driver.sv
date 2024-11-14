module seven_segment_display_driver (
   input logic [26:0] binary_in,        // 27-bit binary input for up to 8 BCD digits
   output logic [6:0] segments [7:0]    // 7-segment output for 8 digits
);

   logic [3:0] bcd_digits [7:0]; // 8-digit BCD output (each digit is 4 bits)

   // Temporary register to store shifting result during conversion
   logic [58:0] shift_reg;

   integer i;

   // Binary to BCD conversion using "Double Dabble"
   always_comb begin
      shift_reg = {32'b0, binary_in};  // 9 bits of 0 padding + binary input (36-bit wide)

      for (i = 0; i < 27; i++) begin
         if (shift_reg[58:55] >= 5) shift_reg[58:55] += 3;
         if (shift_reg[54:51] >= 5) shift_reg[54:51] += 3;
         if (shift_reg[50:47] >= 5) shift_reg[50:47] += 3;
         if (shift_reg[46:43] >= 5) shift_reg[46:43] += 3;
         if (shift_reg[42:39] >= 5) shift_reg[42:39] += 3;
         if (shift_reg[38:35] >= 5) shift_reg[38:35] += 3;
         if (shift_reg[34:31] >= 5) shift_reg[34:31] += 3;
         if (shift_reg[30:27] >= 5) shift_reg[30:27] += 3;

         shift_reg = shift_reg << 1;
      end

      // Assign the BCD digits from the shift register
      bcd_digits[7] = shift_reg[58:55];
      bcd_digits[6] = shift_reg[54:51];
      bcd_digits[5] = shift_reg[50:47];
      bcd_digits[4] = shift_reg[46:43];
      bcd_digits[3] = shift_reg[42:39];
      bcd_digits[2] = shift_reg[38:35];
      bcd_digits[1] = shift_reg[34:31];
      bcd_digits[0] = shift_reg[30:27];
   end

   // Segment decoder for seven-segment display (common cathode)
   function automatic logic [6:0] decode_bcd_to_segment(input logic [3:0] bcd);
      case (bcd)
         4'd0: decode_bcd_to_segment = ~7'b0111111; // 0
         4'd1: decode_bcd_to_segment = ~7'b0000110; // 1
         4'd2: decode_bcd_to_segment = ~7'b1011011; // 2
         4'd3: decode_bcd_to_segment = ~7'b1001111; // 3
         4'd4: decode_bcd_to_segment = ~7'b1100110; // 4
         4'd5: decode_bcd_to_segment = ~7'b1101101; // 5
         4'd6: decode_bcd_to_segment = ~7'b1111101; // 6
         4'd7: decode_bcd_to_segment = ~7'b0000111; // 7
         4'd8: decode_bcd_to_segment = ~7'b1111111; // 8
         4'd9: decode_bcd_to_segment = ~7'b1101111; // 9
         default: decode_bcd_to_segment = ~7'b0000000; // Blank for invalid BCD
      endcase
   endfunction

   // Convert each BCD digit to a seven-segment code
   always_comb begin
      for (i = 0; i < 8; i++) begin
         segments[i] = decode_bcd_to_segment(bcd_digits[i]);
      end
   end

endmodule