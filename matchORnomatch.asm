; multi-segment executable file template.

data segment
    ; add your data here!
    buf  50,?,50 dup(?);目标句子
    keyword 10,?,10 dup(?)
    len db 0
    shift db 0
    keylen db 0
    endindex db 0
    keywordpromp db "Your keyword$"
    sentencepromp db "Your sentance$"
    nomatch db "no match!$"
    match db "match!$"
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
    
    mov dx, offset sentencepromp
    mov ah,9
    int 21h;打印提示输入句子
    call reline;换行
    
    mov dx,offset buf
    mov ah,0ah
    int 21h;录入句子
    mov bx,0
    mov bl,buf[1]
    mov len,bl;送长度
    call reline
    
    mov dx,offset keywordpromp 
    mov ah,9
    int 21h;提示输入关键字
    call reline
    mov dx,offset keyword
    mov ah,0ah
    int 21h;录入关键字
    mov bx,0
    mov bl,keyword[1]
    mov keylen,bl;送长度
    call reline
    
    mov al, len
    sub al, keylen
    mov endindex,al;计算终结处
    
    
    mov si,offset buf
    mov di,offset keyword
    add si,2
    add di,2
    call adjustsi
    mov cx,0
    mov cl,keylen
    
compare:
    cmpsb 
    jne midfail
    loop compare
    call success
    
midfail:
    mov al,shift
    cmp al,endindex
    jl prepare
    jmp finalfail
    

prepare:
    mov si,offset buf
    mov di,offset keyword
    inc shift
    add si,2
    add di,2
    call adjustsi
    mov cx,0
    mov cl,keylen   
    jmp compare 
    
finalfail:
    lea dx,nomatch
    mov ah,9
    int 21h
    call terminate
success:
    lea dx,match
    mov ah,9
    int 21h
    call terminate
    ret

adjustsi:
    mov cx,0
    mov cl,shift
    cmp cx,0
    jle failsafe
    call myadjustai
ret
myadjustai:
    inc si
    loop myadjustai
    ret
failsafe:
    mov cx,0
    mov cl,keylen
    jmp compare


terminate:
    lea dx, pkey
    mov ah, 9
    int 21h
    mov ah, 1
    int 21h
    mov ax, 4c00h ; exit to operating system.
    int 21h         
   
reline:
    push dx
    push ax
    mov ah,02h
    mov dl,0dh
    int 21h
    mov ah,02h
    mov dl,0ah
    int 21h
    pop ax
    pop dx
ret 

       
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
