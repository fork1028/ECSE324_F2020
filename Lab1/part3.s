.global _start

array: .word 3, 4, 5, 4
n: .word 4
log: .word 0
mean: .word 0


_start:
 LDR R0, =array
 LDR R1, log
 MOV R2, #1
 LDR R3, n
 LDR R7, mean
 MOV R6, #0 // store i in first for loop
 LDR R10, [R0] // ptr=array[0]
 MOV R9, #0 // i in second for loop

while:
 LSLS R4, R2, R1 // 1<<log2_n
 CMP R4, R3      // if (R4<n)?
 BGE loop        // if not, jump to the for loop
 ADDS R1, R1, #1  // if is, log2_n++
 B while         // loop

loop:
  CMP R6, R3  // check if i<n?
  BGE shift // if not, go to the last line of the while loop
  
  LDR R8, [R0, R6, LSL#2] // R8=array[i]
  ADDS R7, R7, R8

  ADDS R6, R6, #1 // i++
  B loop     // loop
 
shift:
  ASRS R7, R7, R1  // mean>>log2_n
  B center    // go to center the array
 
center:
 CMP R9, R3 // check if i<n?
 BEQ end         // terminates
 
 LDR R8, [R0, R9, LSL#2] // R8=array[i]
 SUB R8, R8, R7  // R8=array[i]-mean
 STR R8, [R0, R9, LSL#2] // array[i]=R8

 ADDS R9, R9, #1 // i++
 B center
 
 
end:
 
.end
