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
#	$s0 -> last saved point
#	$s1 -> pattern horizontal size	(s2)
#	$s2 -> pattern vertical size	(s3)
#	$s3 -> img width		(s0)
#	$s4 -> img height		(s1)
#	$s5 -> bytes in line		(s4)
#	$t0 -> image pointer
#
#	$v0				($t3)
FindPattern:
lw	$s0, ($a0)		#s0 = width
addiu 	$a0, $a0, +4		
lw	$s1, ($a0)		#s1 = height
addiu 	$a0, $a0, +4		
lw	$t0, ($a0)		#t0 = pointer to image
srl	$s2, $a1, 16		#s2 = pattern width
andi	$s3, $a1, 0xFFFF	#s3 = pattern height
addiu 	$s4, $s0, 31		
srl	$s4, $s4, 5
sll	$s4, $s4, 2		#s4 = bytes in line
move	$s6, $a2		#s6 = pointer to pattern
lb	$t6, ($s6)		#t6 = 1st line of pattern
and	$t6, $t6, 0x000000FF
or	$t6, $t6, 0x00000001
sll	$t6, $t6, 8
addiu 	$t7, $zero, 0		#t7 = counter for pattern lines found
addu 	$t3, $zero, 0		#t3 = counter of occurences of pattern


bgt	$s2, $s0, return	#checking if width is not to small
bgt	$s3, $s1, return	#same for height

sub	$s0, $s0, $s2		#substracting pattern size from img size
addiu	$s0, $s0, 1	
sub	$s1, $s1, $s3
addiu	$s1, $s1, 1

start:
addiu 	$t1, $zero, 0		#t1 = counter of rows
move	$s2, $t0		#storing address of line

rows:
bge	$t1, $s1, return	#check end of image
addiu 	$t1, $t1, 1		#increment counter of rows
addiu 	$t2, $zero, 0		#t2 = counter of columns
lb	$t4, ($t0)		#read byte of picture
and	$t4, $t4, 0x000000ff	
sll	$t4, $t4, 8		#transforming byte for easier comparison

columns:
bge	$t2, $s0, next_row	#check end of row
lb	$t5, 1($t0)		#read next byte of picture
and	$t5, $t5, 0x000000ff	
or	$t4, $t4, $t5		#t4 = 2 bytes of picture
addiu 	$t8, $zero, 0		#t8 = counter for byte

byte:
bge	$t8, 8, end_byte	#shifted 8 times
bge	$t2, $s0, end_byte	#end of row check
or	$t5, $t4, $t6		#oring with pattern
srl	$t6, $t6, 8		#shifting to compare
srl	$t5, $t5, 8		
beq	$t5, $t6, pattern_row_found	#comparing
sll	$t6, $t6, 8		#not found, shifting back
sll	$t4, $t4, 1		#shifting bits of image to compare next byte
and	$t4, $t4, 0x0000FFFF	#deleting msb
addiu 	$t2, $t2, 1		#increment counter
addiu 	$t8, $t8, 1
j byte

end_byte:
addiu	$t0, $t0, 1		#go to next byte
j columns

next_row:
sub	$s2, $s2, $s4		#going to next row
move	$t0, $s2		#loading address of next row to t0
j rows

pattern_row_found:
addiu 	$t7, $t7, 1			#increment counter of pattern rows
beq	$t7, $s3, pattern_found		#check if all pattern rows found
beq	$t2, $s0, pic_end_check
not_end:
lb	$t5, 1($t0)			#loading next byte from next line
and	$t5, $t5, 0x000000ff	

pic_end:
sub	$t0, $t0, $s4			#moving to next line
lb	$t9, ($t0)			#loading byte from next line
and	$t9, $t9, 0x000000FF
sll	$t9, $t9, 8			#transforming for easier comparison

or	$t5, $t5, $t9			#t5 contains 2 bytes from next line
move 	$s7, $t8			#s7 = counter of shifts to get to right position in next line

shift:
beqz	$s7, comp
sll	$t5, $t5, 1			#shifting bytes to correct position
subiu	$s7, $s7, 1
j shift

comp:
and	$t5, $t5, 0x0000ffff		#removing upper bytes
addiu	$s6, $s6, 4			#incrementing pattern array
lb	$t6, ($s6)			#loading next row of pattern
and	$t6, $t6, 0x000000FF		
or	$t6, $t6, 0x00000001
sll	$t6, $t6, 8			#transforming for easier comparison
or	$t5, $t5, $t6			#oring with pattern
srl	$t6, $t6, 8			#shifting to compare
srl	$t5, $t5, 8
beq	$t5, $t6, pattern_row_found	#next row found

ret:
beqz	$t7, load_pattern		
sub	$s6, $s6, 4			#going to beginning of pattern array
add 	$t0, $t0, $s4			#going back in lines
subiu	$t7, $t7, 1
j 	ret

pattern_found:
addiu 	$t3, $t3, 1			#incrementing counter of occurences
subiu	$t7, $t7, 1			
sw	$t2, ($a3)			#storing coordinates of found pattern
addiu	$a3, $a3, 4
addiu	$t1, $t1, -1
sw	$t1, ($a3)
addiu	$a3, $a3, 4
addiu	$t1, $t1, 1
j 	ret

load_pattern:
lb	$t6, ($s6)		#t6 = 1st line of pattern
and	$t6, $t6, 0x000000FF
or	$t6, $t6, 0x00000001
sll	$t6, $t6, 8		#transforming
sll	$t4, $t4, 5		#shifting image pixels,
and	$t4, $t4, 0x0000FFFF	#deleting msb
addiu 	$t2, $t2, 5		#increment counter
addiu 	$t8, $t8, 5
j byte

pic_end_check:
bne	$t1, $s1, not_end
beq 	$t1, $s1, pic_end

return:
move	$s0, $t3
set_ptr:
blez	$s0, set_return		#resetting pointer to result
addiu	$s0, $s0, -1
addiu	$a3, $a3, -8
j set_ptr

set_return:
move	$v0, $a3		#setting values to be returned
move 	$v1, $t3

jr $ra