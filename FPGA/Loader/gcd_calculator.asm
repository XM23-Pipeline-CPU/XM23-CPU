; defining some symbols
u	equ	R0
v	equ	R1
addr	equ	R2
zero	equ	#0000


; load default values into data memory
DATA
	ORG	zero		; set data memory starting address to 0x0000
	WORD	#1000		; store 0x1000 at byte address 0x0000
	WORD	#1200		; store 0x1200 at byte address 0x0002

; start of gcd calculator code
CODE
	ORG	zero		; set program memory starting address to 0x0000
	MOVLZ	zero,addr	; set data memory fetch address to 0x0000
	LD	addr+,u		; load value from memory 0x0000 into 'u' (R0), and post increment address
	LD	addr+,v		; load value from memory 0x0002 into 'v' (R1), and post increment address

WHILE	CMP	v,u		; check if u == v (does u - v)
	BEQ	OUTPUT		; if equal, exit while loop
	BN	ELSE		; if u is smaller than v go to ELSE
IF	SUB	v,u		; u = u - v
	BRA	WHILE		; go back to while loop
ELSE	SUB	u,v		; v = v - u
	BRA	WHILE		; go back to while loop


OUTPUT	ST	u,addr		; store u in data memory location 0x0004
DONE	BRA	DONE
END
	