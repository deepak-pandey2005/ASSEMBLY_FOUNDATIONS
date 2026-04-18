# as -gstabs -o add.o add.s
# ld -o add add.o 



# gdb codes
gdb -q add

break *_start

next 

info registers