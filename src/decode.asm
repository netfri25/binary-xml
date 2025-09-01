; vim: set ft=fasm:
format ELF64 executable
entry _start

OUTPUT_BUFFER_CAP equ (128 * 1024)
INPUT_BUFFER_CAP equ (OUTPUT_BUFFER_CAP * 48)

SYS_read equ 0
SYS_write equ 1

STDIN_FD equ 0
STDOUT_FD equ 1

segment readable writeable
align 64
output_buffer: rb OUTPUT_BUFFER_CAP

; and the start of the input buffer is actually at `input_buffer + 2`.
; this trick just simplifies the parsing by a lot
; the 64 padding is to allow to safely copy the leftover using zmm0
not_input_buffer: rb (INPUT_BUFFER_CAP + 2 + 64)
input_buffer equ not_input_buffer + 2
input_end equ input_buffer + INPUT_BUFFER_CAP

segment readable executable
_start:
    ; initialize the start with some constant that allow simpler parsing
    mov word [not_input_buffer], "/>"

    ; constants used in the parse input
    mov r8, qword "><zero/>"
    mov r9, qword "/><one/>"

    mov rsi, input_buffer
    mov rdx, INPUT_BUFFER_CAP

    .parse_loop:
        call read_input_buffer
        cmp r15, input_buffer
        je exit

        mov r13, r15 ; input end ptr
        cmp r15, input_end
        jb .not_full
        sub r13, 56
        .not_full:

        mov r12, input_buffer
        ; r13 already contains input end ptr
        mov r14, output_buffer
        call parse_input

        ; r14 already contains output buffer end ptr
        lea rdx, [r14 - output_buffer] ; output length
        call flush_output_buffer

        ; calculate the amount of data left
        ; if there's no data left, exit
        ; r15: actual input end ptr
        ; r12: parsed input end ptr
        mov rcx, r15
        sub rcx, r12
        jz exit

        ; copy the leftover content from the end to the start
        ; r12 points to the end of the parsed content
        vmovdqu64 zmm0, [r12]
        vmovdqu64 [input_buffer], zmm0 ; TODO: this can be an aligned mov

        ; pointer to the first empty char in the input buffer
        lea rsi, [input_buffer + rcx]

        ; amount of bytes left in the input buffer
        mov rdx, INPUT_BUFFER_CAP
        sub rdx, rcx

        jmp .parse_loop


; rdx: output len
flush_output_buffer:
    mov rax, SYS_write
    mov rdi, STDOUT_FD
    mov rsi, output_buffer
    ; mov rdx, ...
    syscall
    cmp rax, 0
    jl .error
    ret
.error:
    mov rsi, write_error_msg.text
    mov rdx, write_error_msg.len
    jmp error


; rsi: input ptr
; rdx: amount of bytes to read
; -> rax: number of bytes read
; -> r15: input end ptr
read_input_buffer:
    mov rax, SYS_read
    mov rdi, STDIN_FD
    ; mov rsi, ...
    ; mov rdx, ...
    syscall
    cmp rax, 0
    jl .error
    lea r15, [rsi + rax]
    ret
.error:
    mov rsi, read_error_msg.text
    mov rdx, read_error_msg.len
    jmp error


; r12: input ptr
; r13: input end ptr
; r14: output ptr
; -> r12: parsed input end ptr
; -> r13: unchanged
; -> r14: output end ptr
parse_input:
    ; comparing 8 bytes at once. some comparisons may overlap a bit,
    ; but it's much simpler than comparing 6/7 bytes.
    ; this is correct since the input is initialized with "/>" in input_buffer-2
    .read_byte:
        xor cl, cl
        rept 8 counter {
            cmp qword [r12-1], r8
            je .zero#counter
            cmp qword [r12-2], r9
            jne .parse_error
            or cl, 1 shl (counter - 1)
            dec r12

            .zero#counter:
            add r12, 7 ; length of "<zero/>"
        }

        mov byte [r14], cl
        inc r14
        cmp r12, r13 ; check if the input has reached the end
        jb .read_byte

    ret

.parse_error:
    mov rsi, parse_error.text
    mov rdx, parse_error.len
    jmp error ; defined in `common.asm`

segment readable
parse_error:
.text db "parse error", 10
.len = $ - .text

read_error_msg:
.text db "can't read file", 10
.len = $ - .text

write_error_msg:
.text db "can't write file", 10
.len = $ - .text

include 'common.asm'
