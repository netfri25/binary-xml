; vim: set ft=fasm:
SYS_read equ 0
SYS_write equ 1

STDIN_FD equ 0
STDOUT_FD equ 1

segment readable executable

; doesn't return
; jumpable. no need to `call exit`
exit:
    ; exit(error_code)
    mov rax, 60
    mov rdi, [error_code]
    syscall

; doesn't return
; rsi: error text
; rdx: error len
error:
    mov rax, 1
    mov rdi, 2
    syscall
    mov [error_code], 1
    jmp exit

write_error:
    mov rsi, write_error_msg.text
    mov rdx, write_error_msg.len
    jmp error

read_error:
    mov rsi, read_error_msg.text
    mov rdx, read_error_msg.len
    jmp error

segment readable writeable
error_code dq 0

segment readable
read_error_msg:
.text db "can't read file", 10
.len = $ - .text

write_error_msg:
.text db "can't write file", 10
.len = $ - .text
