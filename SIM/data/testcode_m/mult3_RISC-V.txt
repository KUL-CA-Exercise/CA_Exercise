ld x8, 0(x0)
ld x9, 8(x0)
ld x10, 16(x0)
ld x11, 24(x0)
ld x12, 32(x0)
ld x13, 40(x0)
ld x14, 48(x0)
ld x15, 56(x0)
ld x16, 64(x0)
ld x17, 72(x0)
mul x18, x8,x9
mul x19, x10, x11
mul x20, x12, x13
mul x21, x14, x15
mul x22, x16, x17
addi x23, x0, 0
add x23, x23, x18
add x23, x23, x19
add x23, x23, x20
add x23, x23, x21
add x23, x23, x22
