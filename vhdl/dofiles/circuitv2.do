vsim -gui work.circuit

add wave -position insertpoint  \
sim:/circuit/rst \
sim:/circuit/clk \
sim:/circuit/pc_out_control \
sim:/circuit/pc_in_control \
sim:/circuit/reg0_out \
sim:/circuit/reg1_out \
sim:/circuit/reg2_out \
sim:/circuit/reg3_out \
sim:/circuit/reg4_out \
sim:/circuit/reg5_out \
sim:/circuit/reg6_out \
sim:/circuit/reg7_out \
sim:/circuit/mdr_out \
sim:/circuit/mar_out \
sim:/circuit/ir_out \
sim:/circuit/temp_out \
sim:/circuit/y_out \
sim:/circuit/z_out \
sim:/circuit/flag_out \
sim:/circuit/ram_out \
sim:/circuit/bus_line \
sim:/circuit/flag_in \
sim:/circuit/dest_out \
sim:/circuit/src_out \
sim:/circuit/dest_in \
sim:/circuit/src_in \
sim:/circuit/reg_out_control \
sim:/circuit/reg_in_control \
sim:/circuit/alu_out \
sim:/circuit/f10 \
sim:/circuit/f9 \
sim:/circuit/f8 \
sim:/circuit/f7 \
sim:/circuit/f6 \
sim:/circuit/f5 \
sim:/circuit/f4 \
sim:/circuit/f3 \
sim:/circuit/f2 \
sim:/circuit/f1 

mem load -i ./rom.mem /circuit/instr_decoder_label/control_store_label/ram
mem load -i ./c10.mem /circuit/ram_label/ram

property wave -radix oct *
add wave -position insertpoint -radix oct sim:/circuit/instr_decoder_label/*

force -freeze sim:/circuit/clk 0 0, 1 {50 ps} -r 100

force -freeze sim:/circuit/rst 1 0
run
force -freeze sim:/circuit/rst 0 0
run