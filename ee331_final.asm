;;;;;;;;;;;;;;;;;;;;;;;;;;; Assembler directives ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
		#include "P18F46K22.inc"
		list  P=P18F46K22, F=INHX32, C=160, N=0, ST=OFF, MM=OFF, X=ON
        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Variables ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
        cblock  0x000              	;Beginning of Bank 0.
		R1
		R2
		R3
		R4
		R5
		R6
		Kc
		Kc2
		Kc3
  		COUNT
		COUNT1
		KEYCODE
		KeyToShow
		LINE
		CharCount
		BuzzTime
		Var1
		Var2
		Var3
		Var4
		IntervalL
		IntervalH
		DCount
		DCount1
		DLoop
		DLoop1
		ECount
		ECount1
		ELoop
		ELoop1
		GCount
		GCount1
		GLoop
		GLoop1
		FCount
		FCount1
		FLoop
		FLoop1
		Song1Count
		ACount
		ACount1
		ALoop
		ALoop1
		KimCount
		KimCount1
		KimLoop
		KimLoop1
		Kim1Count
		Kim1Count1
		Kim1Loop
		Kim1Loop1
		CCount
		CCount1
		CLoop
		CLoop1
        endc

;;;;;;;;;;;;;;;;;;;;;;;;;;;  ; Vectors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
 
        org  	0x0000           	;Reset vector
        nop							;Required by ICD 3 module
        goto  	Mainline			;preforms the main loop

        org  	0x0008           	;High priority interrupt vector
		goto	$

        org  	0x0018              ;Low priority interrupt vector
        goto  	$                   ;Trap (an infinite loop at this address)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Mainline program ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
		org  	0x0030	
LCDstr 	db 	0x38, 0x38, 0x38, 0x38, 0x01, 0x0c, 0x06, 0x00
Msg1	db 	0x80, "Hello World!", 0x00
Msg2	db 	0xC0, "FINAL PROJECT!!", 0x00
Menu1	db 	0x80, "1 Happy Birthday", 0x00
Menu2	db	0xC0, "2 Beep Me!", 0x00
Menu3	db	0x80, "3 Twinkle x2", 0x00
Menu4	db 	0xC0, "4 SOS!!!", 0x00
Menu5	db	0x80, "5 for key input", 0x00
Blank1	db	0x80,"                ", 0x00
Blank2	db	0xC0,"                ", 0x00
Playing	db	0X80, "Playing Song!", 0x00

KEY_ASCII	db "A321B654C987D#0*"
SHIFT_KEY	db "@+fe>-?=<&! (:/)" 

Mainline
        rcall  	Initial             ;Initialize everything
		rcall	InitLCD	
INTCOUNT
		movlw	0
		movwf	COUNT
		clrf	CharCount	


MainLoop
		movlw   high Msg1 ;WREG = high byte address (A15 - A8) of Msg1
		movwf	TBLPTRH
		movlw	low Msg1 ;WREG = low byte address (A7 - A0) of Msg1
		movwf	TBLPTRL
		rcall	DisplayC
		movlw	high Msg2	;displays message 2
		movwf	TBLPTRH
		movlw	low Msg2
		movwf	TBLPTRL
		rcall	DisplayC
		rcall	T2
		rcall	clear1
		movlw	high Menu1 ;WREG = high byte address (A15 - A8) of Msg1
		movwf	TBLPTRH
		movlw	low Menu1 ;WREG = low byte address (A7 - A0) of Msg1
		movwf	TBLPTRL
		rcall	DisplayC	
		movlw	high Menu2	;displays menu 2
		movwf	TBLPTRH
		movlw	low Menu2
		movwf	TBLPTRL
		rcall	DisplayC

		rcall	T3
		rcall	clear1
		movlw	high Menu3 ;WREG = high byte address (A15 - A8) of Msg1
		movwf	TBLPTRH
		movlw	low Menu3 ;WREG = low byte address (A7 - A0) of Msg1
		movwf	TBLPTRL
		rcall	DisplayC
		movlw	high Menu4	;displays menu 4
		movwf	TBLPTRH
		movlw	low Menu4
		movwf	TBLPTRL
		rcall	DisplayC
		rcall	T3
		rcall	clear1

		movlw	high Menu5  ;WREG = high byte address (A15 - A8) of Msg1
		movwf	TBLPTRH
		movlw	low Menu5 ;WREG = low byte address (A7 - A0) of Msg1
		movwf	TBLPTRL
		rcall	DisplayC

		rcall	T3
		rcall	clear1
		goto	MainLoop

Again
		nop
		btfss	PORTC, 1
		rcall	CheckRC1
		
		rcall	AnyKey ;check if key is pressed 
		btfsc	STATUS, Z ;exit loop if button is pressed 
		goto	Again
		
		rcall	ScanKeys
		movf	KEYCODE, W
		movwf	Kc
		rcall	LoopTime_10ms ;debouncing delay
		rcall	LoopTime_10ms

		rcall	ScanKeys ;check same key has been pressed 
		movf	KEYCODE, W
		cpfseq	Kc ;ensure same button was pressed 
		goto	Again 

		rcall 	CheckRC0
		goto	Again

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ClearTopLine
		movlw	high Blank1 ;WREG = high byte address (A15 - A8) of Msg1
		movwf	TBLPTRH
		movlw	low Blank1 ;WREG = low byte address (A7 - A0) of Msg1
		movwf	TBLPTRL
		rcall	DisplayC
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ClearBottomLine
		movlw	high Blank2
		movwf	TBLPTRH
		movlw	low Blank2
		movwf	TBLPTRL
		rcall	DisplayC
	
		return
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CheckRC1
		rcall	 LoopTime_10ms
		rcall	 LoopTime_10ms
		btfsc	 PORTC, 1
		bra 	 ChkRC1Done
 
		movlw 	 0
		cpfseq	 LINE ;check if on top line
		bra		 InBottomLine ;if not go to bottom line case

		rcall	 ClearBottomLine ;clear bottom line for new stuff
		rcall	 SetCursorC0H ;set cursor to start of bottom 
		incf	 LINE ;increment LINE to indicate on bottom line 
		clrf	 CharCount
		goto	 ChkRC1Done

InBottomLine
		rcall	 ClearTopLine ;clear top line
		rcall	 SetCursor80H ;set cursor to top line
		clrf	 LINE ;reset LINE to indiciate on top line
		clrf	 CharCount

ChkRC1Done
		rcall	RC1Released 
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CheckRC0
		btfsc 	PORTC, 0 ;Skip next instruction if RC0=0
		bra 	NoShift ;RC0=1 so it is not shifted, treat as such

		movlw	.13 ;Binary code for # key
		cpfseq	KEYCODE ;compare keycode w/WREG to determine if # was pressed 
		bra		Continue ;if # wasn't pressed continue as normal shifted key
		
		rcall	ClearTopLine ;clear top line
		rcall	ClearBottomLine ;clear bottom line	
		rcall	SetCursor80H ;Move cursor to start position of top row
		clrf	LINE ;LINE = 0
		clrf	CharCount ;CharCount = 0
		bra		ChkCharDone ;done with clearing, return from subroutine
		
		
Continue

		movlw	.15
		cpfseq	KEYCODE
		bra		Continue1

		goto 	Mainline

Continue1
		movlw 	low SHIFT_KEY
		movwf 	TBLPTRL
		movlw	high SHIFT_KEY
		movwf 	TBLPTRH
		movf 	KEYCODE,W
		addwf 	TBLPTRL
		movlw 	0
		addwfc 	TBLPTRH ;TBLPTR points at the detected shifted key
		tblrd * ;TABLAT = ASCII code of the shifted key to be displayed
		movff 	TABLAT, KeyToShow ;Save the ASCII code
		bra 	DisplayPressedKey

NoShift
		movlw 	low KEY_ASCII
		movwf 	TBLPTRL
		movlw 	high KEY_ASCII
		movwf	TBLPTRH ;TBLPTR points at KEY_ASCII
		movf	KEYCODE, W
		addwf 	TBLPTRL
		tblrd * ;TABLAT = ASCII code of the non-shited key to be displayed
		movff 	TABLAT, KeyToShow ;Save the ASCII code
	

DisplayPressedKey
		movlw	0x10
		cpfseq	CharCount ;go to new line if CharCount = 16
		bra		CurrentLine	;if <16 stay on current line
		clrf	CharCount ;reset char count for new line
		
		tstfsz	LINE ;if LINE= 0 skip
		bra		OnBottomLine ;go to bottom if else
		rcall	ClearBottomLine 
		setf	LINE	;move to bottom line
		rcall	SetCursorC0H ;set cursor to be on bottom
		rcall	SendKeyASCII	;print char
		bra		ChkCharDone	

CurrentLine		
		rcall	SendKeyASCII ;print char on current line
		bra		ChkCharDone

OnBottomLine
		rcall	ClearTopLine ;clear top line to move to it
		clrf	LINE ;decf line to 0
		clrf	CharCount
		rcall	SetCursor80H ;move cursor to start of top line
		rcall	SendKeyASCII ;print char in 1st pos. of top line
		nop
		
ChkCharDone
		rcall	IsReleased
		rcall	Buzz_2.5ms
		return
		
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetCursor80H
		bcf		PORTE, 0 ;RS = 0 for command
		bsf		PORTE, 1 ;Raise E
		movlw	0x80 
		movwf	PORTD, W ;send 0x80 to PORTD
		bcf		PORTE, 1 ;Drop E
		rcall	LoopTime_10ms
		bsf		PORTE, 0 ;drive RS high
		return
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SetCursorC0H
		bcf		PORTE, 0; drive RS low
		bsf		PORTE, 1; Raise E
		movlw	0xc0
		movwf	PORTD, W ;send 0xc0 to PORTD
		bcf		PORTE, 1 ;drop port E
		rcall	LoopTime_10ms
		bsf		PORTE, 0 ;Drive RS high
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SendKeyASCII 
		bsf 	PORTE, 0
		bsf		PORTE, 1 ;Raise E
		movff 	KeyToShow , PORTD
		bcf		PORTE, 1
		rcall 	T40
		rcall 	T40
		nop
		nop
		incf	CharCount ;count chars on LCD Line
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IsReleased
	rcall	AnyKey
	btfss	STATUS, Z
	bnz		IsReleased
	
	rcall	LoopTime_10ms ; debouce
	rcall	LoopTime_10ms ; debouce
	
	return
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RC1Released 
	btfss	PORTC, 1 ;if rc1 is set(button not pressed) skip
	bra		RC1Released ;check until RC1 is released (0v across the pin)
		
	rcall	LoopTime_10ms ;debounce 
	rcall	LoopTime_10ms ;debounce

	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Initial subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
; This subroutine performs all initializations of variables and registers.
Initial
		movlw	0x5C
		movwf	OSCCON
		movlb	0x0f
		clrf	PORTD
		clrf	PORTE
		clrf	ANSELD
		clrf	ANSELE
		clrf	TRISD
		clrf	TRISE
		
		clrf	PORTB
		clrf	PORTC
		clrf	Kc
		clrf	KEYCODE
		
		clrf	TBLPTRL
		clrf	TBLPTRH
		
		movlw 	0x00
		movwf 	ANSELB
		movlw 	0x00
		movwf	ANSELC

		bcf		INTCON2,7
		
		movlw	0x0F
		movwf	TRISB

		movlw	0x03
		movwf	TRISC
		
		movlb	0

		movlw	0
		movwf	CharCount
		
		clrf	LINE

		movlw	B'10001000'
		movwf	T0CON
	
		clrf	Song1Count

		return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; LoopTime_10ms subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
LoopTime_10ms
       	movlw	.8
		movwf	R1
Loop1								;outer for-loop
		movlw	.250
		movwf	R2
Loop2								;inner for-loop
		nop
		nop														
		decf	R2, F
		bnz		Loop2
		decf	R1, F
		bnz		Loop1

		return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Sub1
		movlw	low (.65536-.10000)
		movwf	IntervalL
		movlw	high (.65536-.10000)
		movwf	IntervalH
		
		rcall	TMR0_Interval
Sub_Again
		rcall	AnyKey
		btfss	STATUS, Z
		rcall	DetermineKey
		
		btfss	INTCON,TMR0IF
		bra		Sub_Again
		return

TMR0_Interval
		bcf		INTCON,TMR0IF
		movlw	B'00001000'
		movwf	T0CON
		movff	IntervalL,TMR0L
		movff	IntervalH,TMR0H
		movlw	B'10001000'
		movwf	T0CON
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DetermineKey
		nop
		btfss	PORTC, 1 ;skip if Enter isn't pressed
		rcall	CheckRC1
		
		
		
		rcall	ScanKeys ;find what key was pressed
		movf	KEYCODE, W 
		movwf	Kc ;store keycode in register 
		rcall	LoopTime_10ms ;debouncing delay
		rcall	LoopTime_10ms

		rcall	ScanKeys ;check same key has been pressed 
		movf	KEYCODE, W
		cpfseq	Kc ;ensure same button was pressed 
		return ;go back to timer loop

		rcall 	FindKeyPressed
		return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FindKeyPressed
		clrf	WREG
		movlw	.3
		cpfseq	KEYCODE
		bra		check2
		bra		option1
check2
		clrf	WREG
		movlw	.2
		cpfseq	KEYCODE
		bra		check3
		bra		option2
check3
		clrf	WREG
		movlw	.1
		cpfseq	KEYCODE
		bra		check4
		bra 	option3
check4
		clrf	WREG
		movlw	.7
		cpfseq	KEYCODE
		bra		check5
		bra		option4
check5
		clrf	WREG
		movlw	.6
		cpfseq	KEYCODE
		bra		ending
		bra		option5
option1
		rcall	DisplayPlaying
		rcall	PlaySong1
		bra		ending
option2
		rcall	DisplayPlaying
		rcall	PlaySong2
		bra		ending
option3
		rcall	DisplayPlaying
		rcall	PlaySong3
		bra		ending
option4
		rcall	DisplayPlaying
		rcall	PlaySOS
		bra		ending
option5
		rcall	clear1
		rcall	SetCursor80H
		clrf	CharCount
		clrf	LINE
		goto	Again
ending
		return


DisplayPlaying
		rcall	clear1
		movlw   high Playing ;WREG = high byte address (A15 - A8) of Msg1
		movwf	TBLPTRH
		movlw	low Playing ;WREG = low byte address (A7 - A0) of Msg1
		movwf	TBLPTRL
		rcall	DisplayC
		rcall	T0
		
		rcall	clear1
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; T40 subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;timer for in-between each letter being displayed

T40
		movlw 	.50 ;Each loop takes 3 cycles for a total of 153 cycles
		movwf	COUNT1
T401 
		decf 	COUNT1,F
		bnz 	T401

endIt
 		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;T1 subroutine;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;subroutine creates a 1 second delay

T1
		movlw	.100
		movwf	R5	
Leup
		rcall	Sub1
		decf	R5, F
		bnz		Leup
		
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; T2 subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;this subroutine creates a time delay of 2 seconds

T2
		movlw	.200
		movwf	R3
Loopies								;outer for-loop
		rcall	Sub1
		decf	R3, F
		bnz		Loopies
		return;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

T0
		movlw	.50
		movwf	R6

LoopDeDoDa

		rcall	LoopTime_10ms
		decf	R6, F
		bnz		LoopDeDoDa

		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; T3 subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;this subroutine creates a time delay of 3 seconds
T3
		rcall	T2	;combine call of T2 and T1 yield total of 3 sec delay
		rcall	T1

		return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; InitLCD subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
InitLCD		movlw	.10
		movwf	COUNT
L1
		rcall	LoopTime_10ms
		decf	COUNT,F
		bnz		L1
		bcf 	PORTE,0
		movlw	high LCDstr
		movwf	TBLPTRH
		movlw	low LCDstr
		movwf	TBLPTRL
		tblrd*
L2
		bsf		PORTE,1
		movff	TABLAT,PORTD
		bcf		PORTE,1
		rcall	LoopTime_10ms
		tblrd+*
		movf	TABLAT,F
		bnz		L2
		return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; DisplayC subroutine ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;this displays a continuous message
DisplayC
		bcf		PORTE, 0 ;RS=0 for command
		bsf		PORTE, 1 ;Raise E
		tblrd*+ ;Read the first byte (cursor positioning code) into TABLAT
 		movff	TABLAT, PORTD ;Send the command byte in TABLAT to PORTD
 		bcf		PORTE, 1 ;Drop E
 		rcall	T40 ;Wait out at least 40 :sec
 		bsf		PORTE, 0 ;RS=1 for displayable data
C1
 		tblrd*+ ;Read data byte and increment pointer
 		movf	TABLAT, F ;Is it zero (EOS)?
 		bz		Done ;Yes, reach the end of string
		bsf		PORTE,1 ;Not done yet, raise E for sending data
 		movff	TABLAT, PORTD ;Send data byte
 		bcf		PORTE,1 ;Drop E
 		rcall	T40 ;Wait out at least 40 :sec
 		bra		C1 ;go read the next data byte
Done
 		return


clear1
		rcall	ClearBottomLine
		rcall	ClearTopLine
		return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; other ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ScanKeys_Table
	db B'11101110' ;Test ‘A' key
	db B'11101101' ;Test ‘3' key
	db B'11101011' ;Test ‘2' key
	db B'11100111' ;Test ‘1' key
	db B'11011110' ;Test ‘B' key, second row rightmost key
	db B'11011101' ;Test ‘6' key
	db B'11011011' ;Test ‘5' key
	db B'11010111' ;Test ‘4' key
	db B'10111110' ;Test ‘C' key, third row rightmost key
	db B'10111101' ;Test ‘9' key
	db B'10111011' ;Test ‘8' key
	db B'10110111' ;Test ‘7' key
	db B'01111110' ;Test ‘D' key, bottom row rightmost key
	db B'01111101' ;Test ‘#' key
	db B'01111011' ;Test ‘0' key
	db B'01110111' ;Test ‘*' key

ScanKeys
		clrf	KEYCODE ;Start by checking the “A" key
		movlw 	high ScanKeys_Table ;Load higher byte address of ScanKeys_Table to WREG
		movwf 	TBLPTRH ;Load higher byte address of ScanKeys_Table to TBLPTRH
		movlw	low ScanKeys_Table ;Load lower byte address of ScanKeys_Table to WREG
		movwf	TBLPTRL ;Load lower byte address of ScanKeys_Table to TBLPTRL

ScanKey_1
		tblrd*+ ;Get the table entry and increment table pointer
		swapf	TABLAT, W ;Read and swap the table data into W
		movwf	PORTD ;RD<3:0> set to the row scanning testing value
		swapf	WREG, W ;Swap expected input bit pattern to lower 4 bits
		xorwf	PORTB, W ;Compare RB<3:0> with expected bit pattern
		andlw	B'00001111' ;Z=1 if RB<3:0> match WREG<3:0>
		btfsc	STATUS, Z ;Z=0, no match, try the next key switch
		bra 	ScanKey_DONE ;Z=1, a match is found
		tblrd*+ ;increment pointer by 1, db bytes are stored in 16 bits
		incf	KEYCODE, F ;Try next key
		btfss	KEYCODE, 4 ;Stop searching with Z=0 when all 16 keys have been checked
		bra 	ScanKey_1 ;Start another search
	
ScanKey_DONE
		call 	LoopTime_10ms ;debounce
		call 	LoopTime_10ms
		return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
AnyKey
		clrf 	PORTD ;Drive 4 rows low
		movlw 	B'00001111' ;Load WREG with expected value if none pressed
		xorwf 	PORTB,W ;WREG=B'xxxx0000’ if no key is pressed
		andlw 	B'00001111' ;Force upper 4 don't care bits to 0

		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; create a buzzing sound for the keyboard ;
BuzzBuzz
		btg		PORTC, 2
		rcall	LoopTime_2.5ms

		return

Buzz_2.5ms
		movlw	.80
		movwf	BuzzTime

Buzzing
		rcall	BuzzBuzz
		decf	BuzzTime
		bnz		Buzzing

		return
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   creates a 2.5 ms delay 
LoopTime_2.5ms
       	movlw	.2
		movwf	Var1
Ruop								;outer for-loop
		movlw	.30
		movwf	Var2
Ruop2								;inner for-loop
		nop
		nop														
		decf	Var2, F
		bnz		Ruop2
		decf	Var1, F
		bnz		Ruop

		return	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PoundCheck
		movlw	B'01111101' ;represents #
		cpfseq	KEYCODE ;skip goto if equal
		goto	Continue ;# not pressed 

		rcall	ClearTopLine
		rcall	ClearBottomLine
		clrf	CharCount
		rcall	SetCursor80H
	
		return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LoopTime_20ms
		rcall	LoopTime_10ms
		rcall	LoopTime_10ms
		return

PlaySong1 ;plays happy birthday 
		clrf	WREG
		movlw	.4
		rcall	PlayD
		rcall	LoopTime_20ms
		movlw	.2
		rcall	PlayD
		rcall	LoopTime_20ms
		movlw	.6
		rcall	PlayE
		rcall	LoopTime_20ms
		movlw	.6
		rcall	PlayD
		rcall	LoopTime_20ms
	
		movlw	.0
		cpfseq	Song1Count
		bra		SecondTime

		movlw	.8
		rcall	PlayG
		rcall	LoopTime_20ms
		movlw	.10
		rcall	PlayF
		clrf	Song1Count
		rcall	LoopTime_20ms
		rcall	LoopTime_20ms
		setf	Song1Count
		bra		PlaySong1

SecondTime
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayA
		rcall	LoopTime_20ms
		movlw	.10
		rcall	PlayG
		
		return

LoopTime_100ms
		rcall	LoopTime_20ms
		rcall	LoopTime_20ms
		rcall	LoopTime_20ms
		rcall	LoopTime_20ms
		rcall	LoopTime_20ms
		return
PlaySong2 ;plays kim possible ringtone
		movlw	.12
		rcall	PlayKim
		rcall	LoopTime_100ms
		rcall	LoopTime_20ms
		rcall	LoopTime_20ms
		movlw	.12
		rcall	PlayKim
		rcall	LoopTime_100ms
		rcall	LoopTime_20ms
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayKim1
		rcall	LoopTime_100ms
		movlw	.7
		rcall	PlayKim
		return

PlaySong3 ; plays twinkle twinkle
		movlw	.7
		rcall	PlayC
		rcall	LoopTime_20ms
		movlw	.7
		rcall	PlayC	
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayG
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayG
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayA
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayA
		rcall	LoopTime_20ms
		movlw	.12
		rcall	PlayG
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayF
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayF
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayE
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayE
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayD
		rcall	LoopTime_20ms
		movlw	.8
		rcall	PlayD
		rcall	LoopTime_20ms
		movlw	.10
		rcall	PlayC

		return


PlaySOS ; play SOS
		movlw	.4
		rcall	PlayKim1
		rcall	LoopTime_100ms
		rcall	LoopTime_100ms
		movlw	.4
		rcall	PlayKim1
		rcall	LoopTime_100ms
		rcall	LoopTime_100ms
		movlw	.4
		rcall	PlayKim1
		rcall	LoopTime_100ms
		rcall	LoopTime_100ms
		movlw	.15
		rcall	PlayKim1
		rcall	LoopTime_100ms
		rcall	LoopTime_100ms
		movlw	.15
		rcall	PlayKim1
		rcall	LoopTime_100ms
		rcall	LoopTime_100ms
		movlw	.15
		rcall	PlayKim1
		rcall	LoopTime_100ms
		rcall	LoopTime_100ms
		movlw	.4
		rcall	PlayKim1
		rcall	LoopTime_100ms
		rcall	LoopTime_100ms
		movlw	.4
		rcall	PlayKim1
		rcall	LoopTime_100ms
		rcall	LoopTime_100ms
		movlw	.4
		rcall	PlayKim1
		return		
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; subroutines to play specific notes for songs ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DToggle
		btg		PORTC,3
		rcall	DLoopTime
		return
PlayD
		movwf	DCount
PlayDLoop
		movlw	.50
		movwf	DCount1
PlayDReally
		rcall	DToggle
		decf	DCount1,F
		bnz		PlayDReally
		decf	DCount,F
		bnz		PlayDLoop
		
		return
		
DLoopTime
		movlw	.8
		movwf	DLoop
D_1
		movlw	.42
		movwf	DLoop1
D_2
		nop
		nop
		decf	DLoop1,F
		bnz		D_2
		decf	DLoop,F
		bnz		D_1
		
		return


EToggle
		btg		PORTC,3
		rcall	ELoopTime
		return
PlayE
		movwf	ECount
PlayELoop
		movlw	.50
		movwf	ECount1
PlayEReally
		rcall	EToggle
		decf	ECount1,F
		bnz		PlayEReally
		decf	ECount,F
		bnz		PlayELoop
		
		return		
ELoopTime
		movlw	.8
		movwf	ELoop
E_1
		movlw	.37
		movwf	ELoop1
E_2
		nop
		nop
		decf	ELoop1,F
		bnz		E_2
		decf	ELoop,F
		bnz		E_1
		
		return
GToggle
		btg		PORTC,3
		rcall	GLoopTime
		return
PlayG
		movwf	GCount
PlayGLoop
		movlw	.50
		movwf	GCount1
PlayGReally
		rcall	GToggle
		decf	GCount1,F
		bnz		PlayGReally
		decf	GCount,F
		bnz		PlayGLoop
		
		return		
GLoopTime
		movlw	.8
		movwf	GLoop
G_1
		movlw	.31
		movwf	GLoop1
G_2
		nop
		nop
		decf	GLoop1,F
		bnz		G_2
		decf	GLoop,F
		bnz		G_1
		
		return
FToggle
		btg		PORTC,3
		rcall	FLoopTime
		return
PlayF
		movwf	FCount
PlayFLoop
		movlw	.50
		movwf	FCount1
PlayFReally
		rcall	FToggle
		decf	FCount1,F
		bnz		PlayFReally
		decf	FCount,F
		bnz		PlayFLoop
		
		return	
FLoopTime
		movlw	.8
		movwf	FLoop
F_1
		movlw	.34
		movwf	FLoop1
F_2
		nop
		nop
		decf	FLoop1,F
		bnz		F_2
		decf	FLoop,F
		bnz		F_1
		
		return

AToggle
		btg		PORTC,3
		rcall	ALoopTime
		return
PlayA
		movwf	ACount
PlayALoop
		movlw	.50
		movwf	ACount1
PlayAReally
		rcall	AToggle
		decf	ACount1,F
		bnz		PlayAReally
		decf	ACount,F
		bnz		PlayALoop
		
		return	
ALoopTime
		movlw	.8
		movwf	ALoop
A_1
		movlw	.28
		movwf	ALoop1
A_2
		nop
		nop
		decf	ALoop1,F
		bnz		A_2
		decf	ALoop,F
		bnz		A_1
		
		return



KimToggle
		btg		PORTC,3
		rcall	KimLoopTime
		return
PlayKim
		movwf	KimCount
PlayKimLoop
		movlw	.50
		movwf	KimCount1
PlayKimReally
		rcall	KimToggle
		decf	KimCount1,F
		bnz		PlayKimReally
		decf	KimCount,F
		bnz		PlayKimLoop
		
		return	
KimLoopTime
		movlw	.2
		movwf	KimLoop
Kim_1
		movlw	.12
		movwf	KimLoop1
Kim_2
		nop
		nop
		decf	KimLoop1,F
		bnz		Kim_2
		decf	KimLoop,F
		bnz		Kim_1
		
		return

Kim1Toggle
		btg		PORTC,3
		rcall	Kim1LoopTime
		return
PlayKim1
		movwf	Kim1Count
PlayKim1Loop
		movlw	.50
		movwf	Kim1Count1
PlayKim1Really
		rcall	Kim1Toggle
		decf	Kim1Count1,F
		bnz		PlayKim1Really
		decf	Kim1Count,F
		bnz		PlayKim1Loop
		
		return	
Kim1LoopTime
		movlw	.2
		movwf	Kim1Loop
Kim1_1
		movlw	.10
		movwf	Kim1Loop1
Kim1_2
		nop
		nop
		decf	Kim1Loop1,F
		bnz		Kim1_2
		decf	Kim1Loop,F
		bnz		Kim1_1
		
		return


CToggle
		btg		PORTC,3
		rcall	CLoopTime
		return
PlayC
		movwf	CCount
PlayCLoop
		movlw	.50
		movwf	CCount1
PlayCReally
		rcall	CToggle
		decf	CCount1,F
		bnz		PlayCReally
		decf	CCount,F
		bnz		PlayCLoop
		
		return
	
CLoopTime
		movlw	.8
		movwf	CLoop
C_1
		movlw	.47
		movwf	CLoop1
C_2
		nop
		nop
		decf	CLoop1,F
		bnz		C_2
		decf	CLoop,F
		bnz		C_1
		
		return


		end