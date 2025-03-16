; rtcds1307.asm
;
; Created: 11/02/2022 12:00:00 PM
; Author : Jordan Steele

; This file initializes and communicates with the DS1307 RTC using I2C.
; It includes functions to set and retrieve the current date and time.


.equ RTCADR           = 0xd0
.equ SECONDS_REGISTER = 0x00
.equ MINUTES_REGISTER = 0x01
.equ HOURS_REGISTER	  = 0x02
.equ DAYOFWK_REGISTER = 0x03
.equ DAYS_REGISTER    = 0x04
.equ MONTHS_REGISTER  = 0x05
.equ YEARS_REGISTER   = 0x06
.equ CONTROL_REGISTER = 0x07
.equ RAM_BEGIN        = 0x08
.equ RAM_END          = 0x3F

initDS1307:
	ldi	r23,RTCADR		; RTC Setup
	call	i2cStart
	ldi	r23,RTCADR		; Initialize DS1307
	ldi	r25,CONTROL_REGISTER
	ldi	r22,0x00
	call	i2cWriteRegister
	ret

; r23 RTC Address, r25 ds1307 Register, Return Data r24
ds1307GetDateTime:
	ldi		r23,RTCADR
	call	i2cReadRegister
	ret

; Setting the initial RTC time
setDS1307:
	ldi		r23,RTCADR
	ldi		r25,CONTROL_REGISTER
	ldi		r22,0x00
	call	i2cWriteRegister
  ldi		r23,RTCADR
	ldi		r25,HOURS_REGISTER
; ldi		r22,0x16  ; Sets time to 16 hours
  ldi		r22,0x11  ; Sets time to 11 hours
  call	i2cWriteRegister
	ldi		r23,RTCADR
	ldi		r25,MINUTES_REGISTER
; ldi		r22,0x58   ; Sets time to 58 minutes
  ldi		r22,0x59   ; Sets time to 59 minutes
  call	i2cWriteRegister
	ldi		r23,RTCADR
	ldi		r25,SECONDS_REGISTER
; ldi		r22,0x11   ; Sets time to 11 seconds
  ldi		r22,0x55   ; Sets time to 55 seconds
	call	i2cWriteRegister
	ret
