.global _start

array: .word 4, 2, 1, 4, -1
n: .word 5


_start:
 
  LDR R0, =array
  LDR R1, n
  MOV R6, #-1 // i for outer loop
  SUB R2, R1, #1
  LDR R5, [R0] // ptr=&array[0]
 
outerLoop:
  ADDS R6, R6, #1   // i++
  CMP R6, R2 // check if i < n-1
  BGE end   // if not terminates
  ADDS R7, R6, #1 // j=i+1
  B innerLoop
  B outerLoop
 
innerLoop:
  CMP R7, R1 // check if j<n
  BGE outerLoop  // if not, jump to the outer loop
  LDR R5, [R0, R6, LSL#2] // R5=array[i]
  MOV R4, R6  // cur_min_idx=i
  LDR R8, [R0, R7, LSL#2] // R8=array[j]
  CMP R5, R8   // if tmp>*(ptr+j)?
  BLE swap     // if not, go to swap
  LDR R5, [R0, R7, LSL#2] // R5=array[j]
  MOV R4, R7  // cur_min_idx=j

swap:
  LDR R5, [R0, R6, LSL#2] // R5(tmp)=array[i]
  LDR R9, [R0, R4, LSL#2] // R9=array[cur_min_idx]
  STR R9, [R0, R6, LSL#2] // array[i]=R9
  STR R5, [R0, R4, LSL#2]
  ADDS R7, R7, #1  // j++
  B innerLoop

end:
 
.end
