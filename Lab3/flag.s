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

@ TODO: copy PS/2 driver here.
read_PS2_data_ASM:
	PUSH {R1-R5}
	LDR R4, =PS2_data
	LDR R5, [R4]	
	ANDS R3, R5, #0x8000 
	BNE VALID
	MOV R0, #0	
	POP {R1-R5}
	BX LR

VALID: 
	AND R2, R5, #0xFF
	STRB R2, [R0]
	MOV R0, #1
	POP {R1-R5}
	BX LR	

@ TODO: adapt this function to draw a real-life flag of your choice.
draw_real_life_flag:
        push    {r3, lr}
		sub		sp, sp, #8
        ldr     r3, .flags_Real
        str     r3, [sp]
        mov     r3, #80
        mov     r2, #320
        mov     r1, #0
        mov     r0, #0
        bl      draw_rectangle
        ldr     r3, .flags_Real+4
        str     r3, [sp]
        mov     r3, #80
        mov     r2, #320
        mov     r1, #80
        mov     r0, #0
        bl      draw_rectangle
		ldr     r3, .flags_Real+8
        str     r3, [sp]
        mov     r3, #80
        mov     r2, #320
        mov     r1, #160
        mov     r0, #0
        bl      draw_rectangle
        add     sp, sp, #8
        pop     {r3, pc}

@ TODO: adapt this function to draw an imaginary flag of your choice.
draw_imaginary_flag:
        push    {r4, lr}
		sub		sp, sp, #8
        ldr     r3, .flags_Imaginary
        str     r3, [sp]
        mov     r3, #240
        mov     r2, #80
        mov     r1, #0
        mov     r0, #0
        bl      draw_rectangle
        ldr     r3, .flags_Imaginary+4
        str     r3, [sp]
        mov     r3, #240
        mov     r2, #80
        mov     r1, #0
        mov     r0, #80
        bl      draw_rectangle
		ldr     r3, .flags_Imaginary+8
        str     r3, [sp]
        mov     r3, #240
        mov     r2, #80
        mov     r1, #0
        mov     r0, #160
        bl      draw_rectangle
		ldr     r3, .flags_Imaginary+12
        str     r3, [sp]
        mov     r3, #240
        mov     r2, #80
        mov     r1, #0
        mov     r0, #240
        bl      draw_rectangle
		ldr     r4, .flags_L32+4
        mov     r3, r4
        mov     r2, #20
        mov     r1, #30
        mov     r0, #40
        bl      draw_star
        str     r4, [sp]
		ldr     r4, .flags_L32+4
        mov     r3, r4
        mov     r2, #20
        mov     r1, #90
        mov     r0, #120
        bl      draw_star
        str     r4, [sp]
		ldr     r4, .flags_L32+4
        mov     r3, r4
        mov     r2, #20
        mov     r1, #150
        mov     r0, #200
        bl      draw_star
        str     r4, [sp]
		ldr     r4, .flags_L32+4
        mov     r3, r4
        mov     r2, #20
        mov     r1, #210
        mov     r0, #280
        bl      draw_star
        str     r4, [sp]
		
        add     sp, sp, #8
        pop     {r4, pc}
		
.flags_Imaginary:
        .word   0xFFFF00
        .word   0xFF00FF
        .word   0xFF69B4
		.word 	45248
		.word	65535

draw_texan_flag:
        push    {r4, lr}
        sub     sp, sp, #8
        ldr     r3, .flags_L32
        str     r3, [sp]
        mov     r3, #240
        mov     r2, #106
        mov     r1, #0
        mov     r0, r1
        bl      draw_rectangle
        ldr     r4, .flags_L32+4
        mov     r3, r4
        mov     r2, #43
        mov     r1, #120
        mov     r0, #53
        bl      draw_star
        str     r4, [sp]
        mov     r3, #120
        mov     r2, #214
        mov     r1, #0
        mov     r0, #106
        bl      draw_rectangle
        ldr     r3, .flags_L32+8
        str     r3, [sp]
        mov     r3, #120
        mov     r2, #214
        mov     r1, r3
        mov     r0, #106
        bl      draw_rectangle
        add     sp, sp, #8
        pop     {r4, pc}
.flags_L32:
        .word   2911
        .word   65535
        .word   45248

draw_rectangle:
        push    {r4, r5, r6, r7, r8, r9, r10, lr}
        ldr     r7, [sp, #32]
        add     r9, r1, r3
        cmp     r1, r9
        popge   {r4, r5, r6, r7, r8, r9, r10, pc}
        mov     r8, r0
        mov     r5, r1
        add     r6, r0, r2
        b       .flags_L2
.flags_L5:
        add     r5, r5, #1
        cmp     r5, r9
        popeq   {r4, r5, r6, r7, r8, r9, r10, pc}
.flags_L2:
        cmp     r8, r6
        movlt   r4, r8
        bge     .flags_L5
.flags_L4:
        mov     r2, r7
        mov     r1, r5
        mov     r0, r4
        bl      VGA_draw_point_ASM
        add     r4, r4, #1
        cmp     r4, r6
        bne     .flags_L4
        b       .flags_L5
should_fill_star_pixel:
        push    {r4, r5, r6, lr}
        lsl     lr, r2, #1
        cmp     r2, r0
        blt     .flags_L17
        add     r3, r2, r2, lsl #3
        add     r3, r2, r3, lsl #1
        lsl     r3, r3, #2
        ldr     ip, .flags_L19
        smull   r4, r5, r3, ip
        asr     r3, r3, #31
        rsb     r3, r3, r5, asr #5
        cmp     r1, r3
        blt     .flags_L18
        rsb     ip, r2, r2, lsl #5
        lsl     ip, ip, #2
        ldr     r4, .flags_L19
        smull   r5, r6, ip, r4
        asr     ip, ip, #31
        rsb     ip, ip, r6, asr #5
        cmp     r1, ip
        bge     .flags_L14
        sub     r2, r1, r3
        add     r2, r2, r2, lsl #2
        add     r2, r2, r2, lsl #2
        rsb     r2, r2, r2, lsl #3
        ldr     r3, .flags_L19+4
        smull   ip, r1, r3, r2
        asr     r3, r2, #31
        rsb     r3, r3, r1, asr #5
        cmp     r3, r0
        movge   r0, #0
        movlt   r0, #1
        pop     {r4, r5, r6, pc}
.flags_L17:
        sub     r0, lr, r0
        bl      should_fill_star_pixel
        pop     {r4, r5, r6, pc}
.flags_L18:
        add     r1, r1, r1, lsl #2
        add     r1, r1, r1, lsl #2
        ldr     r3, .flags_L19+8
        smull   ip, lr, r1, r3
        asr     r1, r1, #31
        sub     r1, r1, lr, asr #5
        add     r2, r1, r2
        cmp     r2, r0
        movge   r0, #0
        movlt   r0, #1
        pop     {r4, r5, r6, pc}
.flags_L14:
        add     ip, r1, r1, lsl #2
        add     ip, ip, ip, lsl #2
        ldr     r4, .flags_L19+8
        smull   r5, r6, ip, r4
        asr     ip, ip, #31
        sub     ip, ip, r6, asr #5
        add     r2, ip, r2
        cmp     r2, r0
        bge     .flags_L15
        sub     r0, lr, r0
        sub     r3, r1, r3
        add     r3, r3, r3, lsl #2
        add     r3, r3, r3, lsl #2
        rsb     r3, r3, r3, lsl #3
        ldr     r2, .flags_L19+4
        smull   r1, ip, r3, r2
        asr     r3, r3, #31
        rsb     r3, r3, ip, asr #5
        cmp     r0, r3
        movle   r0, #0
        movgt   r0, #1
        pop     {r4, r5, r6, pc}
.flags_L15:
        mov     r0, #0
        pop     {r4, r5, r6, pc}
.flags_L19:
        .word   1374389535
        .word   954437177
        .word   1808407283
.flags_Real:
		.word   0x000000
		.word 	45248
		.word	0xFFFF00
		
draw_star:
        push    {r4, r5, r6, r7, r8, r9, r10, fp, lr}
        sub     sp, sp, #12
        lsl     r7, r2, #1
        cmp     r7, #0
        ble     .flags_L21
        str     r3, [sp, #4]
        mov     r6, r2
        sub     r8, r1, r2
        sub     fp, r7, r2
        add     fp, fp, r1
        sub     r10, r2, r1
        sub     r9, r0, r2
        b       .flags_L23
.flags_L29:
        ldr     r2, [sp, #4]
        mov     r1, r8
        add     r0, r9, r4
        bl      VGA_draw_point_ASM
.flags_L24:
        add     r4, r4, #1
        cmp     r4, r7
        beq     .flags_L28
.flags_L25:
        mov     r2, r6
        mov     r1, r5
        mov     r0, r4
        bl      should_fill_star_pixel
        cmp     r0, #0
        beq     .flags_L24
        b       .flags_L29
.flags_L28:
        add     r8, r8, #1
        cmp     r8, fp
        beq     .flags_L21
.flags_L23:
        add     r5, r10, r8
        mov     r4, #0
        b       .flags_L25
.flags_L21:
        add     sp, sp, #12
        pop     {r4, r5, r6, r7, r8, r9, r10, fp, pc}
input_loop:
        push    {r4, r5, r6, r7, lr}
        sub     sp, sp, #12
        bl      VGA_clear_pixelbuff_ASM
        bl      draw_texan_flag
        mov     r6, #0
        mov     r4, r6
        mov     r5, r6
        ldr     r7, .flags_L52
        b       .flags_L39
.flags_L46:
        bl      draw_real_life_flag
.flags_L39:
        strb    r5, [sp, #7]
        add     r0, sp, #7
        bl      read_PS2_data_ASM
        cmp     r0, #0
        beq     .flags_L39
        cmp     r6, #0
        movne   r6, r5
        bne     .flags_L39
        ldrb    r3, [sp, #7]    @ zero_extendqisi2
        cmp     r3, #240
        moveq   r6, #1
        beq     .flags_L39
        cmp     r3, #28
        subeq   r4, r4, #1
        beq     .flags_L44
        cmp     r3, #35
        addeq   r4, r4, #1
.flags_L44:
        cmp     r4, #0
        blt     .flags_L45
        smull   r2, r3, r7, r4
        sub     r3, r3, r4, asr #31
        add     r3, r3, r3, lsl #1
        sub     r4, r4, r3
        bl      VGA_clear_pixelbuff_ASM
        cmp     r4, #1
        beq     .flags_L46
        cmp     r4, #2
        beq     .flags_L47
        cmp     r4, #0
        bne     .flags_L39
        bl      draw_texan_flag
        b       .flags_L39
.flags_L45:
        bl      VGA_clear_pixelbuff_ASM
.flags_L47:
        bl      draw_imaginary_flag
        mov     r4, #2
        b       .flags_L39
.flags_L52:
        .word   1431655766
