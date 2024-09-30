onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /XM23/clk_in
add wave -noupdate /XM23/clk
add wave -noupdate /XM23/pipeline/clk
add wave -noupdate /XM23/controller/stall
add wave -noupdate -divider -height 34 {New Divider}
add wave -noupdate /XM23/regnum_inst/gprc
add wave -noupdate /XM23/regnum_inst/temp_rc
add wave -noupdate /XM23/RC_o_wire
add wave -noupdate /XM23/regnum_inst/src_i
add wave -noupdate /XM23/S_o_wire
add wave -noupdate /XM23/regnum_inst/dst_i
add wave -noupdate /XM23/D_o_wire
add wave -noupdate /XM23/regnum_inst/src_val
add wave -noupdate /XM23/regnum_inst/dst_val
add wave -noupdate -divider -height 34 {New Divider}
add wave -noupdate /XM23/alu_inst/a
add wave -noupdate /XM23/alu_inst/b
add wave -noupdate /XM23/alu_inst/enable
add wave -noupdate /XM23/alu_inst/carry_in
add wave -noupdate -divider -height 34 {New Divider}
add wave -noupdate /XM23/alu_inst/result
add wave -noupdate /XM23/alu_inst/psw_out
add wave -noupdate /XM23/alu_inst/psw_msk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {576 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 192
configure wave -valuecolwidth 267
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {805 ps}
