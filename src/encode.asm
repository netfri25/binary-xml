; vim: set ft=fasm:
format ELF64 executable
entry _start

segment readable executable
_start:
    call init_input

    ; calculate the maximum possible length for the output
    mov rax, [input_len]  ; len
    mov rcx, 8 * zero.len ; max(zero.len, one.len) == zero.len + 2 bytes (alignment for <one/>)
    mul rcx
    mov [output_max_len], rax

    call init_output

    mov rdi, [output_mapped_ptr] ; dst mapped addr
    mov rsi, [input_mapped_ptr]  ; src mapped addr

    mov rcx, [input_len]

.char_loop:
    movzx rax, byte [rsi]
    popcnt rbx, rax
    mov rdx, 56
    mul rdx

    rept 7 i {
        mov r8, [table + rax + (i-1)*8]
        mov [rdi + (i-1)*8], r8
    }

    add rdi, 56
    sub rdi, rbx
    inc rsi

    loop .char_loop

    sub rdi, [output_mapped_ptr]
    mov [output_len], rdi
    call deinit

    jmp exit

include 'common.asm'
include 'table.asm'
