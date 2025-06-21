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
    mov rbx, [input_mapped_ptr]  ; src mapped addr

    mov rdx, 0 ; offset in [input_mapped_ptr]
    mov r10, qword "<zero/>"
    mov r11, qword "<one/>"
    mov r13, 0 ; the amount of bytes to add each iteration
.char_loop:
    ; iterate on each bit (from low to high) and print either "<one/>" or "<zero/>"
    mov r14b, [rbx+rdx]
    rept 8 {
        test r14b, 1
        setz r13b
        mov rax, r11
        cmovz rax, r10
        mov [rdi], rax
        add rdi, r13
        add rdi, one.len
        shr r14b, 1
    }

    inc rdx
    cmp [input_len], rdx
    jnz .char_loop

    sub rdi, [output_mapped_ptr]
    mov [output_len], rdi
    call deinit

    jmp exit

include 'common.asm'
