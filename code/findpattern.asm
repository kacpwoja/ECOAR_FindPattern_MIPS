	.data
	
	.text
	.globl FindPattern
# Point* FindPattern(imgInfo* pImg, int pSize, int* ptrn, Point* pResult)
# $v0	-> returned buffer of found coordinates (Point*)
# $v1	-> no. of found points
# $a0	-> imgInfo* pImg - image information
# $a1	-> int pSize - size of int* ptrn
# $a2	-> int* ptrn - the pattern to search for
# $a3	-> Point* pResult - pointer to buffer to return to
#
#	s0 -> last saved point
#	s1 -> pattern horizontal size
#	s2 -> pattern vertical size
#	s3 -> img width
#	s4 -> img height
#	s5 -> bytes in line
#	t0 -> image pointer
#
#	v0				($t3)
FindPattern:
#	Prologue
	addiu	$sp, $sp, -56
	sw	$s0, 0($sp)
	sw	$s1, 8($sp)
	sw	$s2, 16($sp)
	sw	$s3, 24($sp)
	sw	$s4, 32($sp)
	sw	$s5, 40($sp)
	sw	$s6, 48($sp)
	
# Initialization
	# Init return values
	move	$v0, $a3
	move	$s0, $a3
	xor	$v1, $v1, $v1

	# Pattern size
	srl	$s1, $a1, 16
	andi	$s2, $a1, 0xFFFF
	
	# Img params
	lw	$s3, ($a0)
	lw	$s4, 4($a0)
	lw	$t0, 8($a0)

	# Bytes in each line
	addiu	$s5, $s3, 31
	srl	$s5, $s5, 5
	sll	$s5, $s5, 2
	
	# If dimensions can't fit pattern, end
	bgt	$s1, $s3, FP_end
	bgt	$s2, $s4, FP_end
	
	# Substracting pattern size from image size (protection from out of bounds)
	sub	$s3, $s3, $s1
	addiu	$s3, $s3, 1
	sub	$s4, $s4, $s2
	addiu	$s4, $s4, 1
	
	lb	$t6, ($a2)	# $t6 holds pattern row
	#maskFF
	and	$t6, $t6, 0xFF
	or	$t6, $t6, 1
	sll	$t6, $t6, 8
	xor	$t7, $t7, $t7	# pattern row counter

# Algorithm begins
	xor	$t1, $t1, $t1	# row counter
	move	$s6, $t0	# line save s6 -> s2
	add	$s6, $s6, $s5	# move to "previous" row to restore at the beginning of loop	
	
FP_row:
	sub	$s6, $s6, $s5
	move	$t0, $s6
	# Check for image end
	bge	$t1, $s4, FP_end
	addiu	$t1, $t1, 1
	xor	$t2, $t2, $t2	# column counter
	lb	$t3, ($t0)	# $t3 holds current two bytes
	#maskFF
	and	$t3, $t3, 0xFF
	sll	$t3, $t3, 8	# shift to fit 2 bytes in register
	subiu	$t0, $t0, 1	# go back one byte to return at the beginning of loop

FP_column:
	addiu	$t0, $t0, 1
	# Check for column end
	bge	$t2, $s3, FP_row
	lb	$t4, 1($t0)	# load second byte
	#maskFF
	and	$t4, $t4, 0xFF
	or	$t3, $t3, $t4	# now two bytes in $t3
	xor	$t8, $t8, $t8	# byte shift
	
FP_byte:
	# Check exit conditions
	bge	$t8, 8, FP_column
	bge	$t2, $s3, FP_column
	# Pattern check
	or	$t4, $t3, $t6
	srl	$t6, $t6, 8
	srl	$t4, $t4, 8
	beq	$t4, $t6, FP_found_row
	sll	$t6, $t6, 8
	# Shifting byte and decimating it to 2B
	sll	$t3, $t3, 1
	and	$t3, $t3, 0xFFFF
	# Increment counters
	addiu	$t2, $t2, 1
	addiu	$t8, $t8, 1
	b	FP_byte

FP_found_row:
addiu 	$t7, $t7, 1			#increment counter of pattern rows
beq	$t7, $s2, pattern_found		#check if all pattern rows found
beq	$t2, $s3, pic_end_check
not_end:
lb	$t4, 1($t0)			#loading next byte from next line
and	$t4, $t4, 0x000000ff	

pic_end:
sub	$t0, $t0, $s5			#moving to next line
lb	$t9, ($t0)			#loading byte from next line
and	$t9, $t9, 0x000000FF
sll	$t9, $t9, 8			#transforming for easier comparison

or	$t4, $t4, $t9			#t5 contains 2 bytes from next line
move 	$s7, $t8			#s7 = counter of shifts to get to right position in next line

shift:
beqz	$s7, comp
sll	$t4, $t4, 1			#shifting bytes to correct position
subiu	$s7, $s7, 1
j shift

comp:
and	$t4, $t4, 0x0000ffff		#removing upper bytes
addiu	$a2, $a2, 4			#incrementing pattern array
lb	$t6, ($a2)			#loading next row of pattern
and	$t6, $t6, 0x000000FF		
or	$t6, $t6, 0x00000001
sll	$t6, $t6, 8			#transforming for easier comparison
or	$t4, $t4, $t6			#oring with pattern
srl	$t6, $t6, 8			#shifting to compare
srl	$t4, $t4, 8
beq	$t4, $t6, FP_found_row	#next row found

ret:
beqz	$t7, load_pattern		
sub	$a2, $a2, 4			#going to beginning of pattern array
add 	$t0, $t0, $s5			#going back in lines
subiu	$t7, $t7, 1
j 	ret

pattern_found:
addiu 	$v1, $v1, 1			#incrementing counter of occurences
subiu	$t7, $t7, 1			
sw	$t2, ($a3)			#storing coordinates of found pattern
addiu	$a3, $a3, 4
addiu	$t1, $t1, -1
sw	$t1, ($a3)
addiu	$a3, $a3, 4
addiu	$t1, $t1, 1
j 	ret

load_pattern:
lb	$t6, ($a2)		#t6 = 1st line of pattern
and	$t6, $t6, 0x000000FF
or	$t6, $t6, 0x00000001
sll	$t6, $t6, 8		#transforming
sll	$t3, $t3, 5		#shifting image pixels,
and	$t3, $t3, 0x0000FFFF	#deleting msb
addiu 	$t2, $t2, 5		#increment counter
addiu 	$t8, $t8, 5
j FP_byte

pic_end_check:
bne	$t1, $s4, not_end
beq 	$t1, $s4, pic_end

return:
move	$s3, $v1
set_ptr:
blez	$s3, set_return		#p_resetting pointer to p_result
addiu	$s3, $s3, -1
addiu	$a3, $a3, -8
j set_ptr

set_return:
move	$v0, $a3		#setting values to be returned
move 	$v1, $v1
	
FP_end:
#	Epilogue
	lw	$s0, 0($sp)
	lw	$s1, 8($sp)
	lw	$s2, 16($sp)
	lw	$s3, 24($sp)
	lw	$s4, 32($sp)
	lw	$s5, 40($sp)
	lw	$s6, 48($sp)
	addiu	$sp, $sp, 48

	# return fun
	jr	$ra