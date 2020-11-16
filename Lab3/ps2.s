.global _start

.equ PS2_data, 0xFF200100
.equ VGA_pixelbuff, 0xC8000000      // Pixel Buffer
.equ VGA_charbuff, 0xC9000000		// Character Buffer
_start:
        bl      input_loop
end:
        b       end

@ TODO: copy VGA driver here.
VGA_draw_point_ASM:
	PUSH {R3-R12}
	CMP R1, #239
	BXGT LR
	LDR R3, =319				
	CMP R0, R3					
	BXGT LR
	LDR R3, =VGA_pixelbuff		// R3 holds the base address of pixel buffer
	ADD R3, R3, R0, LSL #1		// x coordinate determined
	ADD R3, R3, R1, LSL #10		// y coordinate determined
	STRH R2, [R3]				
	POP {R3-R12}
	BX LR
	

VGA_clear_pixelbuff_ASM:
	PUSH {R4-R12}	
	SUB R0,R0,R0						// X counter
	SUB R2,R2,R2
	LDR R3, =VGA_pixelbuff

X_PIXEL:
	SUB R1,R1,R1						// Y counter
	ADD R4, R3, R0, LSL #1		
Y_PIXEL:
	ADD R5, R4, R1, LSL #10			
	
	STRH R2, [R5]					
	ADD R0, R0, #1					// x counter increment	
	CMP R0, #320					
	BLT X_PIXEL
	ADD R1, R1, #1					// y counter increment
	CMP R1, #240					
	BLT Y_PIXEL				
	POP {R4-R12}
	BX LR

	
	
VGA_write_char_ASM:
	PUSH {R3-R12}
	CMP R1, #59
	BXGT LR
	CMP R0, #79			
	BXGT LR

	LDR R3, =VGA_charbuff		// R3 holds the base address of character buffer
	LSL R1, R1, #7 // adjust offset in y to the correct value (offset in y is specified starting from bit 7)
	ADD R3, R3, R1 // increment in y direction
	ADD R3, R3, R0 // increment in x direction
	STRB R2, [R3]
	POP {R3-R12}
	BX LR
	

VGA_clear_charbuff_ASM:
	PUSH {R4-R12} 
	SUB R0,R0,R0				// x counter				
	SUB R2,R2,R2
	LDR R3, =VGA_charbuff

X_CHAR: 
	SUB R1,R1,R1				// y counter
	ADD R4, R3, R0			

Y_CHAR: 
	ADD R5, R4, R1, LSL #7	
	
	STRB R2, [R5]			
	ADD R0, R0, #1			// x counter increment	
	CMP R0, #80			
	BLT X_CHAR
	ADD R1, R1, #1			// y counter increment
	CMP R1, #60				
	BLT Y_CHAR
	POP {R4-R12}
	BX LR

@ TODO: insert PS/2 driver here.

read_PS2_data_ASM:
	PUSH {R1-R5}
	LDR R4, =PS2_data
	LDR R5, [R4]	
	ANDS R3, R5, #0x8000 
	BNE RETURN  
	MOV R0, #0	
	POP {R1-R5}
	BX LR
	

RETURN: 
	AND R2, R5, #0xFF
	STRB R2, [R0]
	MOV R0, #1
	POP {R1-R5}
	BX LR	
	
write_hex_digit:
        push    {r4, lr}
        cmp     r2, #9
        addhi   r2, r2, #55
        addls   r2, r2, #48
        and     r2, r2, #255
        bl      VGA_write_char_ASM
        pop     {r4, pc}
write_byte:
        push    {r4, r5, r6, lr}
        mov     r5, r0
        mov     r6, r1
        mov     r4, r2
        lsr     r2, r2, #4
        bl      write_hex_digit
        and     r2, r4, #15
        mov     r1, r6
        add     r0, r5, #1
        bl      write_hex_digit
        pop     {r4, r5, r6, pc}
input_loop:
        push    {r4, r5, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      VGA_clear_charbuff_ASM
        mov     r4, #0
        mov     r5, r4
        b       .input_loop_L9
.input_loop_L13:
        ldrb    r2, [sp, #7]
        mov     r1, r4
        mov     r0, r5
        bl      write_byte
        add     r5, r5, #3
        cmp     r5, #79
        addgt   r4, r4, #1
        movgt   r5, #0
.input_loop_L8:
        cmp     r4, #59
        bgt     .input_loop_L12
.input_loop_L9:
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .input_loop_L8
        b       .input_loop_L13
.input_loop_L12:
        add     sp, sp, #12
        pop     {r4, r5, pc}
