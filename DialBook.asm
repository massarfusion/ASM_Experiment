; multi-segment executable file template.

data segment
    welcome db "1 for adding,2 for consulting,3 for displaying.4 for exit.$"
    order db 0
    overflowprompt db "It is over the limit.Returning to title....$"
    displayover db "Display is over.Returning to title$"
    nonedisplay db "No item here,Please add some.Returning to title...$"
    pkey db "press any key to exit...$"
    initialwrong1 db "I cannot understand.Please give a correct order$"
    addnameprompt db "input a name to save,below 20 words$"
    addnumberprompt db "input a number under 8 words$"
    consultnameprompt db "input a name to consult: $"
    consultnumberprompt db "input a number to consult$"
    totitlebuf db "Returning to title...$"
    consultfailureprompt db "No result found.Return to menu...$"
    consultsuccessprompt db "Record found,Number is:$"
    ifempty db 1
    pool db 300 dup(0)
    savednum db 0
    addnamebuf db 21,0,21 dup(0)
    addnumberbuf db 9,0,9 dup(0)
    deletenamebuf db 21,0,21 dup(0)
    consultnamebuf db 21,0,21 dup(0)
    currentindex dw -30;这个变量告诉我们，最新录入的一个的起始地址
    
    
    
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
    MOV bp,currentindex;30是一个基本的单元格长度，池子可容纳50个
    
    ; add your code here
    call welcomer
    call reline
    cmp order,1
    je adder
    cmp order,2
    je consult
    cmp order,3
    je display
    cmp order,4
    je terminate
    mov dx,offset initialwrong1
    mov ah,9
    int 21h
    call reline
    jmp start
    
    
    
;;   
welcomer:
    push dx
    push ax
    lea dx, welcome
    mov ah, 9
    int 21h 
    call reline
    mov ax,0
    mov ah,1
    int 21h
    sub al,48;输入的是ASCII的字符
    mov order,al
    pop ax  
    pop dx    ; output string at ds:dx
ret
;;
adder:
call reline
call adder_numcheck
add bp,30
mov si,bp;作为基准的地址数值。
;cleaner:mov byte ptr pool[si],0
 ;   inc si
  ;  cmp [si],0
   ; jne cleaner
mov si,bp;清理完空间后回到原先的SI
mov currentindex,bp
mov dx,offset addnameprompt
mov ah,9
int 21h
call reline
mov dx,offset addnamebuf
mov ah,0ah
int 21h
mov bx,-1
s1:inc bx
cmp byte ptr addnamebuf[bx+2],0dh
jne s1;定位到键入信息的回车键之后
fillzero:mov byte ptr addnamebuf[bx+2],0
inc bx
cmp bx,20
jne fillzero;用0补完空位,免得本次的数据写入不能完全覆盖上次的。
mov byte ptr addnamebuf[bx+2],0dh
mov cx,20
mov bx,-1
store:inc bx
mov dl,byte ptr addnamebuf[bx+2]
mov byte ptr pool[si+bx],dl
loop store
mov byte ptr pool[si+bx+1],'$';封盖，方便输出
call reline
mov dx,offset addnumberprompt
mov ah,9
int 21h
call reline
mov dx,offset addnumberbuf
mov ah,0ah
int 21h
mov bx,-1
clear2:inc bx
cmp byte ptr addnumberbuf[bx+2],0dh
jne clear2
mov byte ptr addnumberbuf[bx+2],'$'
add si,21
mov cx,8
mov bx,-1
storenumber:
inc bx
mov dl,byte ptr addnumberbuf[bx+2]
mov byte ptr pool[si+bx],dl
loop storenumber
mov byte ptr pool[si+bx+1],'$'
call reline
mov dx,offset totitlebuf
mov ah,9
int 21h
call reline
inc savednum
mov ifempty,0;表示非空
jmp start

;;;;;;;
adder_numcheck:
cmp savednum,10
jge start_overflow
ret
start_overflow:
push ax
push dx
mov dx , offset overflowprompt
mov ah,9
int 21h
pop dx
pop ax
jmp start
;;;;;;;
;;;;;;;
;;;;;;;
consult:
mov dx,offset consultnameprompt
mov ah,9
int 21h
mov dx,offset consultnamebuf
mov ah,10
int 21h
mov bx,-1
c1:inc bx
cmp byte ptr consultnamebuf[bx+2],0dh
jne c1
c2:mov byte ptr consultnamebuf[bx+2],0
inc bx
cmp bx,20
jne c2
mov byte ptr consultnamebuf[bx+2],0dh
call reline
mov bp,offset pool
sub bp,30
push currentindex
push bx;
lea bx,pool
add bx,currentindex
mov currentindex,bx
pop bx;
outer:
mov cx,20
add bp,30
;;;;?
cmp bp,currentindex
jg fail
MOV SI,OFFSET consultnamebuf
add si,2
MOV DI,bp
jle inner
inner:
cmpsb
jnz outer
loop inner
jmp success
fail:
mov dx,offset consultfailureprompt
mov ah,9
int 21h
call reline
pop currentindex
jmp start
success:
mov dx,offset consultsuccessprompt
mov ah,9
int 21h
MOV dx,bp
add dx,21
mov ah,9
int 21h
pop currentindex
call reline
jmp start


jmp start

;;;;;;;
display:
call reline
cmp ifempty,1
je emptyexc
mov bx,0
mov bp,offset pool
sub bp,30
circle:
push bp
add bp,30
sub bp,offset pool
cmp bp,currentindex
jg jumpout
pop bp
add bp,30
mov dx,bp
mov ah,9
int 21h
call reline
add dx,21
mov ah,9
int 21h
call reline
jmp circle
;circle
emptyexc:
push dx
push ax
mov dx,offset nonedisplay;无记录的错误提示
mov ah,9
int 21h
call reline
pop ax
pop dx
jmp start
jumpout:
mov dx,offset displayover
mov ah,9
int 21h
call reline
jmp start

jmp start
;;;;;;;
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

terminate:
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ret

ends

end start ; set entry point and stop the assembler.
