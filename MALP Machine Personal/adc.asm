; adc.asm
;
; Created: 10/19/2022 1:30:00 PM
; Author : Jordan Steele


initADC:
	ldi		r24,1<<REFS0			; Sets the REFS0 to 1 for 5V vref
	sts		ADMUX,r24
	ldi		r24,0x87			; Enable ADC and select clock/128
	sts		ADCSRA,r24
	ret
	
; Channel to read in r24,value returned in r24,r25
readADCch:
	ldi		r30,ADMUX
	ldi		r31,0x00
	ld		r25,Z
	andi		r24,0x07		; makes sure channel 0-7
	andi		r25,0xF8		; clears bottom 3 bits before OR
	or		r24,r25
	st		Z,r24
	ldi		r30,ADCSRA		; trigger the conversion.
	ldi		r31,0x00
	ld		r24,Z
	ori		r24,0x40
	st		Z,r24
poll:
	ld		r24,Z
	sbrc		r24,6			; Loop until conversion complete
	jmp		poll
	lds		r24,ADCL		; Read low and high byte
	lds		r25,ADCH
	ret

  ; Channel to read in r26,value returned in r26,r27
readADCchY:
	ldi		r30,ADMUX
	ldi		r31,0x00
	ld		r27,Z
	andi		r26,0x07		; makes sure channel 0-7
	andi		r27,0xF8		; clears bottom 3 bits before OR
	or		r26,r27
	st		Z,r26
	ldi		r30,ADCSRA		; trigger the conversion.
	ldi		r31,0x00
	ld		r26,Z
	ori		r26,0x40
	st		Z,r26
pollY:
	ld		r26,Z
	sbrc		r26,6			; Loop until conversion complete
	jmp		poll
	lds		r26,ADCL		; Read low and high byte
	lds		r27,ADCH
	ret
