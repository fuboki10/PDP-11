vsim -gui work.partb
add wave -position insertpoint  \
sim:/partb/a \
sim:/partb/b \
sim:/partb/s \
sim:/partb/f

property wave -radix hex *

force -freeze sim:/partb/s 00 0

force -freeze sim:/partb/a 16#F00F 0
force -freeze sim:/partb/b 16#000A 0
run

force -freeze sim:/partb/s 01 0
run

force -freeze sim:/partb/s 10 0
run

force -freeze sim:/partb/s 11 0
run

