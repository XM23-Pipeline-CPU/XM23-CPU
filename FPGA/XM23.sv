/*-------------------------------------------------*\
|  XM23 - Top Level Module - Author: Vlad Chiriac   |
|                                  & Roee Omessi    |
|  Module contains logic for:                       |
|     - Connecting all submodules                   |
\*-------------------------------------------------*/

module XM23 (
   input  wire       clk_in, // Input clk (50 MHz from the FPGA)
   input  wire       init,   // Init mode signal (the FPGA should be in this mode when idle to setup for running the program)
   input  wire [1:0] speed,  // Input from switches that determine clock speed
   output reg        led,    // LED output (blinking to confirm clk)
   
   output wire [6:0] seven_seg_display [7:0] // External display wire
);

   // Wire for forcing p_ram to read FFFE (7FFF in words) address for init
   parameter FORCED    = 15'b111111111111111;
   parameter UNFORCED  = 15'b000000000000000;
   reg [14:0] PC_force = FORCED;

   // Clock division logic -----------------------------------------------------------------------

   // This is the global clk for other modules
   // (except memory which will take 50MHz)
   reg clk = 0;
                           

   // Initialize counter for the divider
   reg [31:0] counter = 1;
   
   // Divides 50 MHz clk to desired speed
   // (DIVIDER = number of edges until flip)
   logic [31:0] DIVIDER = 3;
   always_comb begin
      case (speed)                     // runs at
         2'b11: DIVIDER = 3;           // 8.333 MHz (fastest it can go)
         2'b10: DIVIDER = 250_000;     // 100 Hz
         2'b01: DIVIDER = 2_500_000;   // 10 Hz
         2'b00: DIVIDER = 25_000_000;  // 1 Hz
         default: DIVIDER = 3;
      endcase
   end
	
	
   always @(posedge clk_in) begin
     if (init) begin
         PC_force <= FORCED;
         counter <= 1;
         clk <= 0;
         led <= 0;
     end else if (counter == (DIVIDER - 1)) begin
         PC_force <= UNFORCED;
         clk <= ~clk;      // Toggle the clk output
         led <= ~led;      // Toggle the LED (LED will blink)
         counter <= 0;     // Reset the counter
     end else begin
         counter <= counter + 1;
     end
   end
   
   // program finish instruction = BRA to itself
   parameter PROGRAM_FINISH = 16'b0011111111111111;
   logic [63:0] global_clock_count = 64'b0;
   
   // Global clock counter gets incremented always unless
   // instruction is the program_finish instruction (BRA to itself)
   // or unless 'init' resets it back to 0
   wire [15:0] inst_wire;
	always @(posedge clk or posedge init) begin
      if(init) begin
         global_clock_count <= 0;
      end else if (inst_wire != PROGRAM_FINISH) begin
         global_clock_count <= global_clock_count + 1;
      end
   end

   // --------------------------------------------------------------------------------------------

   // Declare wires for connections between modules ----------------------------------------------

   // Reg/Wires for fetching from memory
   wire [15:0] PC_wire;
   wire [15:0] PC_next_wire;
   wire [15:0] LBPC_wire;
   wire [15:0] LBPC_LR_wire;
   

   // Wires for data memory access
   wire [14:0] dram_address_wire;
   wire        dram_write_enable_wire;
   wire [15:0] dram_data_in_wire;
   wire [15:0] dram_data_out_wire;

   // Wire for failed branch prediction
   wire        branch_predict_fail_wire;
   wire [15:0] LBPSW_wire;

   // wire for LR (link register)
   wire [15:0] LR_wire;

   // Wires from decode_stage to pipeline_registers
   wire         WB_wire;
   wire         SLP_wire;
   wire         N_wire;
   wire         Z_wire;
   wire         C_wire;
   wire         V_wire;
   wire         PRPO_wire;
   wire         DEC_wire;
   wire         INC_wire;
   wire         RC_wire;
   wire [2:0]   D_wire;
   wire [2:0]   S_wire;
   wire [2:0]   PR_wire;
   wire [2:0]   F_wire;
   wire [2:0]   T_wire;
   wire [3:0]   SA_wire;
   wire [12:0]  OFF_wire;
   wire [7:0]   B_wire;
   wire [40:0]  enable_wire;

   // Wires from decode_stage to pipeline_controller
   wire [7:0]   async_set_wire;
   wire [7:0]   async_dep_wire;

   // Wires from pipeline_controller to pipeline_registers
   wire [7:0]   stall_wire;

   // Wire to clear the pipeline registers for links
   wire         clear_pipeline_LR_wire;

   // Wires from alu_inst
   wire [15:0]  alu_result_wire;
   wire [15:0]  psw_out_wire;
   wire [15:0]  psw_mask_wire;
   wire         enable_psw_msk_wire;

   // wires from moves
   wire [15:0]  moves_result_wire;

   // Wires from pipeline_registers to regnum_to_values_to_alu
   wire [1:0][7:0][15:0]  gprc_o_wire;
   wire [2:0]             RC_o_wire;
   wire [2:0][2:0]        S_o_wire;
   wire [2:0][2:0]        D_o_wire;

   // Wires from regnum_to_values_to_alu to alu_inst
   wire [15:0]  dst_val_wire;
   wire [15:0]  src_val_wire;

   // Wires from pipeline_registers
   wire [2:0][40:0]   	enable_o_wire;
   wire [15:0]   		   PSW_o_wire;

   // Wires from pipeline registers to update psw
   wire [2:0] SLP_o_wire;
   wire [2:0] N_o_wire;
   wire [2:0] Z_o_wire;
   wire [2:0] C_o_wire;
   wire [2:0] V_o_wire;

   // Wire from pipeline registers to get BBBBBBBB bytes for MOVL/MOVLZ/MOVLS/MOVH instructions
   wire [2:0][7:0] B_o_wire;

   // Wires for pre/post increment/decrement and relative load/store
   wire PRPO_o_wire;
   wire DEC_o_wire;
   wire INC_o_wire;
   wire [2:0][12:0] OFF_o_wire;

   // Wire to disable decode for init
   wire decode_disable_wire;
   
   // seven segment display wire
   wire [6:0] seven_seg_display_wire [7:0];

   // --------------------------------------------------------------------------------------------

   // Connections between modules ----------------------------------------------------------------

   // Program_counter
   program_counter program_counter_inst (
      // INPUT FROM TOP LEVEL
      .clk(clk),
      .init_clk(clk_in),
      .init(init),
      .PC_init(inst_wire),

      // INPUT FROM CONTROLLER
      .PC_next(PC_next_wire),
      .LBPC(LBPC_wire),
      .link_back(clear_pipeline_LR_wire),
      .stall_in(stall_wire),

      // INPUT FROM BRANCH INSTRUCTIONS
      .branch_fail(branch_predict_fail_wire),
      .LR(LR_wire),

      // OUTPUT PC
      .true_PC(PC_wire),

      // OUTPUT TO DECODE TO PAUSE AT INIT
      .decode_disable(decode_disable_wire)
   );

   // fetch from program ram
   p_ram pram (
      // INPUT FROM TOP LEVEL
      .clock(clk_in),
      .address(PC_wire[15:1] | PC_force),
      .data(16'b0),	// Never writing
      .wren(1'b0),	// ...

      // OUTPUT TO DECODE
      .q(inst_wire)
   );

   // control for the data memory
   memory_access_d_ram memory_access_d_ram_inst (
      // INPUTS FROM PIPELINE REGISTERS
      .enable(enable_o_wire),
      .gprc(gprc_o_wire),
      .src_i(S_o_wire),
      .dst_i(D_o_wire),
      .pre(PRPO_o_wire),
      .inc(INC_o_wire),
      .dec(DEC_o_wire),
      .off(OFF_o_wire),

      // OUTPUT TO DRAM

      .write_enable(dram_write_enable_wire),
      .output_address(dram_address_wire),
      .output_data(dram_data_in_wire)
   );

   // data memory instantiation
   d_ram dram (
      // INPUT FROM TOP LEVEL
      .clock(clk_in),
      .address(dram_address_wire),
      .data(dram_data_in_wire),
      .wren(dram_write_enable_wire),

      // OUTPUT TO MEMORY ACCESS
      .q(dram_data_out_wire)
   );

   // instructions are fed here from fetch
   decode_stage decode_stage_inst (
      // INPUT FROM FETCH
      .inst(inst_wire),
      .decode_disable(decode_disable_wire),

      // OUTPUTS
      .WB(WB_wire),
      .SLP(SLP_wire),
      .N(N_wire),
      .Z(Z_wire),
      .C(C_wire),
      .V(V_wire),
      .PRPO(PRPO_wire),
      .DEC(DEC_wire),
      .INC(INC_wire),
      .RC(RC_wire),
      .D(D_wire),
      .S(S_wire),
      .PR(PR_wire),
      .F(F_wire),
      .T(T_wire),
      .SA(SA_wire),
      .OFF(OFF_wire),
      .B(B_wire),
      .enable(enable_wire),
      .async_set(async_set_wire),
      .async_dep(async_dep_wire)
   );

   // pipeline registers connections
   pipeline_registers pipeline_registers_inst (
      // INPUTS FROM TOPLEVEL
      .clk(clk),
      .reset_gprc(init),

      // INPUTS FROM DECODE
      .WB(WB_wire),
      .SLP(SLP_wire),
      .N(N_wire),
      .Z(Z_wire),
      .C(C_wire),
      .V(V_wire),
      .PRPO(PRPO_wire),
      .DEC(DEC_wire),
      .INC(INC_wire),
      .RC(RC_wire),
      .D(D_wire),
      .S(S_wire),
      .PR(PR_wire),
      .F(F_wire),
      .T(T_wire),
      .SA(SA_wire),
      .OFF(OFF_wire),
      .B(B_wire),
      .enable(enable_wire),

      // INPUT FROM BRANCH
      .branch_fail(branch_predict_fail_wire),

      // INPUT FROM MEMORY ACCESS
      .mem_access_result(dram_data_out_wire),

      // INPUTS FROM ALU
      .alu_result(alu_result_wire),

      // INPUTS FROM MOVES
      .moves_result(moves_result_wire),

      // INPUTS FROM UPDATING PSW
      .PSW(psw_out_wire),
      .PSW_mask(psw_mask_wire),

      // INPUT FROM PIPELINE CONTROLLER
      .stall_in(stall_wire),
      .LBPSW(LBPSW_wire),

      // INPUT FROM LR control and branch fail
      .clear_in(clear_pipeline_LR_wire || branch_predict_fail_wire),

      // OUTPUTS
      .gprc_o(gprc_o_wire),
      .RC_o(RC_o_wire),
      .S_o(S_o_wire),
      .D_o(D_o_wire),
      .enable_o(enable_o_wire),
      .PSW_o(PSW_o_wire),
      .SLP_o(SLP_o_wire),
      .N_o(N_o_wire),
      .Z_o(Z_o_wire),
      .C_o(C_o_wire),
      .V_o(V_o_wire),
      .B_o(B_o_wire),
      .PRPO_o(PRPO_o_wire),
      .DEC_o(DEC_o_wire),
      .INC_o(INC_o_wire),
      .OFF_o(OFF_o_wire)
   );

   // takes dependency decisions from decoder
   pipeline_controller pipeline_controller_inst (
      // INPUT FROM TOPLEVEL
      .clk(clk),
      .PC_in(PC_wire),
		.PSW_in(PSW_o_wire),

      // INPUT FROM FETCH
      .three_msb(inst_wire[15:13]),
      .thirteen_lsb(inst_wire[12:0]),

      // INPUTS FROM DECODER
      .async_set_from_decode(async_set_wire),
      .async_dep_from_decode(async_dep_wire),

      // OUTPUT
      .stall(stall_wire),
      .PC_next(PC_next_wire),
      .LBPC(LBPC_wire),
      .LBPC_LR(LBPC_LR_wire),
      .LBPSW(LBPSW_wire)
   );

   // module to prepare data for alu from pipeline registers
   regnum_to_values_to_alu regnum_to_values_to_alu_inst (
      // INPUTS FROM PIPELINE REGISTERS
      .gprc(gprc_o_wire),
      .temp_rc(RC_o_wire),
      .src_i(S_o_wire),
      .dst_i(D_o_wire),

      // OUTPUTS
      .dst_val(dst_val_wire),
      .src_val(src_val_wire)
   );

   // alu
   alu alu_inst(
      // INPUTS FROM REGNUM
      .a(dst_val_wire),
      .b(src_val_wire),

      // INPUTS FROM PIPELINE REGISTERS
      .enable(enable_o_wire[0]),
      .carry_in(PSW_o_wire[0]),

      // OUTPUTS
      .result(alu_result_wire),
      .enable_psw_msk(enable_psw_msk_wire)
   );

   // Branching instructions (checking if failed conditions)
   branch branch_inst(
      // INPUT FROM TOPLEVEL
      .clk(clk),

      // INPUTS FROM PIPELINE REGISTERS
      .enable(enable_o_wire[0]),
      .PSW_in(PSW_o_wire),

      // INPUTS FROM CONTROLLER
      .LBPC_in(LBPC_LR_wire),

      // OUTPUT TO PC
      .branch_fail_o(branch_predict_fail_wire),

      // OUTPUT LR
      .LR_o(LR_wire)
   );

   // Module to set PC <- LR when LD mem[FFFF] (invalid instruction indicating link back)
   go_to_LR go_to_LR_inst(
      // INPUTS FROM PIPELINE REGISTERS
      .enable(enable_o_wire[0]),
      .src_i(S_o_wire),
      .gprc(gprc_o_wire),

      // OUTPUT TO PC
      .link_back_o(clear_pipeline_LR_wire)
   );

   // module to do the MOVL/MOVLZ/MOVLS/MOVH instructions
   moves moves_inst(
      // INPUT FROM PIPELINE REGISTERS
      .enable(enable_o_wire[0]),
      .gprc(gprc_o_wire),
      .dst_i(D_o_wire),
      .b_i(B_o_wire),

      // OUTPUT TO PIPELINE REGISTERS
      .result(moves_result_wire)
   );

   // module to update the psw after alu
   update_psw update_psw_inst(
      // INPUTS FROM REGNUM
      .a(dst_val_wire),
      .b(src_val_wire),

      // INPUTS FROM DECODE
      .enable(enable_o_wire[0]),


      // INPUTS FROM ALU
      .result(alu_result_wire),
      .enable_psw_msk(enable_psw_msk_wire),

      // INPUTS FROM PIPELINE REGISTERS
      .SLP_i(SLP_o_wire[0]),
      .N_i(N_o_wire[0]),
      .Z_i(Z_o_wire[0]),
      .C_i(C_o_wire[0]),
      .V_i(V_o_wire[0]),

      // OUTPUTS
      .psw_out(psw_out_wire),
      .psw_msk(psw_mask_wire)
   );

   // Used to just view the contents of registers from 1-Port RAM (non-functional)
   system_view system_view_inst(
      .clk(clk),
      .gprc(gprc_o_wire),
      .psw(PSW_o_wire),
      .pc(PC_wire),
      .inst(inst_wire)
   );
   
   // Driver to display clock count
   seven_segment_display_driver seven_segment_display_driver_inst(
      .binary_in(global_clock_count[26:0]),
      .segments(seven_seg_display_wire)
   );
   
   assign seven_seg_display = seven_seg_display_wire;

   // --------------------------------------------------------------------------------------------

endmodule
