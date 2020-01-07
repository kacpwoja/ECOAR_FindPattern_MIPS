	.data
nline:	.asciiz	"\n"
	.text
	.globl	PrintPoint
# void PrintPoint(Point* pnt)
# Prints Point to console
# $a0 -> Point* pnt
PrintPoint:
	move	$t0, $a0
	
	li	$v0, 11
	li	$a0, '('
	syscall
	
	li	$v0, 1
	lw	$a0, ($t0)
	syscall
	
	li	$v0, 11
	li	$a0, ','
	syscall
	li	$v0, 11
	li	$a0, ' '
	syscall
	
	li	$v0, 1
	lw	$a0, 4($t0)
	syscall
	
	li	$v0, 11
	li	$a0, ')'
	syscall
	
	li	$v0, 4
	la	$a0, nline
	syscall
	
	jr	$ra