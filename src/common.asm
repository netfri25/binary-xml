; vim: set ft=fasm:
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

segment readable writeable
error_code dq 0
