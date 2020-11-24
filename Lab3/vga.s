.global _start

.equ VGA_pixelbuff, 0xC8000000      // Pixel Buffer
.equ VGA_charbuff, 0xC9000000		// Character Buffer

_start:
	bl draw_test_screen
end:
 	b end

@ TODO: Insert VGA driver functions here.
VGA_draw_point_ASM:
	PUSH {R3-R12}
	CMP R1, #239 // check if y exceeds 240 height
	BXGT LR 
	LDR R3, =319	// load 319 immediate value to r3			
	CMP R0, R3		// check if x exceeds 320 width
	BXGT LR
	LDR R3, =VGA_pixelbuff		// R3 points to the base address of pixel buffer
	ADDS R3, R3, R0, LSL #1		// x coordinate determined x<<1
	ADDS R3, R3, R1, LSL #10		// y coordinate determined y<<10
	STRH R2, [R3]				// R2 stores the char
	POP {R3-R12}
	BX LR
	

VGA_clear_pixelbuff_ASM:
	PUSH {R4-R12}	
	SUBS R0, R0, R0					// clear x
	SUBS R2, R2, R2					// clear c
	LDR R3, =VGA_pixelbuff

ClearXPixel:
	SUBS R1, R1, R1					// clear y
	ADDS R4, R3, R0, LSL #1			// x<<1
ClearYPixel:
	ADDS R5, R4, R1, LSL #10			// y<<10
	
	STRH R2, [R5]					// clear the content at y coordinate
	ADDS R0, R0, #1					// x++
	CMP R0, #320					// check if x exceeds 320 pixels
	BLT ClearXPixel					
	ADDS R1, R1, #1					// y++
	CMP R1, #240					// check if y exceeds 240 pixels
	BLT ClearYPixel			
	POP {R4-R12}
	BX LR

	
	
VGA_write_char_ASM:
	PUSH {R3-R12}
	CMP R1, #59  // check if y exceeds 60 pixels
	BXGT LR
	CMP R0, #79	  // check if x exceeds 80 pixels
	BXGT LR
	LDR R3, =VGA_charbuff		// R3 points to base address of character buffer
	ADDS R3, R3, R0				// x coordinate determined x
	ADDS R3, R3, R1, LSL #7		// y coordinate determined y<<7
	STRB R2, [R3]			// write R2 to the address	
	POP {R3-R12}
	BX LR
	

VGA_clear_charbuff_ASM:
	PUSH {R4-R12} 
	SUBS R0, R0, R0				// clear x
	SUBS R2, R2, R2				// clear c
	LDR R3, =VGA_charbuff

ClearXChar: 
	SUBS R1,R1,R1				// clear y
	ADDS R4, R3, R0				// x

ClearYChar: 
	ADDS R5, R4, R1, LSL #7		// y<<7
	STRB R2, [R5]			// clear the content at y coordinate
	ADDS R0, R0, #1			// x++
	CMP R0, #80				// check if x exceeds 80 pixels
	BLT ClearXChar				
	ADDS R1, R1, #1			// y++
	CMP R1, #60				// check if y exceeds 60 pixels
	BLT ClearYChar
	POP {R4-R12}
	BX LR

	

draw_test_screen:
	push    {r4, r5, r6, r7, r8, r9, r10, lr}
	bl      VGA_clear_pixelbuff_ASM
	bl      VGA_clear_charbuff_ASM
	mov     r6, #0
	ldr     r10, .draw_test_screen_L8
	ldr     r9, .draw_test_screen_L8+4
	ldr     r8, .draw_test_screen_L8+8
	b       .draw_test_screen_L2
.draw_test_screen_L7:
	add     r6, r6, #1
	cmp     r6, #320
	beq     .draw_test_screen_L4
.draw_test_screen_L2:
	smull   r3, r7, r10, r6
	asr     r3, r6, #31
	rsb     r7, r3, r7, asr #2
	lsl     r7, r7, #5
	lsl     r5, r6, #5
	mov     r4, #0
.draw_test_screen_L3:
	smull   r3, r2, r9, r5
	add     r3, r2, r5
	asr     r2, r5, #31
	rsb     r2, r2, r3, asr #9
	orr     r2, r7, r2, lsl #11
	lsl     r3, r4, #5
	smull   r0, r1, r8, r3
	add     r1, r1, r3
	asr     r3, r3, #31
	rsb     r3, r3, r1, asr #7
	orr     r2, r2, r3
	mov     r1, r4
	mov     r0, r6
	bl      VGA_draw_point_ASM
	add     r4, r4, #1
	add     r5, r5, #32
	cmp     r4, #240
	bne     .draw_test_screen_L3
	b       .draw_test_screen_L7
.draw_test_screen_L4:
	mov     r2, #72
	mov     r1, #5
	mov     r0, #20
	bl      VGA_write_char_ASM
	mov     r2, #101
	mov     r1, #5
	mov     r0, #21
	bl      VGA_write_char_ASM
	mov     r2, #108
	mov     r1, #5
	mov     r0, #22
	bl      VGA_write_char_ASM
	mov     r2, #108
	mov     r1, #5
	mov     r0, #23
	bl      VGA_write_char_ASM
	mov     r2, #111
	mov     r1, #5
	mov     r0, #24
	bl      VGA_write_char_ASM
	mov     r2, #32
	mov     r1, #5
	mov     r0, #25
	bl      VGA_write_char_ASM
	mov     r2, #87
	mov     r1, #5
	mov     r0, #26
	bl      VGA_write_char_ASM
	mov     r2, #111
	mov     r1, #5
	mov     r0, #27
	bl      VGA_write_char_ASM
	mov     r2, #114
	mov     r1, #5
	mov     r0, #28
	bl      VGA_write_char_ASM
	mov     r2, #108
	mov     r1, #5
	mov     r0, #29
	bl      VGA_write_char_ASM
	mov     r2, #100
	mov     r1, #5
	mov     r0, #30
	bl      VGA_write_char_ASM
	mov     r2, #33
	mov     r1, #5
	mov     r0, #31
	bl      VGA_write_char_ASM
	pop     {r4, r5, r6, r7, r8, r9, r10, pc}
.draw_test_screen_L8:
	.word   1717986919
	.word   -368140053
	.word   -2004318071
