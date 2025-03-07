; andisplay.asm
;
; Created: 11/02/2022 12:00:00 PM
; Author : Jordan Steele

; This file initializes and controls an alphanumeric display using the HT16K33 driver via I2C.

.equ ANI2CADR		= 0xe0
.equ ANON		= 0x21
.equ ANSTANDBY		= 0x20
.equ ANDISPON		= 0x81
.equ ANDISPOFF		= 0x80
.equ ANBLINKON		= 0x85
.equ ANBLINKOFF		= 0x81
.equ ANDIM		= 0xe5
.equ ANBLINKCMD		= 0x80
.equ ANBLINKDISPON	= 0x01
.equ ANBLINKROFF		= 0
.equ ANBLINK2HZ		= 1
.equ ANBLINK1HZ		= 2
.equ ANBLINKHHZ		= 3
.equ ANBRIGHTCMD		= 0xe0

;	Alphanumeric Display Initialization
initAN:
	ldi	r23,ANI2CADR		; HT16K33 I2C Address
	call	i2cStart
	ldi	r24,ANON
	call	i2cWrite
	call	i2cStop
	call	i2cStart
	ldi	r24,ANDISPON
	call	i2cWrite
	call	i2cStop
	call	i2cStart
	ldi	r24,ANDIM
	call	i2cWrite
	call	i2cStop
	ldi	r16, ' '
	ldi	r17,0
	call	anWriteDigit
	ldi	r16, ' '
	ldi	r17,1
	call	anWriteDigit
	ldi	r16, ' '
	ldi	r17,2
	call	anWriteDigit
	ldi	r16, ' '
	ldi	r17,3
	call	anWriteDigit
	ret

	;Write Digit - ASCII Character in r16, Digit to write in r17
anWriteDigit:
	ldi	ZL,LOW(alphatable*2)		; Low byte of alphatable address
	ldi	ZH,HIGH(alphatable*2)	; High byte
	subi	r16,' '
	lsl	r16
	add	ZL,r16
	ldi	r16,0
	adc	ZH,r16
	lpm	r18,Z+
	lpm	r19,Z
	ldi	r23,ANI2CADR	; HT16K33 I2C Address
	call	i2cStart
	mov	r24,r17			; Get digit to write
	add	r24,r24			; Set up digit register
	call	i2cWrite
	mov	r24,r18
	call	i2cWrite
	mov	r24,r19
	call	i2cWrite
	call	i2cStop
	ret

alphatable:
.dw 0b0000000000000000	; Blank  
.dw 0b0000000000000110	; !
.dw 0b0000001000100000	; "
.dw 0b0001001011001110	; #
.dw 0b0001001011101101	; $
.dw 0b0000110000100100	; %
.dw 0b0010001101011101	; &
.dw 0b0000010000000000	; '
.dw 0b0010010000000000	; (
.dw 0b0000100100000000	; )
.dw 0b0011111111000000	; *
.dw 0b0001001011000000	; +
.dw 0b0000100000000000	; ,
.dw 0b0000000011000000	; -
.dw 0b0000000000000000	; .
.dw 0b0000110000000000	; /
.dw 0b0000000000111111	; 0
.dw 0b0000000000000110	; 1
.dw 0b0000000011011011	; 2
.dw 0b0000000011001111	; 3
.dw 0b0000000011100110	; 4
.dw 0b0000000011101101	; 5
.dw 0b0000000011111101	; 6
.dw 0b0000000000000111	; 7
.dw 0b0000000011111111	; 8
.dw 0b0000000011101111	; 9
.dw 0b0001001000000000	; :
.dw 0b0000101000000000	; ;
.dw 0b0010010000000000	; <
.dw 0b0000000011001000	; =
.dw 0b0000100100000000	; >
.dw 0b0001000010000011	; ?
.dw 0b0000001010111011	; @
.dw 0b0000000011110111	; A
.dw 0b0001001010001111	; B
.dw 0b0000000000111001	; C
.dw 0b0001001000001111	; D
.dw 0b0000000011111001	; E
.dw 0b0000000001110001	; F
.dw 0b0000000010111101	; G
.dw 0b0000000011110110	; H
.dw 0b0001001000000000	; I
.dw 0b0000000000011110	; J
.dw 0b0010010001110000	; K
.dw 0b0000000000111000	; L
.dw 0b0000010100110110	; M
.dw 0b0010000100110110	; N
.dw 0b0000000000111111	; O
.dw 0b0000000011110011	; P
.dw 0b0010000000111111	; Q
.dw 0b0010000011110011	; R
.dw 0b0000000011101101	; S
.dw 0b0001001000000001	; T
.dw 0b0000000000111110	; U
.dw 0b0000110000110000	; V
.dw 0b0010100000110110	; W
.dw 0b0010110100000000	; X
.dw 0b0001010100000000	; Y
.dw 0b0000110000001001	; Z
.dw 0b0000000000111001	; [
.dw 0b0010000100000000	; 
.dw 0b0000000000001111	; ]
.dw 0b0000110000000011	; ^
.dw 0b0000000000001000	; _
.dw 0b0000000100000000	; `
.dw 0b0001000001011000	; a
.dw 0b0010000001111000	; b
.dw 0b0000000011011000	; c
.dw 0b0000100010001110	; d
.dw 0b0000100001011000	; e
.dw 0b0000000001110001	; f
.dw 0b0000010010001110	; g
.dw 0b0001000001110000	; h
.dw 0b0001000000000000	; i
.dw 0b0000000000001110	; j
.dw 0b0011011000000000	; k
.dw 0b0000000000110000	; l
.dw 0b0001000011010100	; m
.dw 0b0001000001010000	; n
.dw 0b0000000011011100	; o
.dw 0b0000000101110000	; p
.dw 0b0000010010000110	; q
.dw 0b0000000001010000	; r
.dw 0b0010000010001000	; s
.dw 0b0000000001111000	; t
.dw 0b0000000000011100	; u
.dw 0b0010000000000100	; v
.dw 0b0010100000010100	; w
.dw 0b0010100011000000	; x
.dw 0b0010000000001100	; y
.dw 0b0000100001001000	; z
.dw 0b0000100101001001	; {
.dw 0b0001001000000000	; |
.dw 0b0010010010001001	; }
.dw 0b0000010100100000	; ~
.dw 0b0011111111111111	; All
