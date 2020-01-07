	.data
	
	.text
	.globl FindPattern
# Point* FindPattern(imgInfo* pImg, int pSize, int* ptrn, Point* pResult)
# $v0	-> returned buffer of found coordinates (Point*)
# $v1	-> size of returned buffer
# $a0	-> imgInfo* pImg - image information
# $a1	-> int pSize - size of int* ptrn
# $a2	-> int* ptrn - the pattern to search for
# $a3	-> Point* pResult - pointer to buffer to return to
FindPattern:
	# TODO: Implement
#	Prologue
	# Init return values
	move	$v0, $a3
	move	$t7, $a3
	li	$v1, 1
	
	li	$t0, 123
	sw	$t0, ($t7)
	li	$t0, 456
	sw	$t0, 4($t7)

	# return fun
	jr	$ra
