.global _start

.equ BASE_ADD, 0xFFFEC600
.equ HEX0_3_BASE, 0xFF200020
.equ HEX4_5_BASE, 0xFF200030

// E - start
// A - auto
// I - interrupt
// IAE
// 000 - 0
// 001 - 1
// 010 - 2
// 011 - 3
// 100 - 4
// 101 - 5
// 110 - 6
// 111 - 7

_start:
	MOV R0, #0x00000001 // set to hex 0
	LDR R11, =#200000000  // load value 
	LDR R2, =BASE_ADD // make R2 point to the base address
	STR R11, [R2] // pass the load value
	MOV R1, #7 // configuration bits
	MOV R12, #0 // loop counter

// config the timer
ARM_TIM_config_ASM:
	STR R1, [R2, #8] // write the bits to control register
	
	
loop:
	BL ARM_TIM_read_INT_ASM
	CMP R4, #1
	BEQ check
	B loop
	
check:
	BL ARM_TIM_clear_INT_ASM
	CMP R12, #16
	MOVEQ R12, #0
	MOV R1, R12
	ADDS R12, R12, #1
	MOV R0, #0x00000002
	BL HEX_clear_ASM
	MOV R0, #0x00000004
	BL HEX_clear_ASM
	MOV R0, #0x00000008
	BL HEX_clear_ASM
	MOV R0, #0x00000001
	BL HEX_write_ASM
	B loop


// read F bit
ARM_TIM_read_INT_ASM:
	LDR R4, [R2, #12] // make R4 point to F bit
	AND R4, R4, #1 // keep the last bit
	BX LR

ARM_TIM_clear_INT_ASM:
	MOV R10, #1 
	STR R10, [R2, #12] // write 1 to the F bit to clear it
	BX LR

HEX_clear_ASM:
 PUSH {R1-R8,LR}
 LDR R1, =HEX0_3_BASE // read from 0_3 address
 MOV R3, #0   
   
clearloop: 
 CMP R3, #6   // check if all hex displays are iterated
 BEQ cleardone
 AND R4, R0, #1  
 CMP R4, #1   
 BLEQ clear

 LSR R0, R0, #1   
 
 ADD R3, R3, #1  // counter++
 B clearloop

clear:  
 CMP R3, #3   
 SUBGT R3, R3, #4 
 LDRGT R1, =HEX4_5_BASE // read from 4_5 address
 LDR R2, [R1]  
 LDR R5, =CLEAR 
 LSL R6, R3, #2  
 LDR R5, [R5, R6] 
 
 AND R2, R2, R5  
 STR R2, [R1]  
 BX LR
 
HEX_write_ASM: 
 MOV R10, R0    
 MOV R9, R1    
 PUSH {R2-R8,LR}
 BL HEX_clear_ASM  
 POP {R2-R8,LR} 
 
 MOV R0, R10    

 PUSH {R1-R8,LR}
 LDR R1, =HEX0_3_BASE  
 MOV R3, #0    
 LDR R5, =NUM   
 ADD R5, R5, R9, LSL #2 // to go to the corresponding address
 
 B writeloop

writeloop: 
 CMP R3, #6   // check if all hex displays are iterated 
 BEQ writedone
 AND R4, R0, #1  
 CMP R4, #1
 BLEQ write

 LSR R0, R0, #1   
 ADD R3, R3, #1  // counter++
 B writeloop

write:  
 CMP R3, #3   
 SUBGT R3, R3, #4 
 LDRGT R1, =HEX4_5_BASE 
 LDR R2, [R1]  
 LDR R7, [R5]  
 LSL R6, R3, #3  
 LSL R7, R7, R6  
 ORR R2, R2, R7  
 STR R2, [R1]  
 BX LR
 
cleardone: POP {R1-R8, LR}
   BX LR
   
writedone: POP {R1-R8, LR}
   BX LR
	
			
NUM:		
	.word 0x0000003F //(00111111)b = 0
	.word 0x00000006 //(00000110)b = 1
	.word 0x0000005B //(01011011)b = 2
	.word 0x0000004F //(01001111)b = 3
	.word 0x00000066 //(01100110)b = 4
	.word 0x0000006D //(01101101)b = 5
	.word 0x0000007D //(01111101)b = 6
	.word 0x00000007 //(00000111)b = 7	
	.word 0x0000007F //(01111111)b = 8
	.word 0x00000067 //(01100111)b = 9
	.word 0x00000077 //(01110111)b = A
	.word 0x0000007C //(01111100)b = B
	.word 0x00000039 //(00111001)b = C
	.word 0x0000005E //(01011110)b = D
	.word 0x00000079 //(01111001)b = E
	.word 0x00000071 //(01110001)b = F
	
CLEAR:	.word 0xFFFFFF00
			.word 0xFFFF00FF
			.word 0xFF00FFFF
			.word 0x00FFFFFF
	
.end
