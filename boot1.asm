org 0x7c00             ; Set origin to 0x7c00 (where bootloader typically loads)
jmp 0x0000:start       ; Jump to the label 'start'

start:                 ; Start of the bootloader code
    xor ax, ax         ; Clear ax register
    mov ds, ax         ; Set data segment ds to 0
    mov es, ax         ; Set extra segment es to 0

    mov ax, 0x50       ; Load the address 0x50 (shifted to 0x500 for boot2.asm)
    mov es, ax         ; Set es to 0x500
    xor bx, bx         ; Clear bx (position = es<<1 + bx)

    jmp reset          ; Jump to the 'reset' subroutine

reset:
    mov ah, 00h        ; Reset disk controller
    mov dl, 0          ; Select floppy disk
    int 13h            ; BIOS disk interrupt

    jc reset           ; If access fails, retry

    jmp load           ; Jump to the 'load' subroutine

load:
    mov ah, 02h        ; Read sector from disk
    mov al, 1          ; Number of sectors occupied by boot2
    mov ch, 0          ; Track 0
    mov cl, 2          ; Sector 2
    mov dh, 0          ; Head 0
    mov dl, 0          ; Drive 0
    int 13h            ; BIOS disk interrupt

    jc load            ; If access fails, retry

    jmp 0x500          ; Jump to sector address 0x500 (start of boot2)

times 510-($-$$) db 0 ; Fill remaining bytes with zeros (to complete 512 bytes)
dw 0xaa55             ; Boot signature (0xaa55)

