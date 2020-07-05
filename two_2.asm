; multi-segment executable file template.

data segment
    ; add your data here!
    pkey db "press any key...$"
    x dw 2
    y dw 2 
    zed dw 3
    w dw 4
    v dw 5
ends
;;;;(5-(2*2+3-540))/2==269 AX”¶∏√ «10D
stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    mov ax,x
    mul y
    add ax,zed
    sub ax,540
    xchg ax,v
    sub ax,v
    idiv x
    ; add your code here
            
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
