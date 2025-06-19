format ELF64 executable
entry _start

segment readable executable
_start:
    call init_input

    ; calculate the maximum possible length for the output
    mov rax, [input_len] ; len
    mov rcx, 8 * zero.len ; max(zero.len, one.len) == zero.len
    mul rcx
    mov [output_max_len], rax

    call init_output

    mov rdi, [output_mapped_ptr] ; dst mapped addr
    mov rbx, [input_mapped_ptr]  ; src mapped addr

.char_loop:
    ; iterate on each bit (from low to high) and print either "<one/>" or "<zero/>"
    mov r15, 8
    mov al, [rbx]
    .bit_loop:
        test al, 1
        jz .zero

        .one:
            mov rsi, one.text
            mov rcx, one.len
            jmp .bit_loop_next

        .zero:
            mov rsi, zero.text
            mov rcx, zero.len
            ; jmp .bit_loop_next

    .bit_loop_next:
        add [output_len], rcx
        ; TODO: maybe improve this using mov quad
        cld
        rep movsb
        shr al, 1
        dec r15
        jnz .bit_loop

    inc rbx
    dec [input_len]
    jnz .char_loop

    jmp exit

include 'common.asm'
