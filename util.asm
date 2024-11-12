
print_nibble:
    cmp ax, 9
    jle .ascii_conv

    add ax, 'A'-'9'-1
.ascii_conv:
    add ax, '0'
    mov ah, 0Eh
    int 10h
    ret

print_byte:
    push cx
    push ax
    mov cl, 4
    shr ax, cl
    and ax, 0Fh
    call print_nibble

    pop ax
    and ax, 0Fh
    call print_nibble

    pop cx
    ret

print_word:
    push ax
    mov al, ah
    call print_byte
    pop ax
    call print_byte
    ret
