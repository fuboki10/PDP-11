vsim -gui work.circuit

add wave -position insertpoint  \
sim:/circuit/*

mem load -i ./rom.mem /circuit/instr_decoder_label/control_store_label/ram
mem load -i ./c6.mem /circuit/ram_label/ram

property wave -radix unsigned *
add wave -position insertpoint -radix oct sim:/circuit/instr_decoder_label/*

force -freeze sim:/circuit/system_clk 0 0, 1 {50 ps} -r 100

force -freeze sim:/circuit/rst 1 0
run
force -freeze sim:/circuit/rst 0 0
run