	org	#1000
START	
	ADD	#10,R0
LOOP
	ADD	#1,R0
	CMP	#20,R0
	BEQ	DONE
	ADD	#1,R1
	BRA	LOOP
DONE	BRA	DONE
END START