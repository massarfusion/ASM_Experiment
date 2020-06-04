; multi-segment executable file template.

data segment
    ; add your data here!
    buf 80,?,80 DUP(?)
    letter db 0
    digit db 0
    other db 0
    ten db 10
    lstr db "char number==$"
    dstr db "digit number==$"
    ostr db "others number==$"
    pkey db "press any key...$"
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    mov cx,0
    
    mov dx,offset buf
    mov ah,0ah
    int 21h
    
    mov cl,buf[1]
    mov si,(offset buf)+2
loops:
    lodsb 
     CMP AL,30H
     JB COTHER
     CMP AL,3AH
     JB CDIGIT 
     CMP AL,41H
     JB COTHER
     CMP AL,5AH
     JBE CLETTER
     CMP AL,61H
     JB COTHER 
     CMP AL,7AH
     JBE CLETTER 
CLETTER:
inc letter
jmp HUB
COTHER:
INC other
jmp HUB
CDIGIT:
inc digit 
jmp HUB
HUB:
DEC CX
JZ OUTPUT
jmp loops


OUTPUT:
;NOW HOW TO PRINT THESE CHARS?
CALL RELINE
lea dx, lstr
mov ah,9
int 21h;字母前置介绍
mov dl,letter
MOV AL,DL
MOV AH,0
CALL PRINT10;打印字母个数
call RELINE
lea dx,dstr
mov ah,9
int 21h;打印数字介绍
mov dl,digit
MOV AL,DL
MOV AH,0
CALL PRINT10;打印数字个数
call RELINE
lea dx,ostr
mov ah,9
int 21h;打印其他介绍
mov dl,other
MOV AL,DL
MOV AH,0
call PRINT10;打印其他个数
CALL RELINE
CALL TERMINATE


RELINE:
mov ah,02h
mov dl,0dh
int 21h
mov ah,02h
mov dl,0ah
int 21h
RET

PRINT10:
DIV ten
CALL PRINTAH
CMP AL,0
Jne PRINT10
RET

PRINTAH:
PUSH AX
PUSH DX
MOV DL,AH
add dl,48
MOV AH,2
INT 21H
POP DX
POP AX
RET


TERMINATE:
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h       
RET


ends

end start ; set entry point and stop the assembler.
