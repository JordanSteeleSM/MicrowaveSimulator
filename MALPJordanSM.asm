;
; MALPJordanSM.asm
;
; Created: 02/08/2022 12:00:00 PM
; Modified: 02/27/2025 1:15:00 PM
; Author : Jordan Steele

; This assembly file is for the ATmega328P microcontroller and controls a
; cooking timer system. The system interacts with hardware components such as:
; - Heater
; - Turntable
; - Beeper
; - Door Switch
;
; The program uses a state machine with multiple states, including:
; - Idle
; - Start
; - Cooking
; - Suspend
; - Data Entry
;
; Joystick input is used to adjust cooking time. The program includes the
; following functionalities:
; - Start and stop the timer
; - Increment and decrement cooking time
; - Display relevant information on an attached display
;
; Timer interrupts are used for timekeeping, and a state machine handles
; transitions between operational modes.
;
; Subroutines are provided for:
; - Serial communication
; - Analog-to-digital conversion (ADC)
; - I2C communication with a real-time clock (RTC)
; ****************************************************************************

; Todo:


; 02/13/2025 1:30:00 PM: Make it so holding the joystick button doesn't constantly switch
; between the timer going on and off

; Progress, 02/23/2025 7:10:00 PM

; I'm very shocked I haven't made any real progress in this yet. Maybe it's because most of
; the other stuff has been for software and displaying things, while this one actually depends
; on user input. Holding a button, no less. There's got to be a way I can do this.

; Progress, 02/24/2025 3:24:00 PM

; Have I done it?
; Am I FREE?


; Done, 02/19/2025 5:30 PM

; Make pressing up and down on the joystick increment the time by 1 minute

; Progress, 02/13/2025 3:20 PM
; Adjusting the Joystick check to make it so the Y axis is the last thing checked allows
; it to be used for data entry instead of the X axis. I need to find out how to make
; them both work. There is also an issue where if I tilt the stick up, the minutes go down,
; and vice versa.

; Progress, 02/13/2025 5:10 PM
; After a few hours of trying to inc/dec/add/sub the r26 register by 1, I realized that
; that doesn't really work because of the register sizes being only 8 bits.

; I also finally found out that using the brlo (branch if lower) instruction let
; the seconds go up when the joystick is tilted up and down when it's down,
; instead of the opposite. This is in place of the brsh (branch if same or higher)
; instruction that the x-axis uses, since the dimensions are flipped, if that makes sense.
; I still need to find out how to make both sets of controls work at the same time.

; Progress, 02/16/2025 1:30 PM
; I am able to used the joyx and joyy values and load them into a register in order to
; see if the joystick is centered. All I need to do now is make it so that if x is
; moved, the time changes by 10 seconds, and 60 for y. I probably also need to change
; the deadzone to be smaller, since I don't want x and y being read at the same time.

; Progress, 02/16/2025 1:40 PM
; Made the deadzones bigger. Now to make the value change depending on if x is changed
; or y is changed.

; Progress, 02/16/2025 2:30 PM
; It works! Now I just need to re-add the checks to see if the time is at 0, so
; no underflow occurs.

; Progress  02/16/2025 3:00 PM
; Error: When minutes is past 9 or 10, going down 60 seconds makes the 10 inc trigger.
; But for the most part it works!

; Progress  02/19/2025 5:30 PM
; Lol, I was looking at the code for 5 minutes to see that a jump to store_time
; was missing, so the program would decrement 60 seconds then add 10. Added that, and
; now it works!



; Done, 02/13/2025 2:56 PM

; Decrease the delay between adding more time to the timer. It seems to be 1 second now,
; make it 0.50 seconds



; Done, 02/13/2025 6:00 PM

; Make it so that numbers on left-most display appear, so times higher than 10 minutes can appear.
; It currently works with the RTC, so there should be something simple to change.

; All I had to do was go to the displayCookTime function and change a register from r10 to r16.
; It was always supposed to be r16 but the 0 and 6 were indistinguishable to me. Maybe I'm not
; used to the font of this programming interface! Maybe I can change it.



; Done, 02/20/2025 7:25 PM

; Make it so that time is limited to 59:59 MM:SS just like a real microwave.

; Progress, 02/19/2025 11:28 PM

; I technically solved it by allowing the upper limit of the timer be 60 minutes. It can't
; go past this at all. That's technically 59:59, right? Right.

; Progress, 02/20/2025 7:25 PM
; No it was not right at all! I'm a perfectionist! Why not? I have the time! So I worked all
; day, brute forcing answers and using shortcuts to get this to work. And now it does!
; Now no matter what I press, the timer has a hard upper limit of 59:59, and a lower
; limit of 00:00. Now it works exactly as I want it to.



; Done, 02/20/2025 9:07 PM

; Make it so that when the microwave timer is at 0, the heater and table stop, instead
; of waiting another second before stopping

; Progress, 02/20/2025 9:07 PM

; I started this task when I finished the time limit task, so this took about 2 hours
; to figure out. I just needed to decrement seconds in my newly-added "back"
; label before jumping to idle, ensuring the last second is counted properly. Now I just
; need to figure out how exactly the stop-start button works, and all of the main issues will
; be solved!



; Done, 02/23/2025 12:45 PM

; 02/23/2025 12:11 PM: When the start button is pressed at 0 seconds, not only does it start the
; motor for a second, it also makes the value underflow. Make it so the timer doesn't work when
; there is no time left.

; Progress, 02/23/2025 12:35 PM
;cpi    r24, STARTS     ;State 0
;breq   cook
;cpi    r24, IDLES      ;State 1
;breq   cook
; Commenting out these lines means that the cook timer will no longer try to start if the program
; is in the cook idle state or the start state. That's very nice. If I could make it not even beep,
; that would be huge.

; Progress, 02/23/2025 1:25 PM
; I deadass was not paying attention. I just got rid of cbu PORTD,BEEPER in the ISR_TIM1_COMPA
; interrupt, and then commented out the beeper in the cook routine as well. Then I put the beeper
; in the data entry function, put the setbitinstruction at the start of it then the clearbitinstruction
; after the 25 ms delay. Now the beeper beeps for a quarter of a second when entering stuff in.
; I just need to add a shorter delay if I want to control that even more. MAN sometimes assembly
; is hard, but sometimes it's so easy.

; In doing this, didn't I already make this not start the timer at 0? I swear I did this like 10
; minutes after I made this progress. I was watching a stream while doing this, this was so easy. Is
; this what the actual job is gonna be like???

; We are gonna comment out the beeping for now though.

; Progress, 02/23/2025 6:42 PM

; I updated this even more. Now the decrements can't go below 1 second. There needs to be at least
; 11 seconds for the 10 second decrement, and 61 seconds for the 60 second one. That way, I can no
; longer go to 0 seconds on the clock and underflow the timer.

; Progress, 02/23/2025 7:09 PM

; One more! And I'm just playing at this point. Now I've set it so that the min it can get to is
; one second. WOW I'm on fire today. I don't know what exactly would make this not work now, but
; I'm glad that so far the answer is "nothing."






; Device constants
  .nolist
	.include "m328pdef.inc" ; Define device ATmega328P
	.list

; Constants
; General Constants
	.equ   CLOSED	= 0
	.equ   OPEN	    = 1
	.equ   ON	    = 1
	.equ   OFF	    = 0
	.equ   YES	    = 1
	.equ   NO	    = 0
	.equ   JCTR	    = 125	; Joystick centre value

; States
	.equ   STARTS	= 0
	.equ   IDLES	= 1     ;Occurs after the countdown is finished
	.equ   DATAS	= 2     ;The joystick, lets you enter seconds
	.equ   COOKS	= 3     ;The joystick button
	.equ   SUSPENDS = 4     ;The black button, simulating the door

; Global Data
	.dseg
	cstate:	  .byte 1			; Current State
	inputs:   .byte 1			; Current input settings
  prevSTSP: .byte 1     ; Check to stop joystick button from continuosly being pressed
  doorOpen: .byte 1     ; Check to see if the door is open
  cancelPressed: .byte 1; Check to see if cancel button is pressed
  joyx:	  .byte 1			; Raw joystick x-axis
	joyy:	  .byte 1			; Raw joystick y-axis
	joys:	  .byte 1			; Joystick status bits 0-not centred,1-centred
	seconds:  .byte 2		; Cook time in seconds 16-bit
	sec1:	  .byte 1			; minor tick time (100 ms)
	tascii:   .byte 8     ;holds the reculst of the Integer to ASCII conversion

; Port Pins
	.equ   LIGHT	= 7		; Door Light WHITE LED PORTD pin 7
	.equ   TTABLE	= 6		; Turntable PORTD pin 6 PWM
	.equ   BEEPER	= 5		; Beeper PORTD pin 5
	.equ   CANCEL	= 4		; Cancel switch PORTD pin 4
	.equ   DOOR	    = 3		; Door latching switch PORTD pin 3
	.equ   STSP	    = 2		; Start/Stop switch PORTD pin 2
	.equ   HEATER	= 0		; Heater RED LED PORTB pin 0

  .cseg
  .org   0x0000

; Interrupt Vector Table
	jmp		start
	jmp		ISR_INT0		; External IRQ0 Handler
	jmp		ISR_INT1		; External IRQ1 Handler
	jmp		ISR_PCINT0		; PCINT0 Handler
	jmp		ISR_PCINT1		; PCINT1 Handler
	jmp		ISR_PCINT2		; PCINT2 Handler
	jmp		ISR_WDT		; Watchdog Timeout Handler
	jmp		ISR_TIM2_COMPA	; Timer2 CompareA Handler
	jmp		ISR_TIM2_COMPB	; Timer2 CompareB Handler
	jmp		ISR_TIM2_OVF		; Timer2 Overflow Handler
	jmp		ISR_TIM1_CAPT	; Timer1 Capture Handler
	jmp		ISR_TIM1_COMPA	; Timer1 CompareA Handler
	jmp		ISR_TIM1_COMPB	; Timer1 CompareB Handler
	jmp		ISR_TIM1_OVF		; Timer1 Overflow Handler
	jmp		ISR_TIM0_COMPA	; Timer0 CompareA Handler
	jmp		ISR_TIM0_COMPB	; Timer0 CompareB Handler
	jmp		ISR_TIM0_OVF		; Timer0 Overflow Handler
	jmp		ISR_SPI_STC		; SPI Transfer Complete Handler
	jmp		ISR_USART0_RXC	; USART0 RX Complete Handler
	jmp		ISR_USART0_UDRE	; USART0,UDR Empty Handler
	jmp		ISR_USART0_TXC	; USART0 TX Complete Handler
	jmp		ISR_ADC		; ADC Conversion Complete Handler
	jmp		ISR_EE_RDY		; EEPROM Ready Handler
	jmp		ISR_ANALOGC		; Analog comparator
	jmp		ISR_TWI		; 2-wire Serial Handler
	jmp		ISR_SPM_RDY		; SPM Ready Handler

; Start after interrupt vector table
	.org	0xF6

; Dummy Interrupt routines
  ISR_INT0:			; External IRQ0 Handler
  ISR_INT1:			; External IRQ1 Handler
  ISR_PCINT0:			; PCINT0 Handler
  ISR_PCINT1:			; PCINT1 Handler
  ISR_PCINT2:			; PCINT2 Handler
  ISR_WDT:			; Watchdog Timeout Handler
  ISR_TIM2_COMPA:		; Timer2 CompareA Handler
  ISR_TIM2_COMPB:		; Timer2 CompareB Handler
  ISR_TIM2_OVF:			; Timer2 Overflow Handler
  ISR_TIM1_CAPT:		; Timer1 Capture Handler

  ISR_TIM1_COMPB:		; Timer1 CompareB Handler
  ISR_TIM1_OVF:			; Timer1 Overflow Handler
  ISR_TIM0_COMPA:		; Timer0 CompareA Handler
  ISR_TIM0_COMPB:		; Timer0 CompareB Handler
  ISR_TIM0_OVF:			; Timer0 Overflow Handler
  ISR_SPI_STC:			; SPI Transfer Complete Handler
  ISR_USART0_RXC:		; USART0 RX Complete Handler
  ISR_USART0_UDRE:		; USART0,UDR Empty Handler
  ISR_USART0_TXC:		; USART0 TX Complete Handler
  ISR_ADC:			; ADC Conversion Complete Handler
  ISR_EE_RDY:			; EEPROM Ready Handler
  ISR_ANALOGC:			; Analog comparator
  ISR_TWI:			; 2-wire Serial Handler
  ISR_SPM_RDY:			; SPM Ready Handler
	reti

; Timer1 Interrupt CompareA Handler
ISR_TIM1_COMPA:
	push	r0		; Save Context
	in	r0,SREG	; Get Status register
	push	r0

; Rest of ISR Code here
	;cbi	PORTD,BEEPER
	pop	r0		; Restore Status Register
	out	SREG,r0
	pop	r0
	reti

; Message strings
	cmsg1:    .db "Time: ",0,0
	cmsg2:	  .db " Cook Time: ",0,0
	cmsg3:	  .db " State: ",0,0
	joymsg:	  .db " Joystick X:Y ",0,0
  stspmsg:  .db " STSP Pressed: ",0,0

; .asm include statements
	.include "iopins.asm"
	.include "util.asm"
	.include "serialio.asm"
	.include "adc.asm"
	.include "i2c.asm"
	.include "rtcds1307.asm"
	.include "andisplay.asm"


; Main Program Entry Point
start:
	ldi	   r16,HIGH(RAMEND)	; Initialize the stack pointer
	out	   sph,r16
	ldi    r16,LOW(RAMEND)
	out	   spl,r16
  ldi    r28, 0            ; Initializes the start/stop button being pressed and the door being open to 0
  sts    prevSTSP, r28
  sts    doorOpen, r28
  ldi    r29, 0
  sts    cancelPressed, r29


	call   initPorts ;I/O Pin Initialization
	call   initUSART0 ;USART0 Initialization
	call   initADC
	call   initI2C
	call   initDS1307
	call   initAN
	jmp    startstate









; Main program loop
loop:

; Check the time
	call   updateTick

;	Cancel Key Pressed
  sbis   PIND,CANCEL
  jmp	   idle
  ldi    r29, 0
  sts    cancelPressed, r29

; Check the inputs here
;	If Door Open jump to suspend
	sbis   PIND, DOOR
  jmp	   doorCloseCheck

doorOpenCheck:
	cbi    PORTB,HEATER			;Turns HEATER off
  ldi	   r24,SUSPENDS			; Set state variable to Suspend
  sts	   cstate,r24			; Do suspend state tasks
	ldi    r16, 0
	out	   OCR0A,r16			;Stops turntable

  lds    r28, doorOpen
  cpi    r28, 1
  breq   doorCloseCheck

  sbi    PORTD, LIGHT			;Turns LIGHT on
  sbi	   PORTD,BEEPER
  call   delay0.25s
  cbi	   PORTD,BEEPER
  ldi    r28, 1
  sts    doorOpen, r28

  ; see if door has just been opened
  ; if not return to loop
  ; if door has just been opened, set doorOpen to true and beep
  ;return to loop

doorCloseCheck:
  sbic   PIND, DOOR
  jmp	   loop
  ldi    r28, 0
  sts    doorOpen, r28

loop2:

;	Start Stop Key Pressed
  lds    r24,cstate
  cbi    PORTD, LIGHT
	sbic   PIND,STSP       ; If Start Stop key is pressed, go to stspSet. If not, then cook/suspend
  rjmp   stspSet

; If stsp is not pressed, do these tasks
; Start Stop Key will only activate once, holding it down will not repeatedly trigger these events.
  lds    r28, prevSTSP
  cpi    r28, 0           ; Check if prevSTSP == 0
  brne   loop             ; If startstop key is pressed, go to loop

  cpi    r24,COOKS       ;State 3
  breq   suspendshortcut

  cpi    r24, SUSPENDS   ;State 4
  breq   cook

stspSet:
  sbic   PIND,STSP
  ldi    r28, 0            ; If the STSP button has been pressed, this changes. Init to not pressed.
  sts    prevSTSP, r28


joy0:
  call   joystickInputs
  lds    r24, cstate
  cpi    r24, COOKS     ; If Cook state is on, return to loop
  breq   loop
  cpi    r25, 1         ; If joystick is centered, return to loop
  breq   loop
  rjmp   dataentry      ; Else, go to data entry

	
loopshortcut:
	rjmp   loop


suspendshortcut:
  rjmp suspend

stspshortcut:
  rjmp stspSet

; State Actions Code

; Idle, State 1
idle:
  ldi	   r24,IDLES			; Set state variable to Idle
  sts	   cstate,r24			; Do idle state tasks
	ldi    r16, 0
	out	   OCR0A,r16
	
	cbi    PORTB, HEATER
  sbis   PIND, DOOR
  cbi    PORTD, LIGHT
	ldi    r24, 0
  sts    seconds+1, r24
  sts    seconds, r24
  lds    r29, cancelPressed
  cpi    r29, 0
  breq   idle1
  rjmp   idle2
idle1:
  ldi    r29, 1
  sts    cancelPressed, r29
  call   displayState
idle2:
  jmp	   loop

; Start state, State 0
startstate:
  ldi	   r24,STARTS
  sts	   cstate,r24
	cbi    PORTB,HEATER
	ldi    r16, 0
	out	   OCR0A,r16
  call   setDS1307

  ldi    r24, 0
	sts	   sec1,r24
  sts    seconds+1, r24
  sts    seconds, r24
	
	cbi    PORTB,HEATER
	cbi    PORTD, LIGHT
  jmp	   loop

; Cook State, State 3
cook:
  cpi    r28, 1
  breq   stspshortcut ;if stsp pressed, skip all of this and go to stspset

  ldi	   r24,COOKS			; Set state variable to Cook
  sts	   cstate,r24			; Do cook state tasks
	sbi    PORTB, HEATER
	cbi    PORTD, LIGHT
	ldi    r16, 0x23
	out	   OCR0A,r16

; load 1 into prevSTSP, then go back to stsp
  ldi    r28, 1
  sts    prevSTSP, r28
  call   displayState
  jmp	   stspshortcut

; Suspend State, State 4
suspend:
  cpi    r28, 1
  breq   stspshortcut ;if stsp pressed, skip all of this and go to stspset

  ldi	   r24,SUSPENDS			; Set state variable to Suspend
  sts	   cstate,r24			; Do suspend state tasks
	ldi    r16, 0
	out	   OCR0A,r16			;Stops turntable
	cbi    PORTB,HEATER			;Turns HEATER off
	sbi    PORTD, LIGHT			;Turns LIGHT on

  sbi	   PORTD,BEEPER
  call   delay0.25s
  cbi	   PORTD,BEEPER

; load 1 into prevSTSP, then go back to stsp
  ldi    r28, 1
  sts    prevSTSP, r28
  jmp	   stspshortcut

; Cook timer alarm going off
cookingdone:
  cbi    PORTB,HEATER
	cbi    PORTD, LIGHT
  ldi    r16, 0
	out	   OCR0A,r16
  sbi	   PORTD,BEEPER
  call   delay0.25s
  cbi	   PORTD,BEEPER
  call   delay0.25s
  sbi	   PORTD,BEEPER
  call   delay0.25s
  cbi	   PORTD,BEEPER
  call   delay0.25s
  sbi	   PORTD,BEEPER
  call   delay0.25s
  cbi	   PORTD,BEEPER
  call   delay0.25s
  call   delay0.25s
  jmp    idle








dataentry:						    ; Data Entry State, State 2
	ldi    r24,DATAS			  ; Set state variable to Data Entry
	sts	   cstate,r24
	cbi    PORTB,HEATER
	cbi    PORTD, LIGHT
  ;sbi	   PORTD,BEEPER     ; sometimes it's just annoying so this can be commented out if need be
	lds	   r26, seconds		  ; Get current cook time
	lds	   r27, seconds+1
	lds	   r22, joyx        ; Load joystick X value
	lds	   r23, joyy        ; Load joystick Y value

; Check X axis movement (±10 seconds)
	cpi	   r22, 50           ; If X < 50, increase time by 10
	brlo   check_inc_10
	cpi	   r22, 200          ; If X > 200, decrease time by 10
	brsh   check_dec_10

; Check Y axis movement (±60 seconds)
	cpi	   r23, 50           ; If Y < 50, increase time by 60
	brlo   inc_60
	cpi	   r23, 200          ; If Y > 200, decrease time by 60
	brsh   check_dec_60
	jmp	   store_time        ; If joystick is in deadzone, skip adjustments

check_dec_10:
  cpi    r26, 11           ; Check if seconds are at least 11
  brsh   safe_dec_10       ; If seconds >= 11, it's safe to decrement
  rjmp   check_dec_10_2
  ;tst    r27               ; Check if minutes are 0
  ;breq   store_time        ; If minutes = 0 and seconds < 10, prevent underflow

check_dec_10_2:
  cpi    r27, 0
  breq   min_time

safe_dec_10:
  sbiw   r27:r26, 10       ; Safe to decrease by 10 seconds
  rjmp   store_time        ;

check_dec_60:
  cpi    r26, 61           ; Check if seconds are at least 61
  brsh   safe_dec_60       ; If so, subtract normally
  rjmp   check_dec_60_2

check_dec_60_2:
  cpi    r27, 0
  breq   min_time

safe_dec_60:
  sbiw   r27:r26, 60       ; Safe to decrease by 60 seconds
  rjmp   store_time

inc_60:
  adiw   r27:r26, 60       ; Increase cook time by 60 seconds
  cpi    r27, 14           ; Prevent exceeding 59:59
  brsh   max_time
  rjmp   store_time

data_entry_cont:
  rjmp dataentry

check_inc_10:
  cpi    r27, 14           ; Prevent exceeding 59:59
  brlo   inc_10
  cpi    r26, 15           ; Prevent exceeding 59:59
  brsh   max_time


inc_10:
  adiw   r27:r26, 10       ; Increase cook time by 10 seconds
  cpi    r27, 14
  brlo   store_time

max_time:                  ; 59 minutes, 59 seconds
  cpi    r26, 15
  brlo   continue
  ldi    r26,15
  ldi    r27,14

store_time:
  cpi    r27, 15
  brsh   max_time
  rjmp   continue

min_time:
  ldi    r26, 1

continue:

	sts	   seconds, r26      ; Store lower byte (seconds)
	sts	   seconds+1, r27    ; Store upper byte (minutes)
	call   displayState
  call   delay0.1s
  cbi	   PORTD,BEEPER
  call   delay0.25s
	;call   delay0.25s        ; Data Entry Speed. Currently set to 0.25 seconds, change to delay1s for 1 second.
  call   joystickInputs
	lds	   r21,joys
	cpi	   r21,0
  breq   data_entry_cont			   ; Do data entry until joystick centred
	ldi	   r24,SUSPENDS
	sts	   cstate,r24
	jmp	   loop






;Time Tasks
updateTick:
	call   delay100ms
	lds	   r22,sec1		; Get minor tick time
	cpi	   r22,10			; 10 delays of 100 ms done?
  brne   ut2
	ldi	   r22,0			; Reset minor tick
	sts	   sec1,r22		; Do 1 second interval tasks

	lds	   r23,cstate		; Get current state
	cpi	   r23,COOKS    ; If not cooking, display time
	brne   ut1


  lds	   r26,seconds		; Get current cook time
	lds	   r27,seconds+1

; Check if time is 1 second remaining
    cpi    r26,1
    breq   back         ; If 1 second left, jump to idle

; Otherwise, decrement the cook time by 1 second
    inc    r26
    sbiw   r27:r26,1         ; Decrement cook time by 1 second

    brne   ut3


back:
    sbiw   r27:r26,1         ; Decrement/store cook time
    sts    seconds,r26
    sts    seconds+1,r27
    call   displayState
    jmp    cookingdone       ; If seconds == 0, go to idle

ut3:
	sbiw   r27:r26,1		; Decrement/store cook time
	sts	   seconds,r26
	sts	   seconds+1,r27

ut1:
	call   displayState

ut2:
	lds	   r22,sec1
	inc	   r22
	sts	   sec1,r22
	ret






;Displays the state
displayState:

; prints a new line
  call   newline
	
mess1:
; prints the cmsg1 string
  ldi	   ZL,LOW(2*cmsg1)
	ldi	   ZH,HIGH(2*cmsg1)
  ldi    r16,1
  call   putsUSART0

; prints the time of day
  call   displayTOD

mess2:
; prints the cmsg2 string
  ldi	   ZL,LOW(2*cmsg2)
	ldi    ZH,HIGH(2*cmsg2)
  ldi    r16,1
  call   putsUSART0

; prints the cook time
  call   displayCookTime

; prints the cmsg3 string
  ldi	   ZL,LOW(2*cmsg3)
  ldi	   ZH,HIGH(2*cmsg3)
  ldi    r16,1
  call   putsUSART0

; prints the control state
  lds    r17,cstate
  call   ByteToHexASCII
  mov    r16,r17
  call   putchUSART0

; prints the joymsg string
  ldi	   ZL,LOW(2*joymsg)
	ldi	   ZH,HIGH(2*joymsg)
  ldi    r16,1
  call   putsUSART0



; prints x values
  lds    r17, joyx
  call   ByteToHexASCII
  mov    r16,r17
  call   putchUSART0
  mov    r16,r18
  call   putchUSART0

; prints a colon
  ldi    r16, ':'
  call   putchUSART0

; prints y values
  lds    r17, joyy
  call   ByteToHexASCII
  mov    r16,r17
  call   putchUSART0
  mov    r16,r18
  call   putchUSART0

; prints the stsp string
  ldi	   ZL,LOW(2*stspmsg)
  ldi	   ZH,HIGH(2*stspmsg)
  ldi    r16,1
  call   putsUSART0

; prints the stsp state
  lds    r17,prevSTSP
  call   ByteToHexASCII
  mov    r16,r17
  call   putchUSART0
  ret



; Save Most Significant 8 bits of Joystick X,Y
; To the global variables joyx and joyy
; Set joys if the joystick is centred.

joystickInputs:
	ldi	   r24,0x00		; Read ch 0 Joystick Y
	call   readADCch
	swap   r25
	lsl	   r25
	lsl	   r25
	lsr	   r24
	lsr	   r24
	or	   r24,r25
	sts	   joyy,r24      ; Store Y value

	ldi	   r24,0x01		; Read ch 1 Joystick X
	call   readADCch
	swap   r25
	lsl	   r25
	lsl	   r25
	lsr	   r24
	lsr	   r24
	or	   r24,r25
	sts	   joyx,r24      ; Store X value

	ldi	   r25,0			; Assume joystick is NOT centered

	lds	   r22, joyx      ; Load X value into r22
	cpi	   r22,50
	brlo   not_centered
	cpi	   r22,200
	brsh   not_centered

	lds	   r23, joyy      ; Load Y value into r23
	cpi	   r23,50
	brlo   not_centered
	cpi	   r23,200
	brsh   not_centered

	ldi	   r25,1			; If both X and Y are within 115-135, set centered flag

not_centered:
	sts	   joys,r25        ; Store center status (1 = centered, 0 = not centered)
	ret




displayTOD: ;prints the current time, adding a colon between hours, minutes, and seconds


  ldi	   r25,HOURS_REGISTER
  call   ds1307GetDateTime
  mov    r17, r24
  call   pBCDToASCII
  mov    r16,r17
  call   putchUSART0
  mov    r16,r18
  call   putchUSART0

  ldi    r16, ':'
  call   putchUSART0

  ldi		r25,MINUTES_REGISTER
  call   ds1307GetDateTime
  mov    r17, r24
  call   pBCDToASCII
  mov    r16,r17
  call   putchUSART0
  mov    r16,r18
  call   putchUSART0

  ldi    r16, ':'
  call   putchUSART0

  ldi	   r25,SECONDS_REGISTER
  call   ds1307GetDateTime
  mov    r17, r24
  call   pBCDToASCII
  mov    r16,r17
  call   putchUSART0
  mov    r16,r18
  call   putchUSART0

  lds    r24,cstate
  cpi    r24,COOKS
  breq   tod0
  cpi    r24,SUSPENDS
  breq   tod0
  cpi    r24,DATAS
  breq   tod0

displayTODan:
  ldi	   r25,HOURS_REGISTER
  call   ds1307GetDateTime
  mov    r17, r24
  call   pBCDToASCII
  mov    r16, r17
	mov    r15, r18
	ldi    r17, 0
	call   anWriteDigit
  mov    r16,r15
	ldi    r17, 1
  call   anWriteDigit


  ldi	   r25,MINUTES_REGISTER
  call   ds1307GetDateTime
  mov    r17, r24
  call   pBCDToASCII
  mov    r16, r17
	mov    r15, r18
	ldi    r17, 2
	call   anWriteDigit
  mov    r16,r15
	ldi    r17, 3
  call   anWriteDigit

tod0:
  ret

displayCookTime:

  lds    r16, seconds
  lds    r17, seconds+1
  call   itoa_short

  ldi    r20, 0
  sts    tascii+5, r20
  sts    tascii+6, r20
  sts    tascii+7, r20
  ldi	   ZL,LOW(tascii)
  ldi	   ZH,HIGH(tascii)
  ldi    r16, 0
  call   putsUSART0

	lds    r24, cstate
	cpi    r24, STARTS      ;State 0
  breq   displayTODan
	cpi    r24, IDLES      ;State 1
  breq   displayTODan
  cpi    r24, SUSPENDS      ;State 4
  breq   displayNoChange


	lds    r16, seconds
	lds    r17, seconds+1
	ldi    r18, 60
	ldi    r19, 0


	call   div1616
	mov    r4,r0
	mov    r5, r2
	mov    r16, r4

  ldi    r18,10
	call   div88
	ldi    r16, '0'
	add    r16, r0
	ldi    r17, 0
	call   anWriteDigit
	ldi    r16, '0'
	add    r16, r2
	ldi    r17, 1
	call   anWriteDigit

	mov    r16, r5
	ldi    r18, 10
	call   div88
	ldi    r16, '0'
	add    r16,r0
	ldi    r17, 2
	call   anWriteDigit
	ldi    r16,'0'
	add    r16, r2
	ldi    r17, 3
	call   anWriteDigit
displayNoChange:
  ret
