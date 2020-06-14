; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$" 
    VAR1 DB 00H
ends

stack segment
    dw   128  dup(0)
ends


code segment
start:
    MOV DX,0d0aH
    PUSH DX ;PUSH IN
    MOV DL,10H 
    MOV BX,15;行数
OUTER:
    MOV CX,16; 列数
    ;MOV DL,10H          
A:
     MOV AH,02H     
     INT 21H
     INC DL
     LOOP A   
    ;换行
    MOV VAR1,DL ;暂存DL
    pop dx
    int 21h
    push cx
    mov cl,8
    ror dx,cl  
    int 21h
    ror dx,cl 
    pop cx
    push dx
    MOV DL,VAR1;暂存DL
    ;换行
    DEC BX
    CMP BX,0
    JNE OUTER
     
     
ends

end start ; set entry point and stop the assembler.
