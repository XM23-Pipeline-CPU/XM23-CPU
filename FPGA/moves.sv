/*------------------------------------------*\
|  MOV** Instructions - Author: Vlad Chiriac |
|                             & Roee Omessi  |
|  Module contains logic for:                |
|     - Running MOVL, MOVLZ, MOVLS, MOVH     |
\*------------------------------------------*/
module moves (
   input  logic [40:0]           enable,
   input  logic [1:0][7:0][15:0] gprc,
   input  logic [2:0][2:0]       dst_i,
   input  logic [7:0]            b_i,

   output logic [15:0]           result
);
   parameter MOVL  = 35;
   parameter MOVLZ = 36;
   parameter MOVLS = 37;
   parameter MOVH  = 38;

   // Mode Select Logic
   always_comb begin
      if (enable[MOVL] == 1'b1) begin
         result = {gprc[0][dst_i[0]][15:8], b_i};
      end else if (enable[MOVLZ] == 1'b1) begin
         result = {8'b00000000, b_i};
      end else if (enable[MOVLS] == 1'b1) begin
         result = {8'b11111111, b_i};
      end else if (enable[MOVH] == 1'b1) begin
         result = {b_i, gprc[0][dst_i[0]][7:0]};
      end else begin
         result[15:0] = 16'b0;
      end
   end
endmodule
