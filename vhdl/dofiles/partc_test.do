vsim -gui work.partc
add wave -position insertpoint  \
sim:/partc/a \
sim:/partc/cin \
sim:/partc/s \
sim:/partc/cout \
sim:/partc/f

property wave -radix hex *

force -freeze sim:/partc/s 00 0

force -freeze sim:/partc/a 16#F00F 0
run

force -freeze sim:/partc/s 01 0
run
force -freeze sim:/partc/a 16#F00A 0
run

force -freeze sim:/partc/a 16#F00F 0
force -freeze sim:/partc/s 10 0
force -freeze sim:/partc/cin 0 0
run
force -freeze sim:/partc/cin 1 0
run

force -freeze sim:/partc/s 11 0
run
