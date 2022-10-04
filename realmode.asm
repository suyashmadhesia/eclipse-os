ORG 0
BITS 16
_start:
    jmp short start
    nop             
times 33 db 0

handle_zero:
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret

start:
    jmp 0x7c0:step2

step2:
    cli ; clear Interrupts
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti ; set enable Interrupts
    mov word[ss:0x00], handle_zero
    mov word[ss:0x02], 0x7c0
    int 0
    mov si, message
    call print
    mov ah, 2; Read sector command
    mov al, 1; one sector to read
    mov ch, 0; cylinder low eight bits
    mov cl, 2; Read sector two
    mov dh, 0; Head number
    mov bx, buffer
    int 0x13

    jc error

    mov si, buffer
    call print
    jmp $

error:
    mov si, error_message
    call print
    jmp $

print:
    mov bx, 0
.loop:
    lodsb ; it will load from si into al register
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret 

print_char:
    mov ah, 0x0e
    int 0x10
    ret


error_message: db 'Failed to load'

times 510-($ - $$) db 0
dw 0xAA55

buffer: