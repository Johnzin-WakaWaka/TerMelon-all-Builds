org 0x7C00

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    call cls
    call hdr
.loop:
    call prompt
    call read
    call lower
    call cmd
    jmp .loop

cls:
    mov ax, 0xB800
    mov es, ax
    xor di, di
    mov cx, 2000
    mov ah, 0x07
    mov al, ' '
.fill: stosw
    loop .fill
    ret

hdr: mov si, hdr_msg
    call print
    ret

prompt: mov si, prompt_msg
    call print
    ret

read:
    xor di, di
.r: mov ah, 0
    int 0x16
    cmp al, 13
    je .end
    cmp al, 8
    je .bs
    mov [buf+di], al
    inc di
    mov ah, 0x0E
    int 0x10
    cmp di, 63
    jl .r
    jmp .end
.bs: cmp di, 0
    je .r
    dec di
    mov ah, 0x0E
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    jmp .r
.end: mov byte [buf+di], 0
    ret

lower:
    mov si, buf
    mov di, clean_buf
.l: lodsb
    or al, 0
    jz .done
    cmp al, 'A'
    jb .keep
    cmp al, 'Z'
    ja .keep
    add al, 32
.keep: stosb
    jmp .l
.done: mov byte [di], 0
    ret

cmd:
    mov si, clean_buf
    mov di, cmd_help
    call strcmp
    cmp ax, 1
    je .dohelp
    mov di, cmd_ver
    call strcmp
    cmp ax, 1
    je .dover
    mov di, cmd_cls
    call strcmp
    cmp ax, 1
    je .docls
    mov si, err
    jmp print
.dohelp:
    mov si, msg_help
    jmp print
.dover:
    mov si, msg_ver
    jmp print
.docls:
    call cls
    jmp hdr

strcmp:
.next: lodsb
    cmp al, [di]
    jne .fail
    cmp al, 0
    je .ok
    inc di
    jmp .next
.ok: mov ax, 1
    ret
.fail: xor ax, ax
    ret

print:
    pusha
.p: lodsb
    or al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp .p
.done: popa
    ret

; ---- Dados ----
hdr_msg db 13,10,"TerMelon 0.01 - Terminal MS-DOS Bootavel",13,10,0
prompt_msg db 13,10,"C:\\> ",0
msg_help db "Comandos: HELP, VER, CLS",13,10,0
msg_ver db "Versao: TerMelon 0.01",13,10,0
err db "Comando invalido",13,10,0
cmd_help db "help",0
cmd_ver db "ver",0
cmd_cls db "cls",0
buf times 64 db 0
clean_buf times 64 db 0

times 510-($-$$) db 0
dw 0xAA55
