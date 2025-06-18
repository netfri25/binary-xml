format ELF64 executable
entry _start

; 4 MiB
BUF_CAP equ 0x400000

segment readable executable
_start:
    ; go to the end of redirected stdin and get the size
    mov rdx, 2  ; SEEK_END
    call seek_stdin
    mov [len], rax

    ; seek to the start of redirected stdin
    mov rdx, 0  ; SEEK_SET
    call seek_stdin

    ; mmap(NULL, len, PROT_READ, MAP_PRIVATE|MAP_SEQUENTIAL, fd=0, offset=0)
    mov rax, 9      ; syscall: mmap
    mov rdi, 0      ; addr = NULL
    mov rsi, [len]  ; length
    mov rdx, 1      ; PROT_READ
    mov r10, 0x8002 ; MAP_PRIVATE | MAP_SEQUENTIAL
    mov r8, 0       ; fd = 0 (stdin)
    mov r9, 0       ; offset = 0
    syscall
    cmp rax, 0
    jl mmap_error
    mov rbx, rax ; src mapped file

.char_loop:
    ; iterate on each bit (from low to high) and print either "<one/>" or "<zero/>"
    mov r15, 8
    mov al, [rbx]
    mov [char], al
    .bit_loop:
        test byte [char], 1
        jz .zero

        .one:
            mov rsi, one.text
            mov rdx, one.len
            jmp .bit_loop_next

        .zero:
            mov rsi, zero.text
            mov rdx, zero.len
            ; jmp .bit_loop_next

    .bit_loop_next:
        call write_buffer
        shr byte [char], 1
        dec r15
        jnz .bit_loop

    inc rbx
    dec [len]
    jnz .char_loop

    call flush_buffer

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
; rax => result of lseek
seek_stdin:
    ; rax = lseek(stdin, 0, rdx)
    mov rax, 8
    mov rdi, 0
    mov rsi, 0
    syscall
    cmp rax, 0
    jl .error
    ret
.error:
    mov rsi, seek_error_msg.text
    mov rdx, seek_error_msg.len
    jmp error

mmap_error:
    mov rsi, mmap_error_msg.text
    mov rdx, mmap_error_msg.len
    jmp error

; WARN: rdi, rcx, rax, rsi, rdx are overwritten
; rsi: data.ptr
; rdx: data.len
write_buffer:
.flush_loop:
    ; calculate the leftover
    mov rcx, BUF_CAP
    sub rcx, [buffer_len]

    ; if (len < leftover) break
    cmp rdx, rcx
    jb .end_flush_loop

    ; len -= leftover
    sub rdx, rcx

    ; memcpy(buffer + buffer_len, data, leftover)
    mov rdi, [buffer_len]
    add rdi, buffer
    cld
    rep movsb

    ; flush()
    push rdx
    push rsi
    call flush_buffer
    pop rsi
    pop rdx

    jmp .flush_loop

.end_flush_loop:
    ; memcpy(buffer + buffer_len, data, len)
    mov rdi, [buffer_len]
    add rdi, buffer
    mov rcx, rdx
    cld
    rep movsb

    ; buffer_len += len
    add [buffer_len], rdx
    ret

; WARN: rax, rdi, rsi, rdx are overwritten
flush_buffer:
    ; write(stdout, buffer, buffer_len)
    mov rax, 1
    mov rdi, 1
    mov rsi, buffer
    mov rdx, [buffer_len]
    syscall
    mov [buffer_len], 0 ; reset the buffer
    ret


segment readable writeable
char db 0
len dq 0
error_code dq 0

segment readable writeable
align 4096
buffer rb BUF_CAP
buffer_len dq 0

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
