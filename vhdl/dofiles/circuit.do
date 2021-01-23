vsim -gui work.circuit
add wave -position insertpoint  \
sim:/circuit/src_enable \
sim:/circuit/dest_enable \
sim:/circuit/rst \
sim:/circuit/clk \
sim:/circuit/src_sel \
sim:/circuit/dest_sel \
sim:/circuit/inverted_src_enable \
sim:/circuit/inverted_dest_enable \
sim:/circuit/inverted_flag_enable \
sim:/circuit/inverted_clk \
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
sim:/circuit/en \
sim:/circuit/tri_en \
sim:/circuit/alu_out \
sim:/circuit/alu_s

property wave -radix hex *
force -freeze sim:/circuit/clk 1 0, 0 {50 ps} -r 100

force -freeze sim:/circuit/rst 1 0
run
force -freeze sim:/circuit/rst 0 0
force -freeze sim:/circuit/src_enable 1 0

force -freeze sim:/circuit/bus_line 16#FFFF 0
force -freeze sim:/circuit/dest_sel 001 0
force -freeze sim:/circuit/dest_enable 1 0
force -freeze sim:/circuit/src_enable 0 0
run
force -freeze sim:/circuit/bus_line 16#0001 0
force -freeze sim:/circuit/dest_sel 010 0
run

noforce sim:/circuit/bus_line
noforce sim:/circuit/dest_sel
noforce sim:/circuit/dest_enable

force -freeze sim:/circuit/dest_enable 0 0
force -freeze sim:/circuit/src_sel 001 0
force -freeze sim:/circuit/src_enable 1 0
force -freeze sim:/circuit/en(4) 1 0
run

force -freeze sim:/circuit/src_sel 010 0
force -freeze sim:/circuit/alu_s 0010 0
force -freeze sim:/circuit/en(4) 0 0
force -freeze sim:/circuit/en(5) 1 0
force -freeze sim:/circuit/en(6) 1 0

run

force -freeze sim:/circuit/src_sel 010 0
force -freeze sim:/circuit/alu_s 0010 0
force -freeze sim:/circuit/en(6) 0 0

run
