; vim: set ft=fasm:
format ELF64 executable
entry _start

INPUT_BUFFER_CAP equ (128 * 1024)
OUTPUT_BUFFER_CAP equ (INPUT_BUFFER_CAP * 56 + 8)

SYS_read equ 0
SYS_write equ 1

STDIN_FD equ 0
STDOUT_FD equ 1

segment readable writeable
align 64
input_buffer: rb INPUT_BUFFER_CAP
align 64
output_buffer: rb OUTPUT_BUFFER_CAP

segment readable executable
_start:
    .read_loop:
        ; read to the input buffer
        mov rax, SYS_read
        mov rdi, STDIN_FD
        mov rsi, input_buffer
        mov rdx, INPUT_BUFFER_CAP
        syscall

        ; exit if no more bytes left, or print error when error occures
        cmp rax, 0
        je exit
        jl read_error

        ; initialize pointers to the buffers
        mov rsi, input_buffer
        mov rdi, output_buffer

        ; the amount of bytes read is the number of iterations
        mov rcx, rax

        .byte_loop:
            movzx eax, byte [rsi]

            ; each item in the table is 64 bytes in size (56 maximum string length + 8 bytes for alignment).
            ; which is 2**6
            shl eax, 6

            ; copy from the table to the destination
            vmovdqa64 zmm0, [table + eax]
            vmovdqu64 [rdi], zmm0

            ; advance by the actual string length: 56 - popcnt
            popcnt rax, rax
            add rdi, 56
            sub rdi, rax

            ; next byte
            inc rsi
            loop .byte_loop


        ; flush the output buffer
        lea rdx, [rdi - output_buffer] ; bytes written count
        mov rax, SYS_write
        mov rdi, STDOUT_FD
        mov rsi, output_buffer
        syscall
        cmp rax, 0
        jl write_error
        jmp .read_loop

include 'common.asm'
include 'table.asm'
