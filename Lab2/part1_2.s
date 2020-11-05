.global _start

.equ SW_MEMORY, 0xFF200040
.equ LED_MEMORY, 0xFF200000
.equ HEX0_3_BASE, 0xFF200020
.equ HEX4_5_BASE, 0xFF200030
.equ PB_DATA, 0xFF200050
.equ PB_MASK, 0xFF200058
.equ PB_EDGE, 0xFF20005C

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
	//MOV R0, #0x00000004 // pass hex parameter
	//MOV R1, #9
	LDR R3, =HEX0_3_BASE // load HEX0_3
	LDR R4, =HEX4_5_BASE // load HEX4_5

loop:
	BL read_slider_switches_ASM
	BL write_LEDs_ASM
	CMP R0, #0x200
	BEQ clearALL
	BNE else

else:
	MOV R0, #0x00000010
	BL HEX_flood_ASM
	MOV R0, #0x00000020
	BL HEX_flood_ASM
	BL read_slider_switches_ASM
	B checkPB
	
checkPB:
	BL read_PB_edgecp_ASM
	CMP R0, #1
	BLEQ PB_clear_edgecp_ASM
	BLEQ writeHEX0
	
	CMP R0, #2
	BLEQ PB_clear_edgecp_ASM
	BLEQ writeHEX1
	
	CMP R0, #4
	BLEQ PB_clear_edgecp_ASM
	BLEQ writeHEX2
	
	CMP R0, #8
	BLEQ PB_clear_edgecp_ASM
	BLEQ writeHEX3
	

	B loop
	
writeHEX0:
	BL read_slider_switches_ASM
	MOV R1, R0
	MOV R0, #0x00000001
	BL HEX_write_ASM
	B checkPB
	
writeHEX1:
	BL read_slider_switches_ASM
	//BL write_LEDs_ASM
	MOV R1, R0
	MOV R0, #0x00000002
	BL HEX_write_ASM
	B checkPB
	
writeHEX2:
	BL read_slider_switches_ASM
	//BL write_LEDs_ASM
	MOV R1, R0
	MOV R0, #0x00000004
	BL HEX_write_ASM
	B checkPB
	
writeHEX3:
	BL read_slider_switches_ASM
	//BL write_LEDs_ASM
	MOV R1, R0
	MOV R0, #0x00000008
	BL HEX_write_ASM
	B checkPB
	
clearALL:
	MOV R0, #0x00000001
	BL HEX_clear_ASM
	MOV R0, #0x00000002
	BL HEX_clear_ASM
	MOV R0, #0x00000004
	BL HEX_clear_ASM
	MOV R0, #0x00000008
	BL HEX_clear_ASM
	MOV R0, #0x00000010
	BL HEX_clear_ASM
	MOV R0, #0x00000020
	BL HEX_clear_ASM
	B loop
	
read_slider_switches_ASM:
	LDR R1, =SW_MEMORY
    LDR R0, [R1]
    BX LR
	
write_LEDs_ASM:
    LDR R1, =LED_MEMORY
    STR R0, [R1]
    BX  LR
	
HEX_flood_ASM:			

			PUSH {R1-R8,LR}		
			LDR R1, =HEX0_3_BASE	
			MOV R3, #0	
			
floodloop:	CMP R3, #6
			BEQ flooddone
			AND R4, R0, #1
			CMP R4, #1
			BLEQ flood

			LSR R0, R0, #1 	
			ADD R3, R3, #1
			B floodloop

flood:		CMP R3, #3	
			SUBGT R3, R3, #4
			LDRGT R1, =HEX4_5_BASE
			LDR R2, [R1]
			LDR R5, =FLOOD	
			LSL R6, R3, #2
			LDR R5, [R5, R6]
			ORR R2, R2, R5		
			STR R2, [R1]
			BX LR
 
HEX_clear_ASM:
	PUSH {R1-R8,LR}
	LDR R1, =HEX0_3_BASE	// read from 0_3 address
	MOV R3, #0			
			
clearloop:	
	CMP R3, #6			// check if all hex displays are iterated
	BEQ cleardone
	AND R4, R0, #1		
	CMP R4, #1			
	BLEQ clear

	LSR R0, R0, #1 		
	
	ADD R3, R3, #1		// counter++
	B clearloop

clear:		
	CMP R3, #3			
	SUBGT R3, R3, #4	
	LDRGT R1, =HEX4_5_BASE	// read from 4_5 address
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
	ADD R5, R5, R9, LSL #2	// to go to the corresponding address
	
	B writeloop

writeloop:	
	CMP R3, #6			// check if all hex displays are iterated	
	BEQ writedone
	AND R4, R0, #1		
	CMP R4, #1
	BLEQ write

	LSR R0, R0, #1 		
	ADD R3, R3, #1		// counter++
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
	
cleardone:	POP {R1-R8, LR}
			BX LR
			
flooddone:	POP {R1-R8, LR}
			BX LR
			
writedone: POP {R1-R8, LR}
			BX LR

// PUSHBUTTONS

read_PB_data_ASM:
        PUSH {R1, LR}
        LDR R1, =PB_DATA
		LDR R0, [R1]
        POP {R1, LR}
        BX LR

PB_data_is_pressed_ASM:
        PUSH {R1, R2}
        LDR R1, =PB_DATA
        LDR R2, [R1]
		TST R2, R0
		MOVEQ R0, #0
		MOVNE R0, #1
        POP {R1, R2}
        BX LR

read_PB_edgecp_ASM:
        PUSH {R1}
        LDR R1, =PB_EDGE
        LDR R0, [R1]
        POP {R1}
        BX LR

PB_edgecp_is_pressed_ASM:
        PUSH {R1, R2}
        LDR R1, =PB_EDGE
        LDR R2, [R1]
		TST R2, R0
		MOVEQ R0, #0
		MOVNE R0, #1
        POP {R1, R2}
        BX LR

PB_clear_edgecp_ASM:
        PUSH {R1}
        LDR R1, =PB_EDGE
        STR R0, [R1]
        POP {R1}
        BX LR

enable_PB_INT_ASM:
        PUSH {R1, R2}
        LDR R1, =PB_MASK
        LDR R2, [R1]
        ORR R2, R2, R0
        STR R2, [R1]
        POP {R1, R2}
        BX LR

disable_PB_INT_ASM:
        PUSH {R1, R2}
        LDR R1, =PB_MASK
        LDR R2, [R1]
        BIC R2, R2, R0
        STR R2, [R1]
        POP {R1, R2}
        BX LR
	
CLEAR:	.word 0xFFFFFF00
			.word 0xFFFF00FF
			.word 0xFF00FFFF
			.word 0x00FFFFFF
FLOOD:	.word 0x000000FF
			.word 0x0000FF00
			.word 0x00FF0000
			.word 0xFF000000


.end
