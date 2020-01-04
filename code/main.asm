	.data
fname:	.asciiz	"src.bmp"

# Pattern.
# Size is 0xHHHHVVVV, where H is horizontal size, V is vertical size
# small g
p_size:	.word	0x00070008
pttrn:	.word	0x40, 0x3d, 0x3d, 0x3d, 0x41, 0x7d, 0x7d, 0x43

	.text
	.globl	main
main:
	# Init etc - TODO
	
	# Print pattern - TODO implemetnation
	la	$a0, pttrn
	la	$t0, p_size
	lw	$a1, ($t0)
	jal	PrintPattern
	
	# Read BMP - TODO
	
	# Find the pattern - TODO
	jal	FindPattern

	# Print found instances and invert them - TODO
	
	# Save BMP - TODO

	# End of program
	li	$v0, 10
	syscall