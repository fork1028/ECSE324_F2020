.global _start

.equ HEX0_3_BASE, 0xFF200020
.equ HEX4_5_BASE, 0xFF200030

//HEX0, 0x00000001
//HEX1, 0x00000002
//HEX2, 0x00000004
//HEX3, 0x00000008
//HEX4, 0x00000010
//HEX5, 0x00000020

//HEX0 = 00000001
//HEX1 = 00000010
//HEX2 = 00000100
//HEX3 = 00001000
//HEX4 = 00010000
//HEX5 = 00100000

_start:
	MOV R0, #0x00000004 // pass hex parameter
	MOV R1, #0x0000005B
	LDR R3, =HEX0_3_BASE // load HEX0_3
	LDR R4, =HEX4_5_BASE // load HEX4_5

loop:
	//BL HEX_flood_ASM
	//BL HEX_clear_ASM
	BL HEX_write_ASM
	//B loop
 
HEX_flood_ASM:
	PUSH {R1-R8, LR}
	MOV R1, #0 // loop counter

floodloop:
	CMP R1, #6 // check if already iterated all hex
	BEQ done // if is, terminates
	ANDS R7, R0, #1 // and hex parameter with 00000001
	CMP R7, #1 // check if the last bit is 1
	BLEQ flood
	LSR R0, R0, #1 // shift the hex parameter by 1 bit
	ADDS R1, R1, #1 // increment index for hex going to be flooded
	B floodloop // loop back
 
flood:
	LDR R2, [R3] // load hex0_3 address to R2
	MOV R5, #0x000000FF 
	CMP R1, #0 // check if index == 0
	ROREQ R5, R5, #0 // rotate by 'index' bits
	CMP R1, #1
	ROREQ R5, R5, #24
	CMP R1, #2
	ROREQ R5, R5, #16
	CMP R1, #3
	ROREQ R5, R5, #8
	CMP R1, #3 // check if it is looping the first four hex
	ORRLE R2, R2, R5 // if is, logical OR the current hex with FF
	STRLE R2, [R3] // write to hex
	LDR R2, [R4]
	CMP R1, #4
	ROREQ R5, R5, #0
	CMP R1, #5
	ROREQ R5, R5, #24
	ORR R2, R2, R5
	STR R2, [R4]
	BX LR
 
HEX_clear_ASM:
	PUSH {R1-R8, LR}
	MOV R1, #0 // loop counter

clearloop:
	CMP R1, #6 // check if already iterated all hex
	BEQ done // if is, terminates
	ANDS R7, R0, #1 // and hex parameter with 00000001
	CMP R7, #1 // check if the last bit is 1
	BLEQ clear
	LSR R0, R0, #1 // shift the hex parameter by 1 bit
	ADDS R1, R1, #1 // increment index for hex going to be flooded
	B clearloop // loop back
 
clear:
	LDR R2, [R3] // load hex0_3 address to R2
	MOV R5, #0xFFFFFF00
	CMP R1, #0 // check if index == 0
	ROREQ R5, R5, #0 // rotate by 'index' bits
	CMP R1, #1
	ROREQ R5, R5, #24
	CMP R1, #2
	ROREQ R5, R5, #16
	CMP R1, #3
	ROREQ R5, R5, #8
	CMP R1, #3 // check if it is looping the first four hex
	ANDLE R2, R2, R5 // if is, logical OR the current hex with FF
	STRLE R2, [R3] // write to hex
	LDR R2, [R4]
	CMP R1, #4
	ROREQ R5, R5, #0
	CMP R1, #5
	ROREQ R5, R5, #24
	AND R2, R2, R5
	STR R2, [R4]
	BX LR

done:
	POP {R1-R8, LR}
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

.end
