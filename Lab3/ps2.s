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

@ TODO: insert PS/2 driver here.
read_PS2_data_ASM:
	PUSH {R1-R5}
	LDR R4, =PS2_data // points to the PS2_DATA address
	LDR R5, [R4]   // load the contents to R5
	LSR R3, R5, #15  // (*(volatile int *)0xff200100) >> 15)
	ANDS R3, R3, #0x1  // ((*(volatile int *)0xff200100) >> 15) & 0x1
	CMP R3, #0  // compare the RVALID bit to be 0/1
	BNE VALID
	MOV R0, #0    // if invalid, return 0
	POP {R1-R5}
	BX LR
 

VALID: 
	AND R2, R5, #0xFF
	STRB R2, [R0]
	MOV R0, #1  // return 1
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
