; multi-segment executable file template.

DATAS segment
    STRING DB 50 DUP(0)
    NUM DW ?
    STR1 DB 'Letter==$'
    STR2 DB 'Digit==$'
    STR3 DB 'Others==$'
    STR4 DB 'Place==$'   
    DIGIT DW 0         
    OTHER DW 0
    LETTER DW 0
    PLACE DW ?
    FLAG DW 0
ends

stack segment
    dw   128  dup(0)
ends

CODES segment
MAIN PROC FAR
        ASSUME CS:CODES,DS:DATAS
start: MOV AX,DATAS
       MOV DS,AX
       MOV SI,0
INPUT:
       MOV AH,1
       INT 21H
       CMP AL,0DH;回车就是13号
       JE NEXT0
       MOV STRING[SI],AL
       INC SI
       JMP INPUT  
NEXT0: MOV NUM,SI
       MOV BX,NUM
       LEA SI,STRING
NEXT:  MOV AL,[SI]
       CMP AL,30H
       JB COTHER
       CMP AL,3AH
       JBE CDIGIT 
       CMP AL,41H
       JB COTHER
       CMP AL,5AH
       JBE CLETTER
       CMP AL,61H
       JB COTHER 
       CMP AL,7AH
       JBE CLETTER            
COTHER: 
        INC OTHER
        JMP P2
CDIGIT: 
        INC DIGIT
        JMP P2
CLETTER:    
        INC LETTER
        JMP P2
P2:      
        DEC BX
        JZ OUTPUT
        INC SI
        JMP NEXT
OUTPUT:
        CALL  PRINTER
        MOV AH,9 ;LETTER
        MOV DX,SEG STR1
        MOV DS,DX
        MOV DX,OFFSET STR1
        INT 21H
              
        MOV BX,LETTER
        CALL TOTEN
        CALL  PRINTER
        ;////////////////////////
        MOV AH,9       ;DIGIT
        MOV DX,SEG STR2
        MOV DS,DX
        MOV DX,OFFSET STR2
        INT 21H
        
        MOV BX,DIGIT
        CALL TOTEN
        CALL PRINTER
        ;////////////////////////
        MOV AH,9  
        MOV DX,SEG STR3
        MOV DS,DX
        MOV DX,OFFSET STR3
        INT 21H
        
        MOV BX,OTHER   ;OTHER
        CALL TOTEN
        CALL PRINTER
        ;/////////////////////////////
        MOV AH,9 
        MOV DX,SEG STR4 ;SPACES
        MOV DS,DX
        MOV DX,OFFSET STR4
        INT 21H
        MOV BX,NUM
        LEA SI,STRING
AGAIN:
        MOV AL,20H
        CMP AL,[SI]
        JE P1
        
        DEC BX
        JZ OVER
        INC SI
        JMP AGAIN
OVER: 
        MOV PLACE,4EH
        MOV DX,PLACE
        MOV AH,2
        INT 21H
        JMP EXIT        
P1:
        INC SI
        MOV PLACE,SI
        MOV BX, PLACE
        CALL TOTEN
        CALL PRINTER
        JMP EXIT
    TOTEN PROC NEAR
        CMP BX,0
        JG P111
        MOV DL,30H
        MOV AH,2
        INT 21H
        JMP RETURN
P111:
        MOV FLAG,0
        MOV DI,10000
P15: 
        MOV DX,0
        MOV AX,BX
        DIV DI
        MOV BX,DX
        MOV DL,AL
        CMP DL,0
        JE P101
        MOV FLAG ,1
P102:              
        ADD DL,30H
        MOV AH,2
        INT 21H
        
P16:    
        MOV AX,DI
        MOV DX,0
        MOV CX,10
        DIV CX
        MOV DI,AX
        CMP DI,0
        JG P15
        JMP RETURN 
P101:
        CMP FLAG,0
        JE P16
        JMP P102
RETURN:
        RET
    TOTEN ENDP

PRINTER PROC NEAR
    MOV DL,0DH
    MOV AH,2
    INT 21H
    MOV DL,0AH
    MOV AH,2
    INT 21H
    RET
PRINTER ENDP     

EXIT:
    MOV AX,4C00H
    INT 21H



;MAIN ENDP
CODES ENDS
END START
     
