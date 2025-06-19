; vim: set ft=fasm:
format ELF64 executable
entry _start

segment readable executable
_start:
    call init_input

    ; rdx:rax / rcx
    mov rdx, 0
    mov rax, [input_len]
    mov rcx, 8 * one.len
    div rcx
    mov [output_max_len], rax

    call init_output

    mov rbx, [output_mapped_ptr] ; dst mapped addr
    mov rsi, [input_mapped_ptr]  ; src mapped addr

.read_byte:
    mov al, 0
    mov r9, 8
    .read_bit:
        cmp byte [rsi+1], 'z'
        je .zero
        cmp byte [rsi+1], 'o'
        je .one
        jmp .parse_error

        .zero:
            mov rdi, zero.text
            mov rcx, zero.len
            jmp .verify_input

        .one:
            or al, 1
            mov rdi, one.text
            mov rcx, one.len
            ; jmp .verify_input

        .verify_input:
            sub [input_len], rcx
            cld
            rep cmpsb
            jne .parse_error

        ror al, 1
        dec r9
        jnz .read_bit

    mov byte [rbx], al
    inc rbx
    add [output_len], 1
    cmp [input_len], 0
    jl .parse_error
    jnz .read_byte

    call deinit
    jmp exit

.parse_error:
    mov rsi, parse_error.text
    mov rdx, parse_error.len
    jmp error ; defined in `common.asm`

segment readable
parse_error:
.text db "parse error", 10
.len = $ - .text

include 'common.asm'
