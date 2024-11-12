ORG 100h
CPU 8086

DRIVE equ 0x80
COMPORT equ 0x3f8 ;COM1
SECTOR_SIZE equ 512
COMPORT_DIV equ 1 ; 115200 / 1 = 115200

_start:
    mov ax, ds
    mov es, ax
    call fetch_drive_info

    call init_serial

    call print_debug_geometry
    call iterate_over_chs

    mov ah, 0x9
    lea dx, finished_info
    int 21h

    mov ah, 0x4C
    int 21h

init_serial:
    mov dx, COMPORT + 1
    mov al, 0
    out dx, al ; Disable interrupts

    mov dx, COMPORT + 3
    mov al, 0x80 ; Set baud rate divisor
    out dx, al

    mov dx, COMPORT + 0
    mov al, COMPORT_DIV ; Low bits
    out dx, al

    mov dx, COMPORT + 1
    mov al, 0 ; High bits
    out dx, al

    mov dx, COMPORT + 3
    mov al, 0x03 ; 8 bits - no parity - one stop bit
    out dx, al

    mov dx, COMPORT + 2
    mov al, 0xC7 ; Enable FIFO, clear, 14 byte threshold
    out dx, al

    mov dx, COMPORT + 4
    mov al, 0x0B ; IRQ enable, RTS / DSR set.
    out dx, al

    mov dx, COMPORT + 4
    mov al, 0x1E ; Enter test mode - loopback on
    out dx, al

    ; This did NOT work on my IBM P70:

;     mov dx, COMPORT + 0
;     mov al, 0xAE ; Send 0xAE to test the serial
;     out dx, al
;
;     ; Read it back to test
;     in al, dx
;     cmp al, 0xAE
;     jne serial_error

    ; We set it up correctly
    mov dx, COMPORT + 4
    mov al, 0x0F ; Disable loopback
    out dx, al
    ; Config done
    ret




%include "util.asm"
%include "debug.asm"

cylinder_info: db "Cylinder: $"
head_info: db "Head: $"
sector_info: db "Sector: $"
finished_info: db "Complete.", 13, 10, '$'
serial_error_info: db "Serial port init error", 13, 10, '$'

serial_error:
    call print_byte
    lea dx, serial_error_info
    mov ah, 0x9
    int 21h
    mov ah, 0x4C
    int 21h


transmit_buffer:
    mov cx, SECTOR_SIZE
    lea si, sector_buffer
    .lp:
        ; Transmit:
        mov dx, COMPORT + 5
        .lp_check_transmit_empty:
            in al, dx
            and al, 0x20
            test al, al
            jz .lp_check_transmit_empty ; If zero, wait
        mov dx, COMPORT
        lodsb
        out dx, al

        loop .lp
    ret

read_sector:
    ; AX - cylinder
    ; BL - head
    ; BH - sector
    push ax
    push bx
    push cx
    push dx

    mov ch, al ; Cylinder lower bits
    mov cl, 6
    shl ah, cl
    mov cl, bh ; lower bits - sector
    or cl, ah  ; High bits of cylinder

    mov dh, bl ; dh is head number
    ; Preparation is complete - CHS written, now prepare output buffer
    mov dl, DRIVE
    lea bx, sector_buffer
    mov ax, 0x0201
    int 13h

    call transmit_buffer

    pop dx
    pop cx
    pop bx
    pop ax
    ret

iterate_over_chs:
    ; ax - cylinder
    ; bl - head
    ; bh - sector
    xor ax, ax
    .loop_cylinder:
        ; Print cylinder info
;         push ax
;         lea dx, cylinder_info
;         mov ah, 9
;         int 21h
;         pop ax
;         push ax
;         call print_word
;         lea dx, NL
;         mov ah, 9
;         int 21h
;         pop ax
        ; Print cylinder info DONE
        xor bl, bl
        .loop_head:
;             push ax
;             lea dx, head_info
;             mov ah, 9
;             int 21h
;             mov al, bl
;             call print_byte
;             lea dx, NL
;             mov ah, 9
;             int 21h
;             pop ax
            mov bh, 1
            ; Print head info DONE
            .loop_sector:
;                 push ax
;                 lea dx, sector_info
;                 mov ah, 9
;                 int 21h
;                 mov al, bh
;                 call print_byte
;                 lea dx, NL
;                 mov ah, 9
;                 int 21h
;                 pop ax
                ; Print sector info DONE
                push ax
                push bx
                call print_word
                mov ah, 2
                mov dl, ' '
                int 21h
                mov ax, bx
                call print_word
                push dx
                lea dx, NL
                mov ah, 9
                int 21h
                pop dx
                pop bx
                pop ax

                call read_sector

                inc bh
                cmp bh, byte [sectors_per_track]
                jl .loop_sector
            inc bl
            cmp bl, byte [head_count]
            jl .loop_head
        ; Advance cylinder
        inc ax
        cmp ax, word [total_cylinders]
        jl .loop_cylinder
    ret

fetch_drive_info:
    mov ah, 8
    mov dl, DRIVE
    int 13h

    inc dh
    mov byte [head_count], dh

    mov ax, cx
    and ax, 0x3f
    inc ax
    mov byte [sectors_per_track], al

    mov al, ch
    mov ah, cl
    mov cl, 6
    shr ah, cl
    mov word [total_cylinders], ax
    ret


sectors_per_track: db 0
total_cylinders: dw 0
head_count: db 0

sector_buffer:
