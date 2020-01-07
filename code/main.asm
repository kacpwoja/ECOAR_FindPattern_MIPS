	.data
xxxxx:	.space	2
bmphdr:	.space	62

imgin:	.asciiz	"src2.bmp"
imgout:	.asciiz	"out.bmp"

imgInfo:
width:	.word	-1
height:	.word	-1
fbsize:	.word	-1
fbuf:	.space	400000

# Buffer for storing result (100 points = 100x2 words = 400
p_res:	.space	400

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
	#lw	$s1, bmphdr+34 # this doesnt work, returns 0
	#sw	$s1, fbsize
	# calculate bytes per line
	lw	$t0, width
	addiu	$t0, $t0, 7
	divu	$t0, $t0, 8
	addiu	$t0, $t0, 3
	divu	$t0, $t0, 4
	mul	$t0, $t0, 4
	# calculate total bytes and store them
	lw	$t1, height
	mul	$t0, $t0, $t1
	sw	$t0, fbsize
	
	li	$v0, 14
	move	$a0, $s0
	la	$a1, fbuf
	lw	$a2, fbsize
	syscall
	
	li	$v0, 16
	move	$a0, $s0
	syscall
	
#	Find the pattern - TODO
	la	$a0, imgInfo
	lw	$a1, p_size
	la	$a2, pttrn
	la	$a3, p_res
	jal	FindPattern
	# store results
	move	$s0, $v0
	move	$s1, $v1

#	Print found instances and invert them - TODO
	# no. of found instances
	li	$v0, 1
	move	$a0, $s1
	syscall
	li	$v0, 0xB
	la	$a0, 0xA
	syscall
	beqz	$s1, SkipPoints
	
	# print coords
	move	$t0, $s0
	move	$t1, $s1
PointLoop:
	move	$a0, $t0
	jal	PrintPoint
	addiu	$t0, $t0, 8
	addiu	$t1, $t1, -1
	bnez	$t1, PointLoop
	
SkipPoints:
	
#	Save BMP
#	li	$v0, 13
#	la	$a0, imgout
#	li	$a1, 1
#	li	$a2, 0
#	syscall
	
#	bltz	$v0, finish
#	move	$s0, $v0 #file descriptor
	
#	li	$v0, 15
#	move	$a0, $s0
#	la	$a1, bmphdr
#	li	$a2, 54
#	syscall
	
#	li	$v0, 15
#	move	$a0, $s0
#	la	$a1, fbuf
#	lw	$a2, fbsize
#	syscall
	
#	li	$v0, 16
#	move	$a0, $s0
#	syscall

#	End of program
finish:
	li	$v0, 10
	syscall
