format ELF64 executable
entry _start

segment readable executable
_start:
.read_byte:
    mov byte [char], 0
    ; counter for the bits loop
    mov r8, 8
    .read_bit:
        ; rax = read(stdin, buffer, one.len)
        mov rax, 0
        mov rdi, 0
        mov rsi, buffer

        ; one.len is smaller than zero.len, and since over-read
        ; will break the code then we under-read
        mov rdx, one.len
        syscall

        cmp rax, 0
        je .finish_reading
        jl error

        cmp [buffer + 1], 'o'
        je .one
        cmp [buffer + 1], 'z'
        je .zero
        jmp error

        .one:
            or byte [char], 1
            mov rsi, one.text
            mov rcx, one.len
            jmp .compare_input

        .zero:
            ; read all of the remaining text for zero
            mov rax, 0
            mov rdi, 0
            lea rsi, [buffer + one.len]
            mov rdx, zero.len - one.len
            syscall

            cmp rax, zero.len - one.len
            jne error

            mov rsi, zero.text
            mov rcx, zero.len
            ; jmp .compare_input

        .compare_input:
            mov rdi, buffer
            cld
            rep cmpsb
            jne error

        ror byte [char], 1
        dec r8
        jnz .read_bit

    ; write(stdout, &char, 1)
    mov rax, 1
    mov rdi, 1
    mov rsi, char
    mov rdx, 1
    syscall
    jmp .read_byte

.finish_reading:
    cmp r8, 8
    jne error
    jmp exit

error:
    mov rax, 1
    mov rdi, 2
    mov rsi, error_msg.text
    mov rdx, error_msg.len
    syscall
    mov [error_code], 1

exit:
    ; exit(0)
    mov rax, 60
    mov rdi, [error_code]
    syscall

segment readable
error_msg:
.text db "unable to parse file", 10
.len = $ - .text

one:
.text db "<one/>"
.len = $ - .text

zero:
.text db "<zero/>"
.len = $ - .text

segment readable writeable
char db 0
error_code dq 0
buffer rb zero.len
