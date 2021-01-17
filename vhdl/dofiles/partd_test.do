vsim -gui work.partd
add wave -position insertpoint  \
sim:/partd/a \
sim:/partd/cin \
sim:/partd/s \
sim:/partd/cout \
sim:/partd/f

property wave -radix hex *

force -freeze sim:/partd/s 00 0

force -freeze sim:/partd/a 16#F00F 0
run

force -freeze sim:/partd/s 01 0
run

force -freeze sim:/partd/s 10 0
force -freeze sim:/partd/cin 0 0
run
force -freeze sim:/partd/cin 1 0
run

force -freeze sim:/partd/s 11 0
run
