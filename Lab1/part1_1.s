.global _start

xi: .word 1
a: .word 168
cnt: .word 100
t: .word 2

_start:
	LDR R0, xi
	LDR R1, a
	LDR R2, cnt
	MOV R4, #2 // t
	MOV R3, #0 // store step
	MOV R6, #0 // store i
	NEG R4, R4 // negate t
	MOV R5, R4 // move -t to R5
	
loop:
	CMP R6, R2 // if i<cnt?
	BGE end    // if not, terminates
	MULS R3, R0, R0  // xi*xi
	SUBS R3, R3, R1  // xi*xi-a
	MULS R3, R3, R0  // (xi*xi-a)*xi
	ASRS R3, R3, #10 // >>k
	CMP R3, #2  // if step>t?
	BLE elseif  // if not, go to else if
	MOV R3, #2  // if is, step=t
	B assign // go to the last line in the for loop
	
elseif:
	CMP R3, R5 // if step<-t 
	BGE assign // if not, go to the last line in the for loop
	MOV R3, R5 // step=-t
	
assign:
	SUBS R0, R0, R3  // xi=xi-step
	ADDS R6, R6, #1  // i++
	B loop   // loop

	
.end
	
	
	
	
