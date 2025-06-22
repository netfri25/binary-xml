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

    xor al, al
    rept 8 counter {
        mov rcx, qword [rsi]
        cmp cx, "<z"
        je .zero2#counter
        cmp cx, "<o"
        jne .parse_error
        ; fallthrough to .one

        ; .one:
            or al, 1 shl (counter - 1)

            mov edi, "ne/>"
            add rsi, one.len
            jmp .verify_input2#counter

        .zero2#counter:
            shr rcx, 1 * 8
            cmp ch, 'e'
            jne .parse_error

            mov edi, "ro/>"
            add rsi, zero.len
            ; jmp .verify_input

        .verify_input2#counter:
            ; compares the last 4 bytes
            shr rcx, 2 * 8
            cmp edi, ecx
            jne .parse_error
    }

    mov byte [rbx], al
    inc rbx
    cmp rsi, rdx ; check if the input has reached the end
    ja .parse_error
    je .end

    mov r8, "><zero/>"
    mov r9, "><one/>"
    shl r9, 8 ; it should be in the string but i dont have power to check how to do this

.read_byte:
    xor al, al
    rept 8 counter {
        mov rcx, qword [rsi-1]
        cmp rcx, r8
        je .zero#counter
        shl rcx, 8
        cmp rcx, r9
        jne .parse_error
        or al, 1 shl (counter - 1)
        dec rsi

        .zero#counter:
        add rsi, zero.len
    }

    mov byte [rbx], al
    inc rbx
    cmp rsi, rdx ; check if the input has reached the end
    ja .parse_error
    jne .read_byte

.end:

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
