format ELF64 executable
entry _start

segment readable executable
_start:
.char_loop:
    ; rax = read(stdin, &char, 1)
    mov rax, 0
    mov rdi, 0
    mov rsi, char
    mov rdx, 1
    syscall

    ; if (rax <= 0) goto finish
    cmp rax, 0
    jle exit

    ; iterate on each bit (from low to high) and print either "<one/>" or "<zero/>"
    mov r8, 8
    .bit_loop:
        test [char], 1
        jz .zero

        .one:
            ; <syscall>(_, one.text, one.len)
            mov rsi, one.text
            mov rdx, one.len
            jmp .bit_loop_next

        .zero:
            ; <syscall>(_, zero.text, zero.len)
            mov rsi, zero.text
            mov rdx, zero.len
            ; jmp .bit_loop_next

    .bit_loop_next:
        ; write(stdout, _, _)
        mov rax, 1
        mov rdi, 1
        syscall

        shr [char], 1
        dec r8
        jnz .bit_loop

    jmp .char_loop

exit:
    ; exit(0)
    mov rax, 60
    mov rdi, 0
    syscall


segment readable writeable
char db 0

segment readable
one:
.text db "<one/>"
.len = $ - .text

zero:
.text db "<zero/>"
.len = $ - .text
