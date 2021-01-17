vsim -gui work.alu
add wave -position insertpoint  \
sim:/alu/a \
sim:/alu/b \
sim:/alu/cin \
sim:/alu/s \
sim:/alu/outB \
sim:/alu/coutC \
sim:/alu/outC \
sim:/alu/coutD \
sim:/alu/outD \
sim:/alu/cout \
sim:/alu/f

property wave -radix hex *

#part b
force -freeze sim:/alu/s 0100 0

force -freeze sim:/alu/a 16#F00F 0
force -freeze sim:/alu/b 16#000A 0
run

force -freeze sim:/alu/s 0101 0
run

force -freeze sim:/alu/s 0110 0
run

force -freeze sim:/alu/s 0111 0
run

force -freeze sim:/alu/s 1000 0
run
# part c
force -freeze sim:/alu/s 1001 0
run

force -freeze sim:/alu/s 1010 0
force -freeze sim:/alu/cin 0 0
run
force -freeze sim:/alu/cin 1 0
run

force -freeze sim:/alu/s 1011 0
run

# part b
force -freeze sim:/alu/s 1100 0
run

force -freeze sim:/alu/s 1101 0
run

force -freeze sim:/alu/s 1110 0
force -freeze sim:/alu/cin 0 0
run
force -freeze sim:/alu/cin 1 0
run

force -freeze sim:/alu/s 1111 0
run

#part b rotate right
force -freeze sim:/alu/a 16#F00A 0
force -freeze sim:/alu/s 1001 0
run
