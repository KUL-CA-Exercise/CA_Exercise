addi x16, x0, 80
addi x8, x0, 0
addi x9, x0, 0
addi x10, x0, 1
M1:ld x17, 0(x8)
ld x18, 8(x8)
addi x23, x0, 64
addi x19, x0, 1
addi x20, x0, 0
add x22, x0, x17
LOOP_0: and x21, x18, x19
beq x21, x0, SHIFTING_0
add x20, x20, x22
SHIFTING_0: sll x22, x22,x10
sll x19, x19, x10
addi x23,x23,-1
beq x23, x0, M2
jal LOOP_0
M2: add x9, x9, x20
addi x16, x16, -16
addi x8, x8, 16
beq x16, x0, FINISH
jal M1
FINISH: