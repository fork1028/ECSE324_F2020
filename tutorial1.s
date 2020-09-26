//Q2

.text
.global _start  // tell the program where to start from.

LIST: .word  2, 4, -3, 0, -5, 8, 0, 1
NUM: .word 7

_start:
      LDR R0, =NUM         // Load NUM memory address in R0.
      LDR R1, [R0]         // R1 now has the value at the address NUM, which is 7.
      MOV R0, #0           // Initialize loop counter.
      MOV R6, #0           // Initialize a counter for zero occurrences.
      LDR R3, =LIST        // Load the memory address of the first number in R3.
start_over:
      SUBS R4, R0, R1
      BGE end          // The process should  go as long as counter (R0) is less than  NUM (R1)
      LDR R5, [R3]         // get a value from the list.
	  CMP R5, #0
      BEQ increment    // if R5 is equal to zero, then go to 'increment'.
get_the_next_number:
      ADD R0, R0, #1        // increment loop counter
      ADD R3, R3, #4        // getting the address of the next number in the list.
      B start_over          // branch unconditionally to 'start_over'.
increment:
      ADD R6, R6, #1        // increment zero occurences counter
      B get_the_next_number // branch unconditionally to 'get_the_next_number'.

.end
	
	
	
