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
        cmp byte [rsi], '<'
        jne .parse_error
        cmp byte [rsi+1], 'z'
        je .zero
        cmp byte [rsi+1], 'o'
        je .one
        jmp .parse_error

        .zero:
            mov rdi, zero.text + 2
            mov rcx, zero.len - 2
            jmp .verify_input

        .one:
            or al, 1
            mov rdi, one.text + 2
            mov rcx, one.len - 2
            ; jmp .verify_input

        .verify_input:
            add rsi, 2
            ; TODO: this can be replaced with a single cmp by using an 8 bit register
            ; this compares either 4 or 5 bytes
            rep cmpsb
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
