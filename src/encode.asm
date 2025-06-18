format ELF64 executable
entry _start

segment readable executable
_start:
    ; go to the end of redirected stdin and get the size
    mov rdx, 2  ; SEEK_END
    call seek_stdin
    cmp rax, 0
    jl .seek_error

    mov [len], rax

    ; seek to the start of redirected stdin
    mov rdx, 0  ; SEEK_SET
    call seek_stdin
    cmp rax, 0
    jl .seek_error

    jmp .seek_success

.seek_error:
    mov rsi, seek_error_msg.text
    mov rdx, seek_error_msg.len
    jmp error

.seek_success:
    ; mmap(NULL, len, PROT_READ, MAP_PRIVATE, fd=0, offset=0)
    mov rax, 9      ; syscall: mmap
    mov rdi, 0      ; addr = NULL
    mov rsi, [len]  ; length
    mov rdx, 1      ; PROT_READ
    mov r10, 0x8002 ; MAP_PRIVATE
    mov r8, 0       ; fd = 0 (stdin)
    mov r9, 0       ; offset = 0
    syscall

    cmp rax, 0
    jge .mmap_success

    mov rsi, mmap_error_msg.text
    mov rdx, mmap_error_msg.len
    jmp error

.mmap_success:
    mov rbx, rax

.char_loop:
    ; iterate on each bit (from low to high) and print either "<one/>" or "<zero/>"
    mov r15, 8
    mov al, [rbx]
    mov [char], al
    .bit_loop:
        test byte [char], 1
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

        shr byte [char], 1
        dec r15
        jnz .bit_loop

    inc rbx
    dec [len]
    jnz .char_loop

; jumpable. no need to `call exit`
exit:
    ; exit(error_code)
    mov rax, 60
    mov rdi, [error_code]
    syscall

; rsi: error text
; rdx: error len
error:
    mov rax, 1
    mov rdi, 2
    syscall
    mov [error_code], 1
    jmp exit

; rdx: seek direction (SEEK_END, SEEK_SET, SEEK_CUR)
seek_stdin:
    ; rax = lseek(stdin, 0, rdx)
    mov rax, 8
    mov rdi, 0
    mov rsi, 0
    syscall
    ret

segment readable writeable
char db 0
len dq 0
error_code dq 0

segment readable
seek_error_msg:
.text db "can't seek file", 10
.len = $ - .text

mmap_error_msg:
.text db "can't mmap file", 10
.len = $ - .text

one:
.text db "<one/>"
.len = $ - .text

zero:
.text db "<zero/>"
.len = $ - .text
