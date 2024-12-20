transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/p_ram.v}
vlog -vlog01compat -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/d_ram.v}
vlog -vlog01compat -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/reg_view.v}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/branch.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/regnum_to_values_to_alu.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/decode_stage.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/pipeline_registers.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/pipeline_controller.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_XOR.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_SUB.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_OR.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_DADD.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_BIT.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_BIS.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_BIC.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_AND.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_ADD.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/XM23.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_ADDC.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_SUBC.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/update_psw.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/program_counter.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/moves.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_MOV.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_SRA.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_RRC.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_COMP.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_SWPB.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/alu_SXT.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/memory_access_d_ram.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/go_to_LR.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/system_view.sv}
vlog -sv -work work +incdir+C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA {C:/Users/romes/OneDrive/Desktop/XM23-CPU/FPGA/seven_segment_display_driver.sv}

