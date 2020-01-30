	.data
xxxxx:	.space	2
bmphdr:	.space	62

imgin:	.asciiz	"src2.bmp"

imgInfo:
width:	.word	0
height:	.word	0
pImg:	.word	0
fbsize:	.word	0

# Buffer for storing result (100 points = 100x2 words = 800)
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
	#jal	PrintPattern

	sw	$s1, width
	sw	$s2, height
	sw	$s3, fbsize
	sw	$s4, pImg
	
	# Close file
	li	$v0, 16
	move	$a0, $s0
	syscall
	
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
