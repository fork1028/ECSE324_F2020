.global _start

.equ BASE_ADD, 0xFFFEC600
.equ HEX0_3_BASE, 0xFF200020
.equ HEX4_5_BASE, 0xFF200030
.equ PB_DATA, 0xFF200050
.equ PB_MASK, 0xFF200058
.equ PB_EDGE, 0xFF20005C

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
	LDR R11, =#2000000  // load value 
	LDR R2, =BASE_ADD // make R2 point to the base address
	STR R11, [R2] // pass the load value
	MOV R1, #3 // configuration bits
	MOV R12, #0 // milli loop counter
	MOV R7, #0 // second loop counter
	MOV R8, #0 // minute loop counter
	MOV R9, #0 // start index

//config the timer
ARM_TIM_config_ASM:
	STR R1, [R2, #8] // write the bits to control register
	
loop:
	BL read_PB_edgecp_ASM
	CMP R11, #1 // START is released
	MOVEQ R9, #1 // start the timer
	CMP R11, #2 // STOP is released
	MOVEQ R9, #0 // stop the timer
	BLEQ PB_clear_edgecp_ASM
	CMP R11, #7 // RESET is released
	MOVEQ R9, #0
	MOVEQ R7, #0
	MOVEQ R8, #0
	MOVEQ R12, #0
	BLEQ PB_clear_edgecp_ASM
	BEQ writeTime
	BL ARM_TIM_read_INT_ASM
	CMP R4, #1
	BEQ checkF
	B loop
	
	
checkF:
	MOV R11, #0
	CMP R9, #1 // check if start index is 1
	BNE loop
	BL ARM_TIM_clear_INT_ASM
	ADDS R12, R12, #10 // +10 milliseconds
	B ifmilli
	
ifmilli:
	CMP R12, #1000 // if milli>=1000
	MOVGE R12, #0 // milli = 0
	ADDGE R7, R7, #1 // second++
	B ifsecond
	
ifsecond:
	CMP R7, #60 // if second>=60
	MOVGE R7, #0 // second=0
	ADDGE R8, R8, #1 // minute++
	B ifminute

ifminute:
	CMP R8, #60 // if minute>=60
	MOVGE R8, #0 // minute=0
	B writeTime
	
writeTime:
	
	// hex0
	CMP R12, #0
	MOVEQ R1, #0
	CMP R12, #10
	MOVEQ R1, #1
	CMP R12, #20
	MOVEQ R1, #2
	CMP R12, #30
	MOVEQ R1, #3
	CMP R12, #40
	MOVEQ R1, #4
	CMP R12, #50
	MOVEQ R1, #5
	CMP R12, #60
	MOVEQ R1, #6
	CMP R12, #70
	MOVEQ R1, #7
	CMP R12, #80
	MOVEQ R1, #8
	CMP R12, #90
	MOVEQ R1, #9

		
	CMP R12, #100
	MOVEQ R1, #0
	CMP R12, #110
	MOVEQ R1, #1
	CMP R12, #120
	MOVEQ R1, #2
	CMP R12, #130
	MOVEQ R1, #3
	CMP R12, #140
	MOVEQ R1, #4
	CMP R12, #150
	MOVEQ R1, #5
	CMP R12, #160
	MOVEQ R1, #6
	CMP R12, #170
	MOVEQ R1, #7
	CMP R12, #180
	MOVEQ R1, #8
	CMP R12, #190
	MOVEQ R1, #9
	
	CMP R12, #200
	MOVEQ R1, #0
	CMP R12, #210
	MOVEQ R1, #1
	CMP R12, #220
	MOVEQ R1, #2
	CMP R12, #230
	MOVEQ R1, #3
	CMP R12, #240
	MOVEQ R1, #4
	CMP R12, #250
	MOVEQ R1, #5
	CMP R12, #260
	MOVEQ R1, #6
	LDR R3, =#270
	CMP R12, R3
	MOVEQ R1, #7
	LDR R3, =#280
	CMP R12, R3
	MOVEQ R1, #8
	LDR R3, =#290
	CMP R12, R3
	MOVEQ R1, #9
	
	LDR R3, =#300
	CMP R12, R3
	MOVEQ R1, #0
	LDR R3, =#310
	CMP R12, R3
	MOVEQ R1, #1
	LDR R3, =#320
	CMP R12, R3
	MOVEQ R1, #2
	LDR R3, =#330
	CMP R12, R3
	MOVEQ R1, #3
	LDR R3, =#340
	CMP R12, R3
	MOVEQ R1, #4
	LDR R3, =#350
	CMP R12, R3
	MOVEQ R1, #5
	LDR R3, =#360
	CMP R12, R3
	MOVEQ R1, #6
	LDR R3, =#370
	CMP R12, R3
	MOVEQ R1, #7
	LDR R3, =#380
	CMP R12, R3
	MOVEQ R1, #8
	LDR R3, =#390
	CMP R12, R3
	MOVEQ R1, #9

	LDR R3, =#400
	CMP R12, R3
	MOVEQ R1, #0
	LDR R3, =#410
	CMP R12, R3
	MOVEQ R1, #1
	LDR R3, =#420
	CMP R12, R3
	MOVEQ R1, #2
	LDR R3, =#430
	CMP R12, R3
	MOVEQ R1, #3
	LDR R3, =#440
	CMP R12, R3
	MOVEQ R1, #4
	LDR R3, =#450
	CMP R12, R3
	MOVEQ R1, #5
	LDR R3, =#460
	CMP R12, R3
	MOVEQ R1, #6
	LDR R3, =#470
	CMP R12, R3
	MOVEQ R1, #7
	LDR R3, =#480
	CMP R12, R3
	MOVEQ R1, #8
	LDR R3, =#490
	CMP R12, R3
	MOVEQ R1, #9
	
	LDR R3, =#500
	CMP R12, R3
	MOVEQ R1, #0
	LDR R3, =#510
	CMP R12, R3
	MOVEQ R1, #1
	LDR R3, =#520
	CMP R12, R3
	MOVEQ R1, #2
	LDR R3, =#530
	CMP R12, R3
	MOVEQ R1, #3
	LDR R3, =#540
	CMP R12, R3
	MOVEQ R1, #4
	LDR R3, =#550
	CMP R12, R3
	MOVEQ R1, #5
	LDR R3, =#560
	CMP R12, R3
	MOVEQ R1, #6
	LDR R3, =#570
	CMP R12, R3
	MOVEQ R1, #7
	LDR R3, =#580
	CMP R12, R3
	MOVEQ R1, #8
	LDR R3, =#590
	CMP R12, R3
	MOVEQ R1, #9
	
	LDR R3, =#600
	CMP R12, R3
	MOVEQ R1, #0
	LDR R3, =#610
	CMP R12, R3
	MOVEQ R1, #1
	LDR R3, =#620
	CMP R12, R3
	MOVEQ R1, #2
	LDR R3, =#630
	CMP R12, R3
	MOVEQ R1, #3
	LDR R3, =#640
	CMP R12, R3
	MOVEQ R1, #4
	LDR R3, =#650
	CMP R12, R3
	MOVEQ R1, #5
	LDR R3, =#660
	CMP R12, R3
	MOVEQ R1, #6
	LDR R3, =#670
	CMP R12, R3
	MOVEQ R1, #7
	LDR R3, =#680
	CMP R12, R3
	MOVEQ R1, #8
	LDR R3, =#690
	CMP R12, R3
	MOVEQ R1, #9
	
	LDR R3, =#700
	CMP R12, R3
	MOVEQ R1, #0
	LDR R3, =#710
	CMP R12, R3
	MOVEQ R1, #1
	LDR R3, =#720
	CMP R12, R3
	MOVEQ R1, #2
	LDR R3, =#730
	CMP R12, R3
	MOVEQ R1, #3
	LDR R3, =#740
	CMP R12, R3
	MOVEQ R1, #4
	LDR R3, =#750
	CMP R12, R3
	MOVEQ R1, #5
	LDR R3, =#760
	CMP R12, R3
	MOVEQ R1, #6
	LDR R3, =#770
	CMP R12, R3
	MOVEQ R1, #7
	LDR R3, =#780
	CMP R12, R3
	MOVEQ R1, #8
	LDR R3, =#790
	CMP R12, R3
	MOVEQ R1, #9
	
	LDR R3, =#800
	CMP R12, R3
	MOVEQ R1, #0
	LDR R3, =#810
	CMP R12, R3
	MOVEQ R1, #1
	LDR R3, =#820
	CMP R12, R3
	MOVEQ R1, #2
	LDR R3, =#830
	CMP R12, R3
	MOVEQ R1, #3
	LDR R3, =#840
	CMP R12, R3
	MOVEQ R1, #4
	LDR R3, =#850
	CMP R12, R3
	MOVEQ R1, #5
	LDR R3, =#860
	CMP R12, R3
	MOVEQ R1, #6
	LDR R3, =#870
	CMP R12, R3
	MOVEQ R1, #7
	LDR R3, =#880
	CMP R12, R3
	MOVEQ R1, #8
	LDR R3, =#890
	CMP R12, R3
	MOVEQ R1, #9
	
	LDR R3, =#900
	CMP R12, R3
	MOVEQ R1, #0
	LDR R3, =#910
	CMP R12, R3
	MOVEQ R1, #1
	LDR R3, =#920
	CMP R12, R3
	MOVEQ R1, #2
	LDR R3, =#930
	CMP R12, R3
	MOVEQ R1, #3
	LDR R3, =#940
	CMP R12, R3
	MOVEQ R1, #4
	LDR R3, =#950
	CMP R12, R3
	MOVEQ R1, #5
	LDR R3, =#960
	CMP R12, R3
	MOVEQ R1, #6
	LDR R3, =#970
	CMP R12, R3
	MOVEQ R1, #7
	LDR R3, =#980
	CMP R12, R3
	MOVEQ R1, #8
	LDR R3, =#990
	CMP R12, R3
	MOVEQ R1, #9
	LDR R3, =#1000
	CMP R12, R3
	MOVEQ R1, #0
	
	
	MOV R0, #0x00000001
	BL HEX_write_ASM
	
	// hex1
	CMP R12, #100
	MOVLT R1, #0
	CMP R12, #100
	MOVGE R1, #1
	CMP R12, #200
	MOVGE R1, #2
	CMP R12, #300
	MOVGE R1, #3
	CMP R12, #400
	MOVGE R1, #4
	CMP R12, #500
	MOVGE R1, #5
	CMP R12, #600
	MOVGE R1, #6
	CMP R12, #700
	MOVGE R1, #7
	CMP R12, #800
	MOVGE R1, #8
	CMP R12, #900
	MOVGE R1, #9
	
	MOV R0, #0x00000002
	BL HEX_write_ASM
	
	// hex2
	
	CMP R7, #0
	MOVEQ R1, #0
	CMP R7, #1
	MOVEQ R1, #1
	CMP R7, #2
	MOVEQ R1, #2
	CMP R7, #3
	MOVEQ R1, #3
	CMP R7, #4
	MOVEQ R1, #4
	CMP R7, #5
	MOVEQ R1, #5
	CMP R7, #6
	MOVEQ R1, #6
	CMP R7, #7
	MOVEQ R1, #7
	CMP R7, #8
	MOVEQ R1, #8
	CMP R7, #9
	MOVEQ R1, #9
	
	CMP R7, #10
	MOVEQ R1, #0
	CMP R7, #11
	MOVEQ R1, #1
	CMP R7, #12
	MOVEQ R1, #2
	CMP R7, #13
	MOVEQ R1, #3
	CMP R7, #14
	MOVEQ R1, #4
	CMP R7, #15
	MOVEQ R1, #5
	CMP R7, #16
	MOVEQ R1, #6
	CMP R7, #17
	MOVEQ R1, #7
	CMP R7, #18
	MOVEQ R1, #8
	CMP R7, #19
	MOVEQ R1, #9
	
	CMP R7, #20
	MOVEQ R1, #0
	CMP R7, #21
	MOVEQ R1, #1
	CMP R7, #22
	MOVEQ R1, #2
	CMP R7, #23
	MOVEQ R1, #3
	CMP R7, #24
	MOVEQ R1, #4
	CMP R7, #25
	MOVEQ R1, #5
	CMP R7, #26
	MOVEQ R1, #6
	CMP R7, #27
	MOVEQ R1, #7
	CMP R7, #28
	MOVEQ R1, #8
	CMP R7, #29
	MOVEQ R1, #9
	
	CMP R7, #30
	MOVEQ R1, #0
	CMP R7, #31
	MOVEQ R1, #1
	CMP R7, #32
	MOVEQ R1, #2
	CMP R7, #33
	MOVEQ R1, #3
	CMP R7, #34
	MOVEQ R1, #4
	CMP R7, #35
	MOVEQ R1, #5
	CMP R7, #36
	MOVEQ R1, #6
	CMP R7, #37
	MOVEQ R1, #7
	CMP R7, #38
	MOVEQ R1, #8
	CMP R7, #39
	MOVEQ R1, #9
	
	CMP R7, #40
	MOVEQ R1, #0
	CMP R7, #41
	MOVEQ R1, #1
	CMP R7, #42
	MOVEQ R1, #2
	CMP R7, #43
	MOVEQ R1, #3
	CMP R7, #44
	MOVEQ R1, #4
	CMP R7, #45
	MOVEQ R1, #5
	CMP R7, #46
	MOVEQ R1, #6
	CMP R7, #47
	MOVEQ R1, #7
	CMP R7, #48
	MOVEQ R1, #8
	CMP R7, #49
	MOVEQ R1, #9
	
	CMP R7, #50
	MOVEQ R1, #0
	CMP R7, #51
	MOVEQ R1, #1
	CMP R7, #52
	MOVEQ R1, #2
	CMP R7, #53
	MOVEQ R1, #3
	CMP R7, #54
	MOVEQ R1, #4
	CMP R7, #55
	MOVEQ R1, #5
	CMP R7, #56
	MOVEQ R1, #6
	CMP R7, #57
	MOVEQ R1, #7
	CMP R7, #58
	MOVEQ R1, #8
	CMP R7, #59
	MOVEQ R1, #9
	CMP R7, #60
	MOVEQ R1, #0
	
	
	MOV R0, #0x00000004
	BL HEX_write_ASM

	// hex3
	CMP R7, #0
	MOVGE R1, #0
	CMP R7, #10
	MOVGE R1, #1
	CMP R7, #20
	MOVGE R1, #2
	CMP R7, #30
	MOVGE R1, #3
	CMP R7, #40
	MOVGE R1, #4
	CMP R7, #50
	MOVGE R1, #5
	CMP R7, #60
	MOVGE R1, #0
	
	
	MOV R0, #0x00000008
	BL HEX_write_ASM

	// hex4
	CMP R8, #0
	MOVEQ R1, #0
	CMP R8, #1
	MOVEQ R1, #1
	CMP R8, #2
	MOVEQ R1, #2
	CMP R8, #3
	MOVEQ R1, #3
	CMP R8, #4
	MOVEQ R1, #4
	CMP R8, #5
	MOVEQ R1, #5
	CMP R8, #6
	MOVEQ R1, #6
	CMP R8, #7
	MOVEQ R1, #7
	CMP R8, #8
	MOVEQ R1, #8
	CMP R8, #9
	MOVEQ R1, #9
	CMP R8, #10
	MOVEQ R1, #0
	
	
	MOV R0, #0x00000010
	BL HEX_write_ASM

	// hex5
	CMP R8, #0
	MOVGE R1, #0
	CMP R8, #10
	MOVGE R1, #1
	CMP R8, #20
	MOVGE R1, #2
	CMP R8, #30
	MOVGE R1, #3
	MOV R0, #0x00000020
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
		MOV R11, R0
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
