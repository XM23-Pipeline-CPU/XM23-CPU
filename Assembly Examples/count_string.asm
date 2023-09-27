	org	#0020
string ascii "This is a very long string 1 2 3 byeeee, oh wait, hi! How are you doing? I am writing a longer string so that I can benchmark the performance of my system. I will keep writing for a little and see what the max is. Seems to be here :)\0"
	org	#1000
START	
ADD	#20,R0
LOOP
	LD.B	R0+,R2
	CMP.B	#0,R2
	BEQ	DONE
	ADD	#1,R1
	BRA	LOOP
DONE
END START