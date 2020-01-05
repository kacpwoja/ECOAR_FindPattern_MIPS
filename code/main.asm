	.data
xxxxx:	.space	2
bmphdr:	.space	54

imgin:	.asciiz	"src.bmp"
imgout:	.asciiz	"out.bmp"

imgInfo:
width:	.word	-1
height:	.word	-1
fbsize:	.word	-1
fbuf:	.space	400000

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
#	la	$a0, pttrn
#	la	$t0, p_size
#	lw	$a1, ($t0)
#	jal	PrintPattern
	
#	Read BMP
	li	$v0, 13
	la	$a0, imgin
	li	$a1, 0
	li	$a2, 0
	syscall
	
	bltz	$v0, finish
	move	$s0, $v0 #file descriptor
	
	# Read BMP Header
	li	$v0, 14
	move	$a0, $s0
	la	$a1, bmphdr
	li	$a2, 54
	syscall
	
	# Get width, height and buffer size	
	lw	$s1, bmphdr+18
	sw	$s1, width
	lw	$s1, bmphdr+22
	sw	$s1, height
	lw	$s1, bmphdr+34
	sw	$s1, fbsize
	
#	li	$v0, 14
#	move	$a0, $s0
#	la	$a1, fbuf
#	lw	$a2, fbsize
#	syscall
	
	li	$v0, 16
	move	$a0, $s0
	syscall
	
	li	$v0, 1
	lw	$a0, bmphdr+34
	syscall
	
#	Find the pattern - TODO
	#jal	FindPattern

#	Print found instances and invert them - TODO
	
#	Save BMP
#	li	$v0, 13
#	la	$a0, imgout
#	li	$a1, 1
#	li	$a2, 0
#	syscall
#	
#	bltz	$v0, finish
#	move	$s0, $v0 #file descriptor
#	
#	li	$v0, 15
#	move	$a0, $s0
#	la	$a1, bmphdr
#	li	$a2, 54
#	syscall
#	
#	li	$v0, 15
#	move	$a0, $s0
#	la	$a1, fbuf
#	lw	$a2, fbsize
#	syscall
#	
#	li	$v0, 16
#	move	$a0, $s0
#	syscall

#	End of program
finish:
	li	$v0, 10
	syscall
