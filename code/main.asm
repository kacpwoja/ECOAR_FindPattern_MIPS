	.data
xxxxx:	.space	2
bmphdr:	.space	56

imgin:	.asciiz	"src2.bmp"

imgInfo:
width:	.word	0
height:	.word	0
pImg:	.word	0
fbsize:	.word	0

# Buffer for storing result (100 points = 100x2 words = 400)
p_res:	.space	800

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
	move	$s0, $v0 # file descriptor
	
	# Read BMP Header
	li	$v0, 14
	move	$a0, $s0
	la	$a1, bmphdr
	li	$a2, 62
	syscall
	
	# Get width, height and buffer size	
	lw	$s1, bmphdr+18
	sw	$s1, width
	lw	$s2, bmphdr+22
	sw	$s2, height
	#lw	$s3, bmphdr+34 # this doesnt work, returns 0
	#sw	$s3, fbsize
	# Calculate size manually
	addiu	$s1, $s1, 31
	srl	$s1, $s1, 5
	sll	$s1, $s1, 2 # bytes in line
	mul	$s3, $s1, $s2
	sw	$s3, fbsize
	
	# Allocate heap
	li	$v0, 9
	move	$a0, $s3
	syscall
	move	$s4, $v0
	sw	$s4, pImg
	
	# Load image into buffer
	li	$v0, 14
	move	$a0, $s0
	move	$a1, $s4
	move	$a2, $s3
	syscall
	
	# Close file
	li	$v0, 16
	move	$a0, $s0
	syscall
	
	# Height processing
	blez	$s2, height_negative
	subiu	$s5, $s2, 1
	mul	$s5, $s6, $s5 # total bytes
	add	$s4, $s4, $s5 # move pointer (it's backwards)
	b	height_positive	
height_negative:
	# Two's complement integer negation
	not	$s2, $s2
	addiu	$s2, $s2, 1
height_positive:
	
#	Find the pattern
	la	$a0, imgInfo
	lw	$a1, p_size
	la	$a2, pttrn
	la	$a3, p_res
	jal	FindPattern
	# store results
	move	$s0, $v0
	move	$s1, $v1

#	Print found instances and invert them
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
	#jal	PrintPoint
	addiu	$t0, $t0, 8
	addiu	$t1, $t1, -1
	bnez	$t1, PointLoop
	
SkipPoints:

#	End of program
finish:
	li	$v0, 10
	syscall
