;
; util.asm
;
; Created: 9/28/2022 3:00:00 PM
; Modified: 02/27/2025 1:15:00 PM
; Author : Jordan Steele

; This file contains utility functions including delays, number-to-ASCII conversions,
; and division routines. It includes a 100 ms delay, a 1-second delay, conversion of
; packed BCD to ASCII, byte-to-hexadecimal conversion, and functions for dividing
; 16-bit and 8-bit numbers.


; 100 ms Delay
delay100ms:
	ldi	r18, 0xFF		; 255
	ldi	r24, 0x80		; 128
	ldi	r25, 0x04		; 4
d100:

	subi	r18, 0x01		; 1
	sbci	r24, 0x00		; 0
	sbci	r25, 0x00		; 0
	brne	d100
	ret
	
	; Packed BCD To ASCII
; Number to convert in r17
; Converted output in r17 (upper nibble),r18 (lower nibble)
pBCDToASCII:
	mov r18, r17 ; save a copy
	andi r18, 0b00001111 ; mask the upper nibble
	ori r18, 0x30 ; converet to ASCII
	swap r17 ; swap nibbles
	andi r17, 0x0F ; mask the upper nibble
	ori r17, 0x30 ; convert to ascii
	ret


; Byte To Hexadecimal ASCII
; Number to convert in r17
; Converted output in r17 (lower nibble),r18 (upper nibble)
byteToHexASCII:
	mov r18, r17; save a copy
	andi r17, 0x0f ; mask the upper nibble
	ldi r16, 0x30 ; index to '0'
	cpi r17, 10 
	brlo b1
	ldi r16, 0x37; index to 'A'
b1: add r17,r16
	swap r18 ; look at the upper nibble
	andi r18, 0x0f ; mask the upper nibble
	ldi r16, 0x30 ; index to '0'
	cpi r18, 10 ; greater than 9?
	brlo b2
	ldi r16, 0x37 ; index to 'A'
b2: add r18,r16
	ret

; Converts unsigned integer value of r17:r16 to ASCII string tascii[5]
itoa_short:
	ldi	zl,low(dectab*2)	; pointer to 10^x power compare value
	ldi	zh,high(dectab*2)
	ldi	xl,low(tascii)	; pointer to array to store string
	ldi	xh,high(tascii)
itoa_lext:
	ldi	r18,'0'-1		; (ASCII 0) -1
	lpm	r2,z+			; load 10^x word, point to next
	lpm	r3,z+
itoa_lint:
	inc	r18			; start with '0' ASCII
	sub	r16,r2			; (## - 10^x
	sbc	r17,r3
	brsh	itoa_lint
	add	r16,r2			; if negative reconstruct
	adc	r17,r3
	st	x+,r18			; save 1/10^x count, point to next location to save
	lpm				; read last ZX pointed at from 10^x table in (r0)
	tst	r0                  ; LAST WORD YET?=0x00
brne	itoa_lext
	ret

dectab:	.dw	10000,1000,100,10,1,0


; 1 Second Delay
delay1s:
	ldi	   r20,64
d1:	ldi	   r21,200
d2:	ldi	   r22,250
d3:	nop
	nop
	dec	   r22
	brne   d3
	dec	   r21
	brne   d2
	dec	   r20
	brne   d1
	ret

; 0.25 Second Delay
delay0.25s:
	ldi	   r20,8
d4:	ldi	   r21,200
d5:	ldi	   r22,250
d6:	nop
	nop
	dec	   r22
	brne   d6
	dec	   r21
	brne   d5
	dec	   r20
	brne   d4
	ret

; 0.10 Second Delay
delay0.1s:
	ldi	   r20,3
d7:	ldi	   r21,200
d8:	ldi	   r22,250
d9:	nop
	nop
	dec	   r22
	brne   d9
	dec	   r21
	brne   d8
	dec	   r20
	brne   d7
	ret
	
	
.def ANSL = R0		;To hold low-byte of answer
.def ANSH = R1		;To hold high-byte of answer     
.def REML = R2		;To hold low-byte of remainder
.def REMH = R3		;To hold high-byte of remainder
.def   AL = R16		;To hold low-byte of dividend
.def   AH = R17		;To hold high-byte of dividend
.def   BL = R18		;To hold low-byte of divisor
.def   BH = R19		;To hold high-byte of divisor   
.def  C16 = R20		;Bit Counter


div1616:
	movw	ANSH:ANSL,AH:AL	;Copy dividend into answer
	ldi	C16,17		;Load bit counter
	sub	REML,REML	;Clear Remainder and Carry
	clr	REMH          
dloop:	rol	ANSL		;Shift the answer to the left
	rol	ANSH          
	dec	C16		;Decrement Counter
	breq	ddone		;Exit if sixteen bits done
	rol	REML		;Shift remainder to the left
	rol	REMH          
	sub	REML,BL		;Try to subtract divisor from remainder
	sbc	REMH,BH
	brcc	skip		;If the result was negative then
	add	REML,BL		;reverse the subtraction to try again
	adc	REMH,BH
	clc			;Clear Carry Flag so zero shifted into A 
	rjmp	dloop		;Loop Back
skip:	sec			;Set Carry Flag to be shifted into A
	rjmp	dloop
ddone:	ret


; Divide two 8-bit numbers
; r0 holds answer
; r2 holds remainder
; r16 holds dividend
; r18 holds divisor
; r20 Bit Counter
div88:
	ldi	r20,9	; Load bit counter
	sub	r2,r2	; Clear remainder and Carry
	mov	r0,r16	; Copy dividend to answer
loopd8:
	rol	r0	; Shift answer to left
	dec	r20	; Decrement counter
	breq	doned8	; Exit if eight bits done
	rol	r2	; Shift remainder to the left
	sub	r2,r18	; Try to subtract the divsor from remainder
	brcc	skipd8	; If result was negative then
	add	r2,r18	; reverse subtraction to try again
	clc		; Clear Carry flag so zero shifted into A
	rjmp	loopd8
skipd8:
	sec		; Set Carry flag to be shifted into A
	rjmp	loopd8
doned8:
	ret
