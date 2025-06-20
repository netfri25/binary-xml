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

    ; points to the end of the input
    mov rdx, rsi
    add rdx, [input_len]

    cld
.read_byte:
    mov al, 0
    mov r9, 8
    .read_bit:
        cmp word [rsi], "<z"
        je .zero
        cmp word [rsi], "<o"
        jne .parse_error
        ; fallthrough to .one

        .one:
            or al, 1
            mov edi, "ne/>"
            add rsi, one.len
            jmp .verify_input

        .zero:
            cmp byte [rsi+2], 'e'
            jne .parse_error
            mov edi, "ro/>"
            add rsi, zero.len
            ; jmp .verify_input

        .verify_input:
            ; compares the last 4 bytes
            cmp edi, dword [rsi-4]
            jne .parse_error

        ror al, 1
        dec r9
        jnz .read_bit

    mov byte [rbx], al
    inc rbx
    cmp rsi, rdx ; check if the input has reached the end
    ja .parse_error
    jne .read_byte

    sub rbx, [output_mapped_ptr]
    mov [output_len], rbx
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
