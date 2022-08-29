CALL CLEAR
JMP START
;------------------------MAIN ROUTINE---------------------------------
START:	
		CALL MENU
		CALL MOUSE
		CALL MOUSE_LEFTCLICK
		CALL CONDITION
;------------------------MENU ROUTINE---------------------------------
MENU:
		CALL DESIGN_POS
		LEA DX, DESIGN
		CALL DISPLAY_S
		
		CALL MENU_POS
		LEA DX, STRING
		CALL DISPLAY_S
		
		CALL CHOICE_POS
		LEA DX, CHOICE
		CALL DISPLAY_S
		
		CALL CHOICE1_POS
		LEA DX, CHOICE1
		CALL DISPLAY_S
		
		CALL CHOICE2_POS
		LEA DX, CHOICE2
		CALL DISPLAY_S
		
		CALL CHOICE3_POS
		LEA DX, CHOICE3
		CALL DISPLAY_S
		
		CALL CHOICE4_POS
		LEA DX, CHOICE4
		CALL DISPLAY_S
		RET
;------------------------CONDITION ROUTINE---------------------------
CONDITION:
		MOV SI, 08H
		CMP SI, DX
		JE OPT_1
		MOV SI, 09H
		CMP SI, DX
		JE OPT_2
		MOV SI, 0AH
		CMP SI, DX
		JE OPT_3A
		MOV SI, 0BH
		CMP SI, DX
		JE EX
		CALL MOUSE_LEFTCLICK
		JMP CONDITION
		RET
;------------------------EXIT & ETC ROUTINE---------------------------
EX:
		INT 20H
;------------------------OPTION_1 ROUTINE---------------------------
OPT_1:
		CALL KILL_MOUSE
		LEA DX, OPTION_1A
		CALL DISPLAY_S
		CALL INPUT_C
			
		LEA DX, OPTION_1B
		CALL DISPLAY_S
		MOV CX, 2
			LOOP_INPUT1:
						CALL INPUT_C
						LOOP LOOP_INPUT1

		LEA DX, OPTION_1C
		CALL DISPLAY_S
		MOV CX, 2
			LOOP_INPUTT1:
						CALL INPUT_C
						LOOP LOOP_INPUTT1

		
		LEA DX, OPTION_1D
		CALL DISPLAY_S
		CALL OPT_1A
		CALL INPUT_C
		CALL CLEAR
		JMP START
OPT_3A:				;FOR JMP
		JMP OPT_3
START2:
		CALL CLEAR
		JMP START
;------------------------OPTION_2 ROUTINE---------------------------
OPT_2:
		CALL KILL_MOUSE
		LEA DX, OPTION_2A
		CALL DISPLAY_S
		LEA SI, BUFF
		MOV CX, 32
				MAKE_STRING:
						CALL INPUT_C
						CMP AL, 0DH
						JE CONTINUE
						MOV B[SI], AL
						INC SI
						LOOP MAKE_STRING
		CONTINUE:
		MOV AL, '$'
		MOV B[SI], AL
		CALL STRING_POS
		LEA DX, BUFF
		CALL DISPLAY_S
		JMP DRAGNDROP
;------------------------OPTION_3 ROUTINE---------------------------
OPT_3:
		CALL KILL_MOUSE
		LEA DX, OPTION_3A
		CALL DISPLAY_S
		MOV CX, 48
				MAKE_STRING2:
						CALL INPUT_C
						CMP AL, 0DH
						JE CONTINUE2
						LOOP MAKE_STRING2
		CONTINUE2:
		CALL CONVERTUPLO
		CONTINUE3:
		CALL INPUT_C
		CALL CLEAR
		JMP START
;------------------------DRAG_AND_DROP(OPTION 2) ROUTINE---------------------------
DRAGNDROP:	
		CALL MOUSE_SHOW
		CALL MOUSE_LEFTCLICK
		MOV SI, 00H
		CMP SI, DX
		JE START2
		MOV SI, 18H
		CMP SI, DX
		JE START2
		MOV DS, 0B800H
		MOV SI, 0
		MOV BX, CX
		MOV CX, 160
				ASD:
						ADD SI, DX
						LOOP ASD
		ADD BX, BX
		ADD SI, BX
		MOV BH, 41H
		CALL CHECKLETTER
		MOV BH, 61H
		CALL CHECKLETTER
		MOV DS, 00DF9H
		JMP DRAGNDROP
		CONTINUE4:
		MOV DS, 00DF9H
		MOV SI, DX
		CALL MOUSE_RELEASE
		CALL KILL_MOUSE
		MOV CH, DL
		CALL CLEAR_ROW_POS
		LEA DX, OPTION_2F
		CALL DISPLAY_S
		CALL MOUSE_RELEASE_POS
		LEA DX, BUFF
		CALL DISPLAY_S
		JMP DRAGNDROP
;------------------------CONVERT UPPERCASE TO LOWERCASE VICE-VERSA ROUTINE---------------------------
CONVERTUPLO:		
		MOV DS, 0B800H
		MOV SI, (18*160)+(24*2)
		MOV CX, 36
				CHECKCHAR:
						CALL CONVERSION
						BACKTOLOOP:
						INC SI, 2
						LOOP CHECKCHAR
						
		MOV DS, 00DF9H
		JMP CONTINUE3
CONVERSION:
		MOV AL, 41H
		MOV DL, 61H
		MOV CX, 26
				CONVERTCHAR:
						MOV AH, B[SI]
						CMP AL, AH
						JE CONVUPPER
						CMP DL, AH
						JE CONVLOWER
						ADD AL, 1
						ADD DL, 1
						LOOP CONVERTCHAR
		RET
CONVUPPER:
		MOV B[SI], DL
		JMP BACKTOLOOP
		RET
CONVLOWER:
		MOV B[SI], AL
		JMP BACKTOLOOP
		RET
CHECKLETTER:
		MOV CX, 26
		MOV BL, B[SI]
				CHECKLETTER3:
						CMP BL, BH
						JE CONTINUE4
						ADD BH, 1
						LOOP CHECKLETTER3
		RET
OPT_1A:
		MOV DS, 0B800H
		MOV AH, 00
		MOV SI, (20*160)+(28*2)		;REPEAT
		MOV DL, B[SI] 
		MOV BL, DL
		MOV DH, B[SI+2]
		CALL ASCII_CONV
		CALL BL_CHECKER
		MOV AL, DH
		MOV DI, (21*160)+(19*2)		;DISPLAY
		MOV SI, (18*160)+(27*2)		;CHAR		
		MOV CX, AX		
		MOV AL, B[SI]
		MOV SI, (19*160)+(27*2)		;ATTRIBUTE
		MOV DL, B[SI]
		MOV DH, B[SI+2]
		CALL ASCII_CONV
			MONKEYDLOOPY:			    
					MOV B[DI], AL
					MOV B[DI+1], DH
					INC DI, 2
					LOOP MONKEYDLOOPY
		MOV DS, 00DF9H
;------------------------BL_CHECKER ROUTINE---------------------------
BL_CHECKER:
		CMP BL, '0'
		JNE BL_CHECKER1
		RET
BL_CHECKER1:
		CMP BL, '1'
		JNE BL_CHECKER2
		SUB DH, 6
		RET
BL_CHECKER2:
		CMP BL, '2'
		JNE BL_CHECKER3
		SUB DH, 12
		RET
BL_CHECKER3:
		CMP BL, '3'
		JNE BL_CHECKER4
		SUB DH, 18
		RET
BL_CHECKER4:
		CMP BL, '4'
		JNE BL_CHECKER5
		SUB DH, 24
		RET
BL_CHECKER5:
		CMP BL, '5'
		JNE BL_CHECKER6
		SUB DH, 30
		RET
BL_CHECKER6:
		CMP BL, '6'
		JNE BL_CHECKER7
		SUB DH, 36
		RET
BL_CHECKER7:
		CMP BL, '7'
		JNE BL_CHECKER8
		SUB DH, 42
		RET
BL_CHECKER8:
		SUB DH, 48
		RET
;------------------------STRING_POSITION ROUTINE---------------------------
STRING_POS:
		CALL CLEAR
		LEA DX, OPTION_2B
		CALL DISPLAY_S
		CALL CHOICE5_POS
		LEA DX, OPTION_2C
		CALL DISPLAY_S
		CALL MOUSE
		CALL MOUSE_LEFTCLICK
		MOV DH, DL
		MOV DL, CL
		MOV BH, 0
		MOV AH, 02H
		INT 10H
		RET
;------------------------ASCII_CONV ROUTINE---------------------------
ASCII_CONV:
		CALL LETCHECK_DL
		CALL LETCHECK_DH
		SUB DL, 48
		SUB DH, 48
		SHL DH, 4
		ROR DX, 4
		RET
;------------------------MENU_POSITION ROUTINE---------------------------
MENU_POS:
		MOV AH, 02H
		MOV BH, 0
		MOV DH, 5
		MOV DL, 37
		INT 10H
		RET
;------------------------CHOICE_POSITION ROUTINE---------------------------
CHOICE_POS:
		MOV AH, 02H
		MOV BH, 0
		MOV DH, 8
		MOV DL, 10
		INT 10H
		RET
;------------------------CHOICE1_POSITION ROUTINE---------------------------
CHOICE1_POS:
		MOV AH, 02H
		MOV BH, 0
		MOV DH, 9
		MOV DL, 10
		INT 10H
		RET
;------------------------CHOICE2_POSITION ROUTINE---------------------------
CHOICE2_POS:
		MOV AH, 02H
		MOV BH, 0
		MOV DH, 10
		MOV DL, 10
		INT 10H
		RET
;------------------------CHOICE3_POSITION ROUTINE---------------------------
CHOICE3_POS:
		MOV AH, 02H
		MOV BH, 0
		MOV DH, 11
		MOV DL, 10
		INT 10H
		RET
		
;------------------------CHOICE4_POSITION ROUTINE---------------------------
CHOICE4_POS:
		MOV AH, 02H
		MOV BH, 0
		MOV DH, 17
		MOV DL, 10
		INT 10H
		RET

;------------------------CHOICE5_POSITION ROUTINE---------------------------
CHOICE5_POS:
		MOV AH, 02H
		MOV BH, 0
		MOV DH, 23
		MOV DL, 0
		INT 10H
		RET
;------------------------CLEAR_ROW_POS ROUTINE---------------------------
CLEAR_ROW_POS:
		MOV AX, SI
		MOV BH, 0
		MOV DH, AL
		MOV DL, 0
		MOV AH, 02H
		INT 10H
		RET
;------------------------MOUSE_RELEASE_POS ROUTINE---------------------------
MOUSE_RELEASE_POS:
		MOV DH, CH
		MOV DL, CL
		MOV BH, 0
		MOV AH, 02H
		INT 10H
		RET
;-----------------------DESIGN_POSITION ROUTINE---------------------------
DESIGN_POS:
		MOV AH, 02H
		MOV BH, 0
		MOV DH, 3
		MOV DL, 7
		INT 10H
		RET
;------------------------DISPLAY_STRING ROUTINE-----------------------
DISPLAY_S:
		MOV AH, 09H
		INT 21H
		RET
;------------------------DISPLAY_CHAR ROUTINE-------------------------
DISPLAY_C:
		MOV AH, 02H
		INT 21H
		RET
;------------------------INPUT_CHAR ROUTINE---------------------------
INPUT_C:
		MOV AH, 01H
		INT 21H
		RET
;------------------------INPUT_STRING ROUTINE---------------------------
INPUT_S:
		MOV AH, 0AH
		INT 21H
		RET
;------------------------CLEAR_SCREEN ROUTINE---------------------------
CLEAR:
		MOV AX, 03H
		INT 10H
		RET
;------------------------LETTER_CHECKER_DL ROUTINE---------------------------
LETCHECK_DL:
		CMP DL, 'A'
		JE SUBDL
		
		CMP DL, 'B'
		JE SUBDL
		
		CMP DL, 'C'
		JE SUBDL
		
		CMP DL, 'D'
		JE SUBDL
		
		CMP DL, 'E'
		JE SUBDL
		
		CMP DL, 'F'
		JE SUBDL
		
		RET
;------------------------LETTER_CHECKER_DH ROUTINE---------------------------
LETCHECK_DH:
		CMP DH, 'A'
		JE SUBDH
		
		CMP DH, 'B'
		JE SUBDH
		
		CMP DH, 'C'
		JE SUBDH
		
		CMP DH, 'D'
		JE SUBDH
		
		CMP DH, 'E'
		JE SUBDH
		
		CMP DH, 'F'
		JE SUBDH
		
		RET

;------------------------SUBTRACT_DL ROUTINE---------------------------			
SUBDL:
		SUB DL, 7
		RET

;------------------------SUBTRACT_DH ROUTINE---------------------------			
SUBDH:
		SUB DH, 7
		RET
;------------------------INITIALIZE_MOUSE ROUTINE---------------------------			
MOUSE:
		MOV AX, 0
		INT 33H
		
		MOV AX, 1
		INT 33H
		RET
;------------------------SHOW_MOUSE ROUTINE---------------------------			
MOUSE_SHOW:
		MOV AX, 1
		INT 33H
		RET
;------------------------GET_BUTTON_PRESS_STATUS ROUTINE---------------------------			
MOUSE_LEFTCLICK:
		MOV AX, 5
		MOV BX, 0
		INT 33H
		CMP AX, 01H
		JNE MOUSE_LEFTCLICK
		SHR CX, 03				;COLUMN
		SHR DX, 03				;ROW
		RET
;------------------------GET_MOUSE_STATUS ROUTINE---------------------------			
MOUSE_RELEASE:
		MOV AX, 6
		MOV BX, 0
		INT 33H
		CMP AX, 00H
		JNE MOUSE_RELEASE
		SHR CX, 03				;COLUMN
		SHR DX, 03				;ROW
		RET
;------------------------KILL_MOUSE ROUTINE---------------------------			
KILL_MOUSE:
		MOV AX, 2
		INT 33H
		RET

STRING DB 'MENU$'

CHOICE DB '[1] ENTER CHARACTER, ATTRIBUTE, # OF TIMES TO BE DISPLAYED$'
CHOICE1 DB '[2] ENTER STRING AND LOCATION$'
CHOICE2 DB '[3] ENTER STRING AND CONVERT UPPERCASE & LOWERCASE$'
CHOICE3 DB '[4] EXIT$'
CHOICE4 DB '                    CLICK YOUR CHOICE$'

DESIGN DB 0A, 0D, '       #--------------------------------------------------------------#'
DESIGN1 DB 0A, 0D, '       |                      *                *                      |'
DESIGN2 DB 0A, 0D, '       #--------------------------------------------------------------#'
DESIGN3 DB 0A, 0D, '       |                                                              |'
DESIGN4 DB 0A, 0D, '       |                                                              |'
DESIGN5 DB 0A, 0D, '       |                                                              |'
DESIGN6 DB 0A, 0D, '       |                                                              |'
DESIGN7 DB 0A, 0D, '       |                                                              |'
DESIGN8 DB 0A, 0D, '       |                                                              |'
DESIGN9 DB 0A, 0D, '       #--------------------------------------------------------------#$'

OPTION_1A DB 0D, 0A, '          ENTER CHARACTER: $'
OPTION_1B DB 0D, 0A, '          ENTER ATTRIBUTE: $'
OPTION_1C DB 0D, 0A, '          ENTER # OF TIMES: $'
OPTION_1D DB 0D, 0A, '          DISPLAY: $'

OPTION_2A DB 0D, 0A, '          ENTER STRING: $'
OPTION_2B DB '            USE MOUSE TO SET COORDINATES <<YOU MAY DRAG AND DROP>>$'
OPTION_2C DB '---------------------------CLICK ANYWHERE BELOW TO EXIT------------------------$'
OPTION_2F DB '                                                                               $'

OPTION_3A DB 0D, 0A, '          ENTER STRING: $'

BUFF DB 10 DUP ' '
