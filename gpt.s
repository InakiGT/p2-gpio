.include "gpio.inc" @ Includes definitions from gpio.inc file

.thumb              @ Assembles using thumb mode
.cpu cortex-m3      @ Generates Cortex-M3 instructions
.syntax unified

.include "nvic.inc"

setup:
        # enabling clock in port C
        ldr     r0, =RCC_APB2ENR @ move 0x40021018 to r0
        mov     r3, 0x1C @ loads 16 in r1 to enable clock in port C (IOPC bit)
        str     r3, [r0] @ M[RCC_APB2ENR] gets 16

        # reset pin 0 to 7 in GPIOC_CRL
        ldr     r0, =GPIOC_CRL @ moves address of GPIOC_CRL register to r0
        ldr     r3, =0x44444444 @ this constant signals the reset state
        str     r3, [r0] @ M[GPIOC_CRL] gets 0x44444444

        # reset pin 0 to 7 in GPIOB_CRH
        ldr     r0, =GPIOB_CRH @ moves address of GPIOC_CRL register to r0
        ldr     r3, =0x44444444 @ this constant signals the reset state
        str     r3, [r0] @ M[GPIOC_CRL] gets 0x44444444

        # set pin 13 as digital output
        ldr     r0, =GPIOC_CRH @ moves address of GPIOC_CRH register to r0
        @ 0100 0100 0011 0100 0100 0100 0100 0100
        ldr     r3, =0x33333333
 @ PC13: output push-pull, max speed 50 MHz, 
        str     r3, [r0] @ M[GPIOC_CRH] gets 0x44344444

        ldr     r0, =GPIOB_CRL
        ldr     r3, =0x33344333
        str     r3, [r0]

        ldr     r0, =GPIOB_CRH
        ldr     r3, =0x33333333
        str     r3, [r0]

        @ #44444443 = 0100 0100 0100 0100 0100 0100 0100 1000
        ldr     r0, =GPIOA_CRL
        ldr     r3, =0x88888888
        str     r3, [r0]

        # set led status initial value
        ldr     r0, =GPIOC_ODR @ moves address of GPIOC_ODR register to r0
        mov	r4, #0x0
	str	r4, [r0]
	ldr     r7, =GPIOB_ODR
	mov	r4, #0xFFFF
	str	r7, [r4] 
        ldr     r8, =GPIOA_IDR
reset_count:
	mov	r2, #0x0
loop:
    	@; Comprueba si el push button A0 está siendo presionado
    	ldr r0, =GPIOA_IDR
    	ldr r1, [r0]
    	and r1, r1, #0x01
    	cmp r1, 0x0
    	beq inc_count     @; Si el push button A0 está siendo presionado, salta a la etiqueta "inc_count"
    
    	@; Comprueba si el push button A4 está siendo presionado
    	ldr r0, =GPIOA_IDR
    	ldr r1, [r0]
    	and r1, r1, #0x10
    	cmp r1, #0
    	beq dec_count     @; Si el push button A4 está siendo presionado, salta a la etiqueta "dec_count"

    	@; Si ninguno de los botones está siendo presionado, sigue leyendo el valor de los botones
	b loop

inc_count:
    	@; Incrementa el contador
    	add r2, r2, #1
    	cmp r2, #10
    	bgt reset_count   @; Si el contador supera el valor 10, salta a la etiqueta "reset_count"
    
    	@; Enciende los LEDs correspondientes al contador actual
    	ldr r0, =GPIOB_ODR
    	mov r1, r2
    	lsl r1, r1, #16
    	str r1, [r0]     @; Escribe el valor del contador en los bits 0-9 del registro GPIOB_BSRR para encender los LEDs correspondientes
    	b loop

dec_count:
   	 @; Decrementa el contador
    	sub r2, r2, #1
    	cmp r2, #-1
    	blt reset_count   @; Si el contador es menor que 0, salta a la etiqueta "reset_count"

    @@; Enciende los LEDs correspondientes al contador actual
    	ldr r0, =GPIOB_ODR
    	mov r1, r2
    	lsl r1, r1, #16

	@; Escribe el valor del contador en los bits 0-9 del registro GPIOB_BSRR para encender los LEDs correspondientes
	mov r3, #0x03FF
	and r1, r1, r3
	lsl r1, r1, #16
	str r1, [r0]
	b loop

	@; Apaga todos los LEDs
	ldr r0, =GPIOB_ODR
	mov r1, #0x0000
	str r1, [r0]
	b loop


