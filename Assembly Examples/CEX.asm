START
;checking EQ condition
	SETCC	Z
	CEX	EQ,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	CLRCC	Z
	CEX	EQ,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	
	MOVLZ	#0000,R0	;CLEAR R0
;checking NE condition
	CLRCC	Z
	CEX	NE,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	SETCC	Z
	CEX	NE,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0

	MOVLZ	#0000,R0	;CLEAR R0
;checking CS condition
	SETCC	C
	CEX	CS,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	CLRCC	C
	CEX	CS,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	
	MOVLZ	#0000,R0	;CLEAR R0
;checking CC condition
	CLRCC	C
	CEX	CC,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	SETCC	C
	CEX	CC,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0

	MOVLZ	#0000,R0	;CLEAR R0
;checking MI condition
	SETCC	N
	CEX	MI,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	CLRCC	N
	CEX	MI,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	
	MOVLZ	#0000,R0	;CLEAR R0
;checking PL condition
	CLRCC	N
	CEX	PL,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	SETCC	N
	CEX	PL,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0

	MOVLZ	#0000,R0	;CLEAR R0
;checking VS condition
	SETCC	V
	CEX	VS,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	CLRCC	V
	CEX	VS,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	
	MOVLZ	#0000,R0	;CLEAR R0
;checking VC condition
	CLRCC	V
	CEX	VC,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	SETCC	V
	CEX	VC,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0

	MOVLZ	#0000,R0	;CLEAR R0
;checking HI condition
	SETCC	C
	CLRCC	Z
	CEX	HI,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	CLRCC	C
	SETCC	Z
	CEX	HI,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	
	MOVLZ	#0000,R0	;CLEAR R0
;checking LS condition
	CLRCC	C
	SETCC	Z
	CEX	LS,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	SETCC	C
	CLRCC	Z
	CEX	LS,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	
	MOVLZ	#0000,R0	;CLEAR R0
;checking GE condition
	SETCC	N
	SETCC	V
	CEX	GE,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	SETCC	N
	CLRCC	V
	CEX	GE,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	
	MOVLZ	#0000,R0	;CLEAR R0
;checking LT condition
	SETCC	N
	CLRCC	V
	CEX	LT,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	SETCC	N
	SETCC	V
	CEX	LT,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	
	MOVLZ	#0000,R0	;CLEAR R0
;checking GT condition
	CLRCC	Z
	SETCC	N
	SETCC	V
	CEX	GT,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	SETCC	Z
	CEX	GT,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	
	MOVLZ	#0000,R0	;CLEAR R0
;checking LE condition
	SETCC	Z
	CEX	LE,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	CLRCC	Z
	SETCC	N
	SETCC	V
	CEX	LE,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
	
	MOVLZ	#0000,R0	;CLEAR R0
;checking TR condition
	CEX	TR,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0
;checking FL condition
	CEX	FL,$1,$1
	MOVL	#00FF,R0
	MOVH	#FF00,R0

END START