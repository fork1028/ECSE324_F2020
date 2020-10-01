.global _start

array: .word 5, 6, 7, 8
n: .word 4
log: .word 0
tmp: .word 0
norm: .word 1
cnt: .word 100
k: .word 10
t: .word 2

_start:
	
	LDR R0, =array // now points to the address of the first element in the array
	LDR R1, log
	LDR R2, n
	LDR R3, tmp
	LDR R9, cnt
	MOV R11, #0 // store the result of 1<<log2_n
	MOV R5, #0 // store *ptr * *ptr
	MOV R6, #0 // store i in calcNorm
	MOV R7, #0 // store i in sqrtIter
	MOV R8, #2 // t
	NEG R8, R8 // negate t
	MOV R8, R8 // move -t to R8
	MOV R10, #0 // store result
	MOV R12, #1 
	
while:
	LSLS R11, R12, R1 // 1<<log2_n
	CMP R11, R2      // if (R1<n)?
	BGE loop        // if not, jump to the for loop
	ADDS R1, R1, #1  // if is, log2_n++
	B while         // loop
	
loop:
 	CMP R6, R2  // check if i<n?
 	BGE shift // if not, go to the last line of the while loop
 	LDR R4, [R0], #4 // ptr++
	MULS R5, R4, R4 // R5=(*ptr)*(*ptr)
 	ADDS R3, R3, R5 // R3=tmp+R5
 	ADDS R6, R6, #1 // i++
 	B loop     // loop
 
shift:
 	ASRS R3, R3, R1  // >>log2_n
	BL sqrtIter

sqrtIter:
  	CMP R7, R9 // if i<cnt?
  	BGE end    // if not, terminates
  	MULS R5, R10, R10  // xi*xi
  	SUBS R5, R5, R3  // xi*xi-a
  	MULS R5, R5, R0  // (xi*xi-a)*xi
  	ASRS R5, R5, #10 // >>k
  	CMP R5, #2  // if step>t?
  	BLE elseif  // if not, go to else if
  	MOV R5, #2  // if is, step=t
  	B assign // go to the last line in the for loop
  	BX LR
 
elseif:
  	CMP R5, R8 // if step<-t 
  	BGE assign // if not, go to the last line in the for loop
  	MOV R5, R8 // step=-t
 
assign:
  	SUBS R10, R10, R5  // xi=xi-step
  	ADDS R7, R7, #1  // i++
  	B sqrtIter   // loop

.end
	
