LR	equ	R5
PC	equ	R7
P	equ	R0
PP	equ 	R1
CNT	equ	R2
VAL	equ	R3
I	equ	R4
ONE	equ	R5
LIMNUM	equ	#3800		;greatest number is 7FFF because of comparisons with negatives (signed)
LIMIT	equ	R6



	org	#FF00		;MAIN LOOP OCCURS AT FF00
START
	movl	LIMNUM,LIMIT
	movh	LIMNUM,LIMIT
	movlz	$1,ONE		; save number 1 in R5
	movlz	$2,P		; Save number 2 in R0
LOOP1	
	mov	P,CNT		;set counter to P
	movlz	#0000,PP	; reset R1

; Following loop creates P^2
MULTLP	add	P,PP		;add P to PP
	sub	$1,CNT		;decrement counter (initially set to P)
	bnz	MULTLP		;as long as counter isnt zero, continue looping

	cmp	LIMIT,PP	;compare P squared to limit
	BGE	STOPLOOP1	;stop looping if P squared is larger than loop limit
	mov	P,R6		;temporarly store P in R6
	add	P,R6		;multiply P by 2 and save it in R6
	ld	R6,VAL		;loads value from memory (val <- mem[2p])
	movl	LIMNUM,LIMIT	;restoring R6 to LIMIT
	movh	LIMNUM,LIMIT	
	cmp	$0,VAL		
	BNE	SKIP1		;if value is NOT zero, then skip following lines
	

	mov	PP,I		;set I initiaially equal to P squared		
LOOP2	cmp	LIMIT,I		;compare I to limit
	BGE	STOPLOOP2	;if I is larger than limit, then dont loop again
	mov	I,R6		;temporarly store I in R6
	add	I,R6		;multiply I by 2 and save it in R6
	st	ONE,R6		;store 1 in memory to indicate not prime
	movl	LIMNUM,LIMIT	;restoring R6 to LIMIT
	movh	LIMNUM,LIMIT	
	add	P,I		;increment I by P
	BRA	LOOP2		;do loop again
STOPLOOP2

SKIP1	add	$1,P		;increment P by 1
	BRA	LOOP1		;Loop again
STOPLOOP1


;at this point, any value in memory between locations 0000 and LIMIT should be a 1 or a zero.
;if the value is a 1 that means it is not a prime, if a value is zero it is a prime
;Now program goes through memory, checks if value in address is 0 or 1, if its 0, then write that address somewhere else to save it


	movl	#A000,R5	;can now override R5 (not needed any more) to set starting point for saving memory at location 10,000 (A000)
	movh	#A000,R5	
	movlz	#0002,P
LOOP3	cmp	LIMIT,P
	BGE	STOPLOOP3	;stop looping if P is greater than or equal to limit
	mov	P,R6		;temporarly store P in R6
	add	P,R6		;multiply P by 2 and save it in R6
	ld	R6,VAL		;loads value from memory (val <- mem[2p])
	movl	LIMNUM,LIMIT	;restoring R6 to LIMIT
	movh	LIMNUM,LIMIT
	cmp	$0,VAL		
	BNE	SKIP2		;if value is not zero, it is not a prime, so skip saving it to memory
	swpb	P		;swap bytes of P because of little endian (for presentation)
	st	P,R5		;Store the byte address of val, not val itself
	swpb	P		;swap bytes back to how they should be
	add	$2,R5		;Increment by two as we are storing addresses - 16 bits
SKIP2	add	$1,P
	BRA	LOOP3
STOPLOOP3
BRA	DONE


	org	#FFA0
DONE	BRA	DONE
end START
