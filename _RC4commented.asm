include emu8086.inc

#DS=0600h#
 
PRINTN 'WAIT...'
MOV CX,256 ; no. of chars to display

STATE:
    MOV WORD PTR [SI],DX
    ADD SI,2
    INC DX
    LOOP STATE
PRINTN 'RC-4 RANDOM GENERATOR PROGRAM'


LEN:
    PRINT 'ENTER THE LENGHTH OF THE KEY FROM 1 TO 9= ' 
    MOV AH,01H ;READ CHARACTER FROM STANDARD INPUT
    INT 21H 
    ;This simply means that you are using function 01h of the Interrupt type 21... 
    ;where 01h means to read character from standard input, with echo, 
    ;result is stored in AL. 
    ;if there is no character in the keyboard buffer, the function waits until any key is pressed. It comes under type 21h of various interrput tables, hence the lines of code goes like these as you mentioned.
    SUB AL,'0'
    MOV CL,AL
    MOV DS:[0210H],CX
    MOV AH,02 ; write or display char function
    MOV DL,0AH
    INT 21H
    MOV DL,0DH
    INT 21H      
    
PRINTN 'ENTER THE KEY = '
MOV AH,01H ;READ CHARACTER FROM STANDARD INPUT
 
KEY:
    INT 21H
    SUB AL,'0'
    MOV [SI],AL
    ADD SI,2
    LOOP KEY

MOV CX,256 ; no. of chars to display   
MOV SI,0   ; Initialize J counter = 0
MOV DX,0
MOV [0220H],0100H 
MOV AH,02 ; display char function
MOV DL,0AH
INT 21H
MOV DL,0DH
INT 21H  

PRINT 'WAIT...' 
   
;Key-Scheduling Algorithm   
KSA:  
    MOV AX,DI   ; DI=I counter     
    DIV DS:[0210H]  ;I%LEN
    MOV BL,AH       ;Remainder into BL
    SHL BX,1              ;To reach the right memory place
    ADD SI,[BX+0200H]     ;J=J+KEY[I%LEN]
    PUSH DI               ;Save Counter in stack
    SHL DI,1              ;to point to right State[I]
    ADD SI,[DI]           ;J=J+KEY[I%LEN]+STATE[I]
    MOV AX,SI             ;J into AX to divide
    MOV DX,0H             ;Emptying DX for remainder
    DIV WORD PTR [0220H]  ;Dividing
    MOV SI,DX             ;J=(J+STATE[I]+KEY[I%LEN])%256
    PUSH SI               ;Save SI in stack
    SHL SI,1              ;Shift it to point to the right State[J]
    MOV DX,[DI]           ;Swapping
    MOV AX,[SI]           
    MOV [SI],DX
    MOV [DI],AX
    POP SI                ;Get J back to last operation
    POP DI                ;Get I back to last operation                              
    INC DI                ;I++
    LOOP KSA
    
MOV SI,0     ;Re-initailize I & J = 0
MOV DI,0 
MOV BX,0230H
MOV AH,02 ; display char function
MOV DL,0AH
INT 21H
MOV DL,0DH
INT 21H 
  

PRINT 'ENTER THE LENGHT OF THE DISERED OUTPUT  FROM 1 TO 9 = ' 

OUTPUTDIGITS:
    MOV AH,01H ;Take user input of how many bytes is the message to XOR with Key
    INT 21H 
    SUB AL,'0'
    MOV CL,AL 
PUSH CX 

;Pseudo-Random Generation Algorithm  
PRGA:                           
    INC DI    ;I++
    MOV AX,DI
    MOV DX,0H
    DIV WORD PTR [0220H];MOD256
    MOV DI,DX ;I=(I+1)%256
    PUSH DI   ; Save it in stack
    SHL DI,1  ;to point to right State[i]
    ADD SI,[DI]   ;J=J+STATE(I)
    MOV AX,SI     
    MOV DX,0H
    DIV WORD PTR [0220H];MOD256
    MOV SI,DX     ;J=(J+STATE[I])%256
    PUSH SI 
    SHL SI,1      ;to point to right State[J]
    MOV DX,[DI]   ;Swapping S[I] S[J]
    MOV AX,[SI]
    MOV [SI],DX
    MOV [DI],AX       
    MOV AX,[DI]   ;S[I] new
    ADD AX,[SI]   ;S[I]+S[J] new put in AX to divide
    MOV DX,0H     
    DIV WORD PTR [0220H];MOD256
    MOV DI,DX           ;Remainder put as index
    shl di,1            ;to point to new S[(S[I]+S[J])mod256]
    MOV AX,[DI]         ;Key byte to AX
    MOV [BX],AX         ;Key byte stored in BX
    ADD BX,2            ;Prepare new byte place for next key byte
    POP SI              ;restore J
    POP DI              ;restore I
    LOOP PRGA 
    
POP CX      ;     
MOV BX,0230H;Point to key 1st byte location
MOV AH,2H   ;Write to screen fn
MOV DL,0AH
INT 21H 
MOV DL,0DH
INT 21H     ;new line and return carriage
  
  
PRINT 'YOUR RANDOM NUMBER IS:  ' 
OUTPUT:    
       MOV AX,[BX]
       CALL PRINT_NUM_UNS  
       PRINT ' '
       ADD BX,2
       LOOP OUTPUT        
ASK:
    MOV AH,02
    MOV DL,0AH
    INT 21H 
    MOV DL,0DH
    INT 21H 
    PRINT 'DO YOU WANT TO DO ANOTHER OPERATION? PRESS (Y) FOR YES AND (N) FOR NO.' 
    MOV AH,01H
    INT 21H 
    CMP AL,89
    JE  LEN
    CMP AL,121
    JE  LEN
    CMP AL,78
    JE  FINISH
    CMP AL,110
    JE FINISH
    JMP ASK
       
FINISH:
    hlt                   ; return to operating system.
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS  ; required for print_num.

END
