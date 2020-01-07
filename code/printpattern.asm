	.data
	.text
	.globl	PrintPattern
# void PrintPattern(int* pattern, int p_size)
# Prints Pattern to console
# $a0 -> int* pattern
# $a1 -> int p_size
PrintPattern:
#	for (i=0; i < 8; ++i)
#         {
#                 for (mask=0x40; mask != 0; mask >>= 1)
#                         printf("%c", (pattern[i] & mask) ? ' ' : '*');
#                 printf("\n");
#         }

#	$t0 -> i
#	$t1 -> mask
#	$t2 -> pattern[i]
#	$t3 -> pattern[i] & mask
#	$s0 -> saved $a0
#	$s1 -> i limit (vertical size)
#	$s2 -> starting mask (1<<(h-1)), where h is horizontal size
	# TODO: save saved registers
#	Prologue:
	addiu	$sp, $sp, -24
	sw	$s0, 16($sp)
	sw	$s1, 8($sp)
	sw	$s2, ($sp)
#	Locals:
	move	$s0, $a0
	andi	$s1, $a1, 0xFFFF
	srl	$t0, $a1, 16
	li	$s2, 1
PrintPfor_shift:
	sll	$s2, $s2, 1
	addiu	$t0, $t0, -1
	bnez	$t0, PrintPfor_shift
	srl	$s2, $s2, 1
	
	
#	Body
	li	$t0, 0
PrintPfor_i:
	move	$t1, $s2
PrintPfor_mask:
	lw	$t2, ($s0)
	and	$t3, $t2, $t1
	beqz	$t3, PrintPout_ast
	li	$a0, ' '
PrintPout_back:
	li	$v0, 11
	syscall
#	iterate for mask
	srl	$t1, $t1, 1
	bnez	$t1, PrintPfor_mask
#	iterate for i
	la	$a0, 0xA
	li	$v0, 0xB
	syscall
	addiu	$s0, $s0, 4
	addiu	$t0, $t0, 1
	bltu	$t0, $s1, PrintPfor_i
	
#	Epilogue
	lw	$s2, ($sp)
	lw	$s1, 8($sp)
	lw	$s0, 16($sp)
	addiu	$sp, $sp, 24
#	return
	jr	$ra
	
PrintPout_ast:
	li	$a0, '*'
	b	PrintPout_back
	
