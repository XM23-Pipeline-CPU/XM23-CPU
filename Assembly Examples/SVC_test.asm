SVC_VECT	equ	#FFC0
VECT_ISR	equ	#0100
PRIO_FIVE	equ	#00A0
LR	equ	R5
PC	equ	R7

	org	SVC_VECT
	PSW0	word	PRIO_FIVE
	PC0	word	VECT_ISR

	org	#0000
Start
	add	R1,R2
	svc	#0
	movls	#FFFF,R4
	bra	done

	org	VECT_ISR
	movls	#FFFF,R3
	mov	LR,PC
	
	org	#0200
done
end Start