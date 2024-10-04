module XM23 (
    input wire clk_in,    // Input clk (50 MHz from the FPGA)
    input wire reset,       // Reset signal
    output reg led          // LED output (blinking to confirm clk)
);
	reg clk = 0;       // This is the global clk for other modules
	reg [31:0] counter = 0;
	parameter DIVIDER = 1;  // Divides 50 MHz clk to desired speed

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

	// Declare wires for connections between modules

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

	// Wires from alu_inst to pipeline_registers
	wire [15:0]  alu_result_wire;    
	wire [15:0]  psw_out_wire;       
	wire [15:0]  psw_mask_wire;
	wire         enable_psw_msk_wire;

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
	wire [15:0]   		PSW_o_wire;         

	// Internal signals
	logic [15:0] inst;

	always_comb begin
	  inst <= 16'b0100_0000_0000_1000; // add, (registers), (word size), from reg 000 + 001, save in reg 000
	end

	// instructions are fed here from fetch
	decode_stage decode(
		// INPUT FROM FETCH
		.inst(inst),
		
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
	pipeline_registers pipeline (
		// INPUTS FROM TOPLEVEL
		.clk(clk),
		
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
		
		// INPUTS FROM ALU
		.exec_result(alu_result_wire),
		
		// INPUTS FROM UPDATING PSW
		.PSW(psw_out_wire),
		.PSW_mask(psw_mask_wire),
		
		// INPUT FROM PIPELINE CONTROLLER
		.stall_in(stall_wire),

		// OUTPUTS
		.gprc_o(gprc_o_wire),
		.RC_o(RC_o_wire),
		.S_o(S_o_wire),
		.D_o(D_o_wire),
		.enable_o(enable_o_wire),
		.PSW_o(PSW_o_wire)
	);
	
	// takes dependency decisions from decoder
	pipeline_controller controller(
		//INPUT FROM TOPLEVEL
		.clk(clk),
		
		// INPUTS FROM DECODER
		.async_set_from_decode(async_set_wire),
		.async_dep_from_decode(async_dep_wire),
		
		// OUTPUT
		.stall(stall_wire)
	);
	
	// module to prepare data for alu from pipeline registers
	regnum_to_values_to_alu regnum_inst(
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
	
	// module to update the psw after alu
	update_psw update_psw_inst(
		// INPUTS FROM REGNUM
		.a(dst_val_wire),
		.b(src_val_wire),
		
		// INPUTS FROM ALU
		.result(alu_result_wire),
		.enable_psw_msk(enable_psw_msk_wire),
		
		// OUTPUTS
		.psw_out(psw_out_wire),
		.psw_msk(psw_mask_wire)
	);
		
		

endmodule