org 0x500
jmp 0x0000:start

; Since the address given for the kernel is 0x7e00, we need
; to use the left shift method (hexadecimal)
; and add the offset to the base address, to run the kernel.

runningKernel db 'Running Kernel...', 0

print_string:
    lodsb
    cmp al, 0
    je end

    mov ah, 0eh
    mov bl, 15
    int 10h

    mov dx, 0
.delay_print:
    inc dx
    mov cx, 0
.time:
    inc cx
    cmp cx, 10000
    jne .time

    cmp dx, 1000
    jne .delay_print

    jmp print_string

end:
    mov ah, 0eh
    mov al, 0xd
    int 10h
    mov al, 0xa
    int 10h
    ret

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; Part to print the desired messages

    mov si, runningKernel
    call print_string

    reset:
        mov ah, 00h ; Reset disk controller
        mov dl, 0   ; Floppy disk
        int 13h

        jc reset    ; If access fails, try again

        jmp load_kernel

    load_kernel:
        ; Setting the position of the disk where kernel.asm was stored (ES:BX = [0x7E00:0x0])
        mov ax, 0x7E0    ; 0x7E0 << 1 + 0 = 0x7E00
        mov es, ax
        xor bx, bx       ; Zeroing the offset

        mov ah, 0x02     ; Read disk sector
        mov al, 20       ; Portion of sectors occupied by kernel.asm
        mov ch, 0        ; Track 0
        mov cl, 3        ; Sector 3
        mov dh, 0        ; Head 0
        mov dl, 0        ; Drive 0
        int 13h

        jc load_kernel  ; If access fails, try again

        jmp 0x7e00      ; Jump to the address sector 0x7e00, which is the kernel

times 510-($-$$) db 0 ; 512 bytes
dw 0xaa55             ; Boot signature
