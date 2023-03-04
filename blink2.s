/* This program blinks the led embedded in the blue pill board. The led is
 * attached to pin PC13. This pin works as a GPIO, then it must be configured,
 * at assembly level, through the following registers:
 * 1) RCC register,
 * 2) GPIOC_CRL register, 
 * 3) GPIOC_CRH register, and
 * 4) GPIOC_ODR register.
 * 
 * Author: A. Geovanni Medrano-Chávez.
 * The following code is based on the explanation given in this video:
 * https://www.youtube.com/watch?v=KLWzyhOR3-Y,
 */

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

	ldr 	r0, =GPIOB_CRL
	ldr 	r3, =0x33344333
	str	r3, [r0]
	
	ldr 	r0, =GPIOB_CRH
	ldr 	r3, =0x33333333
	str	r3, [r0]
	
	@ #44444443 = 0100 0100 0100 0100 0100 0100 0100 1000
	ldr	r0, =GPIOA_CRL
	ldr	r3, =0x88888888
	str	r3, [r0]
	
        # set led status initial value
        ldr     r0, =GPIOC_ODR @ moves address of GPIOC_ODR register to r0
        ldr     r7, =GPIOB_ODR
	ldr	r8, =GPIOA_IDR
        mov     r1, 0x0

loop:   
	ldr	r5, [r8]
	mov	r3, 0x0
	and	r5, r5, #1
	cmp	r5, 0x0
	bne	L2 
	ldr	r5, [r8]	
	mov	r4, r5
	mov	r3, 0xFFFF
L2:	str	r3, [r0]
	str     r4, [r7]
L4:     sub     r2, r2, #1
L3:     cmp     r2, #0
        bge     L4
        eor     r1, #1 @ negates LSB of r1
        b       loop
