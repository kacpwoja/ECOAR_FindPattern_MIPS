	.data
imgin:	.asciiz	"src.bmp"
imgout:	.asciiz	"out.bmp"

imgInfo:
w:	.word	-1
h:	.word	-1
fsize:	.word	-1
pImg:	.word	-1
fbuf:	.space	400000
fbsize:	.word	400000

# Pattern.
# Size is 0xHHHHVVVV, where H is horizontal size, V is vertical size
# small g
p_size:	.word	0x00070008
pttrn:	.word	0x40, 0x3d, 0x3d, 0x3d, 0x41, 0x7d, 0x7d, 0x43
# other letter
#
#

	.text
	.globl	main
main:
#	Init etc - TODO
	
#	Print pattern
	la	$a0, pttrn
	la	$t0, p_size
	lw	$a1, ($t0)
	jal	PrintPattern
	
#	Read BMP - TODO: BMP HEADER
	li	$v0, 13
	la	$a0, imgin
	li	$a1, 0
	li	$a2, 0
	syscall
	
	bltz	$v0, finish
	move	$s0, $v0 #file descriptor
	sw	$s0, pImg
	
	li	$v0, 14
	move	$a0, $s0
	la	$a1, fbuf
	lw	$a2, fbsize
	syscall
	
	li	$v0, 16
	move	$a0, $s0
	syscall
	
#	Find the pattern - TODO
	jal	FindPattern

#	Print found instances and invert them - TODO
	
#	Save BMP - TODO: BMP HEADER
	li	$v0, 13
	la	$a0, imgout
	li	$a1, 1
	li	$a2, 0
	syscall
	
	bltz	$v0, finish
	move	$s0, $v0 #file descriptor
	sw	$s0, pImg
	
	li	$v0, 15
	move	$a0, $s0
	la	$a1, fbuf
	lw	$a2, fbsize
	syscall
	
	li	$v0, 16
	move	$a0, $s0
	syscall

#	End of program
finish:
	li	$v0, 10
	syscall