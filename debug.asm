print_debug_geometry:
    lea dx, cylinders_total_info
    mov ah, 9
    int 21h
    mov ax, word [total_cylinders]
    call print_word

    lea dx, sectors_per_track_info
    mov ah, 9
    int 21h

    mov al, byte [sectors_per_track]
    call print_byte

    lea dx, head_count_info
    mov ah, 9
    int 21h

    mov al, byte [head_count]
    call print_byte

    lea dx, NL
    mov ah, 9
    int 21h
    ret



cylinders_total_info: db "Total Cylinders: $"
sectors_per_track_info: db 13, 10, "Sectors per Track: $"
head_count_info: db 13, 10, "Head Count: $"
NL: db 13, 10, '$'
