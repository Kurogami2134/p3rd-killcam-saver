.psp

.include "../sceio.asm"

; 09DC5A74 input hook

TEX_ADDRESS EQU 0x092DF930 + (480*2 + 64)*271
PLAYTIME EQU 0x9b4da94
SAVE_SLOT EQU 0x09BAEA00

CROSS EQU 0x4000
TRIANGLE EQU 0x1000

.createfile "../bin/main", 0x99D0000


input:
addiu   sp, sp, -0x4
sw      ra, 0x0(sp)

andi    at, v0, TRIANGLE
beq     at, zero, @ret
nop
    jal     create_bmp
    nop

@ret:
lw      ra, 0x0(sp)
addiu   sp, sp, 0x4

; restore original functionality
andi    v0, v0, CROSS
beq     v0, zero, @no_cross
nop
    j       0x09DC5A80
    nop
@no_cross:
    j   0x09DC5AEC
    nop


create_bmp:

addiu   sp, sp, -0x40
sw      ra, 0x00(sp)
sw      a0, 0x04(sp)
sw      a1, 0x08(sp)
sw      a2, 0x0C(sp)
sw      a3, 0x10(sp)
sw      v0, 0x14(sp)
sw      t0, 0x18(sp)
sw      t1, 0x1C(sp)
sw      t2, 0x20(sp)
sw      t3, 0x24(sp)
sw      t4, 0x28(sp)
sw      t5, 0x2C(sp)
sw      s0, 0x30(sp)
sw      s1, 0x34(sp)
sw      s2, 0x38(sp)
sw      s3, 0x3C(sp)


jal     create_path
nop

la      a0, path
li      a1, PSP_O_CREAT | PSP_O_WRONLY
li      a2, 0x1B6
jal     sceIoOpen
li      a3, 0x0

move    s0, v0

jal     set_header
nop

la      s1, TEX_ADDRESS

li      s3, 0x10F
@heightloop:
li      s2, 0x1D
@@loop:
    jal     parse_pixels
    nop
    jal     save_pixels
    nop

    bne     s2, zero, @@loop
    addiu   s2, s2, -0x1
    

addiu   s1, s1, -0x7C0; 0x40

bne     s3, zero, @heightloop
addiu   s3, s3, -0x1


jal     sceIoClose
move    a0, s0

lw      ra, 0x00(sp)
lw      a0, 0x04(sp)
lw      a1, 0x08(sp)
lw      a2, 0x0C(sp)
lw      a3, 0x10(sp)
lw      v0, 0x14(sp)
lw      t0, 0x18(sp)
lw      t1, 0x1C(sp)
lw      t2, 0x20(sp)
lw      t3, 0x24(sp)
lw      t4, 0x28(sp)
lw      t5, 0x2C(sp)
lw      s0, 0x30(sp)
lw      s1, 0x34(sp)
lw      s2, 0x38(sp)
lw      s3, 0x3C(sp)
jr      ra
addiu   sp, sp, 0x40

create_path:
la      a0, path_end
la      a1, PLAYTIME
lw      a1, 0x0(a1)
li      a2, 0x0F0F0F0F
and     a1, a1, a2
li      a2, 0x41414141
addu    a1, a1, a2
sw      a1, 0x0(a0)

la      a1, SAVE_SLOT
lb      a1, 0x0(a1)
addiu   a1, a1, 0x30
sb      a1, 0x5(a0)
jr      ra
nop


set_header:
addiu   sp, sp, -0x40
sw      ra, 0x0(sp)

la      a0, path_end
li      a1, 0x524448  ; "HDR"
sw      a1, 0x0(a0)
la      a0, path

li      a1, PSP_O_RDONLY
li      a2, 0x1B6
jal     sceIoOpen
li      a3, 0x0

move    s1, v0

move    a0, v0
addiu   a1, sp, 0x4
li      a2, 0x36
jal     sceIoRead
li      a3, 0x0

jal     sceIoClose
move    a0, s1

move    a0, s0
addiu   a1, sp, 0x4
li      a2, 0x36
jal     sceIoWrite
li      a3, 0x0


lw      ra, 0x0(sp)
jr      ra
addiu   sp, sp, 0x40

save_pixels:
addiu   sp, sp, -0x34
sw      ra, 0x0(sp)
move    a0, s0
addiu   a1, sp, 0x4
li      a2, 0x30
jal     sceIoWrite
li      a3, 0x0
lw      ra, 0x0(sp)
jr      ra
addiu   sp, sp, 0x34

parse_pixels:
addiu   sp, sp, -0x30;
li      at, 0xF
@@loop:
    lh      a0, 0x0(s1)
    addiu   s1, s1, 0x2

    andi    a1, a0, 0x1F
    sll     a1, a1, 0x3
    sb      a1, 0x2(sp)

    andi    a1, a0, 0x7E0
    srl     a1, a1, 0x3
    sb      a1, 0x1(sp)

    srl     a1, a0, 0x8
    sb      a1, 0x0(sp)

    addiu   sp, sp, 0x3

    bne     at, zero, @@loop
    addiu   at, at, -0x1

jr      ra
nop

path:
    .ascii  "ms0:/P3rdML/KILLCAM/"
path_end:
    .asciiz "XXXX-X.bmp"

.close
