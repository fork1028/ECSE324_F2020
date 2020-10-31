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
			
Flood_Loop:	CMP R3, #6
			BEQ Flood_DONE
			AND R4, R0, #1
			CMP R4, #1
			BLEQ Flood

			LSR R0, R0, #1 	
			ADD R3, R3, #1
			B Flood_Loop

Flood:		CMP R3, #3	
			SUBGT R3, R3, #4
			LDRGT R1, =HEX4_5_BASE
			LDR R2, [R1]
			LDR R5, =FLOOD_N	// Difference here: Sets R5 to FLOOD_N variable which is the inverse of CLEAR_N
			LSL R6, R3, #2
			LDR R5, [R5, R6]
			ORR R2, R2, R5		// Difference here: We use ORR to OR R2 and R5. This will turn on all the segments at that particular hex since everything else is Zeros.
			STR R2, [R1]
			BX LR
 
HEX_clear_ASM:
	PUSH {R1-R8,LR}
	LDR R1, =HEX0_3_BASE	// Set R1 to HEX0-3 address
	MOV R3, #0			// Index of which hex we're at
			
clearloop:	
	CMP R3, #6			// Check if when we're done iterating
	BEQ Clear_DONE
	AND R4, R0, #1		// Checks if the bit we're at is hot encoded
	CMP R4, #1			// If yes, go to Clear (This branch clears the hex)
	BLEQ clear

	LSR R0, R0, #1 		// Shift the input right by 1 bit since the inputs is hot encoded
	// So we move on to the next bit to check if that value (HEX) is 1 on line 19
	ADD R3, R3, #1		// Increment counter (index)
	B clearloop

clear:		
	CMP R3, #3			// Check if we're at the HEX 4 or 5
	SUBGT R3, R3, #4	// Sets the counter to 0 or 1 when it's > 3 (the counter refers to HEX 4-5 when it's 0-1 after this is called)
	LDRGT R1, =HEX4_5_BASE	// Set it to the the other disp HEX
	LDR R2, [R1]		// Set R2 to address of HEX 4-5
	LDR R5, =CLEAR_N	// Sets R5 to Clear_N variable
	LSL R6, R3, #2		// Multiply R3 with 4
	LDR R5, [R5, R6]	// Load R5 with the value at =Light + offset (R3*4)
	// This mimicks the Rotate Left method that doesn't exist
	AND R2, R2, R5		// AND R5 with the current HEX value to clear that particular HEX
	STR R2, [R1]		// Store the result to change it physically
	BX LR
	
HEX_write_ASM:	
	MOV R10, R0				// Store copy of R0 (HEX_t)
	MOV R9, R1				// Store copy of R1 (char val)		
	PUSH {R2-R8,LR}
	BL HEX_clear_ASM		// Clear the HEX displays before writing to it
	POP {R2-R8,LR}	
	
	MOV R0, R10				// Restore the initial value of R0 before the clear

	PUSH {R1-R8,LR}
	LDR R1, =HEX0_3_BASE		// Load location of the HEX0-3 into R1
	MOV R3, #0				// Counter for HEX count
	LDR R5, =NUM			// Set R5 to the first address of LIGHTS var (i.e address of .word 0x0000003F)
	ADD R5, R5, R9, LSL #2	// From that address, add R9 (the HEX LED value we want to put) * 4 (must increment by multiples of 4 since words are 4bytes)
	// This makes R5 point the HEX value that we want inject
	B writeloop

writeloop:	
	CMP R3, #6			// Checks when we're done iterating		
	BEQ Write_DONE
	AND R4, R0, #1		// Checks if the HEX needs to be written with One hot encoded bit
	CMP R4, #1
	BLEQ write

	LSR R0, R0, #1 		// Shift the input right by 1 bit since the input is one hot encoded
	// So we move on to the next bit to check if that value (HEX) is 1
	ADD R3, R3, #1		// Increment counter
	B writeloop

write:		
	CMP R3, #3			// Check if we're at the HEX 4 or 5
	SUBGT R3, R3, #4	// Sets the counter to 0 or 1 when it's > 3 (the counter refers to HEX 4-5 when it's 0-1 after this is called)
	LDRGT R1, =HEX4_5_BASE	// Set it to the the other disp HEX
	LDR R2, [R1]		// Set R2 to the value of R1 to get the value of the hex at that time
	LDR R7, [R5]		// Set R7 to the proper HEX LED value (e.g. 0x0000004F = 3 in HEX LED)
	LSL R6, R3, #3		// Multiply the counter by 2^3 (8 bits)
	LSL R7, R7, R6		// Shift the HEX LED value to the proper HEX using the counter multiplied by 8 (e.g 0x0000004F -> 0x004F0000)
	ORR R2, R2, R7		// OR the current HEX values of the board with R7 to write the HEX value onto that HEX address
	STR R2, [R1]		// Store the new HEX values to the address. This effectively changes the HEX on the board
	BX LR
	
Clear_DONE:	POP {R1-R8, LR}
			BX LR
			
Flood_DONE:	POP {R1-R8, LR}
			BX LR
			
Write_DONE: POP {R1-R8, LR}
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
	
CLEAR_N:	.word 0xFFFFFF00
			.word 0xFFFF00FF
			.word 0xFF00FFFF
			.word 0x00FFFFFF
FLOOD_N:	.word 0x000000FF
			.word 0x0000FF00
			.word 0x00FF0000
			.word 0xFF000000


.end
