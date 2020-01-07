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
#	int i, j, k, l;
#	int mask;
#	int rx = pSize >> 16;
#	int ry = pSize & 0xFFFF;
#
#	fCnt = 0;
#	for (i=0; i < pImg->height - ry; ++i)
#		for (j=0; j < pImg->width - rx; ++j)
#		{
#			// for a rectangle with upper lefr corner in (i,j)
#			// check if there is pattern in image
#			for (k=0; k < ry; ++k)
#			{
#				mask = 1 << (rx - 1);
#				for (l=0; l < rx; ++l, mask >>= 1)
#					if (GetPixel(pImg, j+l, i+k) != ((ptrn[k] & mask) != 0))
#						break;
#				if (l < rx) // pattern not found
#					break;
#			}
#			if (k >= ry) //pattern found
#			{
#				pDst[*fCnt].x = j;
#				pDst[*fCnt].y = i;
#				++(*fCnt);
#			}
#		}
#	return pDst;
#
#	i -> $t0
#	i limit -> $s4
#	j -> $t1
#	j limit -> $s5
#	k -> $t2
#	l -> $t3
#	mask -> $t4
#	rx -> $s1
#	ry -> $s2
#	rx-1 -> $s3
FindPattern:
	# TODO: saving $s and restoring
#	Prologue
	addiu	$sp, $sp, -48
	sw	$s0, 0($sp)
	sw	$s1, 8($sp)
	sw	$s2, 16($sp)
	sw	$s3, 24($sp)
	sw	$s4, 32($sp)
	sw	$s5, 40($sp)
	# Init return values
	move	$v0, $a3
	move	$s0, $a3
	xor	$v1, $v1, $v1

	srl	$s1, $a1, 16
	andi	$s2, $a1, 0xFFFF
	addiu	$s3, $s1, -1
	
	lw	$s4, 4($a0)
	sub	$s4, $s4, $s2
	lw	$s5, ($a0)
	sub	$s5, $s5, $s1
	
	xor	$t0, $t0, $t0
		FPfor_i:
		#
		xor	$t1, $t1, $t1
			FPfor_j:
			#
			xor	$t2, $t2, $t2
				FPfor_k:
				#
				li	$t5, 1
				sllv	$t5, $t5, $s3
				xor	$t3, $t3, $t3
					FPfor_l:
					#
#					if (GetPixel(pImg, j+l, i+k) != ((ptrn[k] & mask) != 0))
#						break;
					mul	$t6, $t2, 4
					addu	$t6, $a2, $t6
					lw	$t6, ($t6)
					and	$t6, $t6, $t4
					# $t6 -> ptrn[k] & mask
					la	$t7, 12($a0)
					addu	$t8, $t1, $t3
					srl	$t8, $t8, 3
					mul	$t8, $t8, 4
					addu	$t7, $t7, $t8
					lw	$t8, ($a0)
					addiu	$t8, $t8, 31
					srl	$t8, $t8, 5
					sll	$t8, $t8, 2
					addu	$t9, $t0, $t2
					mul	$t8, $t8, $t9
					mul	$t8, $t8, 4
					addu	$t7, $t7, $t8
					lw	$t7, ($t7)
					# $t7 -> pPix from GetPixel
					li	$t8, 0x80
					addu	$t9, $t1, $t3
					andi	$t9, $t9, 0x07
					srlv	$t8, $t8, $t9
					# $t8 -> mask from GetPixel
					and	$t7, $t7, $t8
					
					beqz	$t7, FPSKIPZERO
					beqz	$t6, FPSKIPZERO
					bne	$t6, $t7, FPbreak_l
					FPSKIPZERO:

					addiu	$t3, $t3, 1
					srl	$t5, $t5, 1
					bltu	$t3, $s1, FPfor_l
				FPbreak_l:
				bltu	$t3, $s1, FPbreak_k
				addiu	$t2, $t2, 1
				bltu	$t2, $s2, FPfor_k
			FPbreak_k:
			bltu	$t2, $s2, FPskip_found
			addiu	$v1, $v1, 1
			sw	$t1, ($s0)
			sw	$t0, 4($s0)
			addiu	$s0, $s0, 8
			FPskip_found:
			addiu	$t1, $t1, 1
			bltu	$t1, $s5, FPfor_j	
		addiu	$t0, $t0, 1
		bltu	$t0, $s4, FPfor_i
		
#	Epilogue
	lw	$s0, 0($sp)
	lw	$s1, 8($sp)
	lw	$s2, 16($sp)
	lw	$s3, 24($sp)
	lw	$s4, 32($sp)
	lw	$s5, 40($sp)
	addiu	$sp, $sp, 48

	# return fun
	jr	$ra
