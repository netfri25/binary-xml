; vim: set ft=fasm:
format ELF64 executable
entry _start

BUFFER_CAP equ (1024 * 1024)

segment readable writeable
align 64
buffer: rb BUFFER_CAP

segment readable executable
_start:
    call init_input
    call mmap_input

    ; calculate the maximum possible length for the output
    mov rax, [input_len]  ; len
    shl rax, 6            ; rax *= 64
    mov [output_max_len], rax

    call init_output

    mov r10, buffer ; dst mapped addr
    mov r13, [input_mapped_ptr]  ; src mapped addr

    mov rcx, [input_len]

    ; pointer to the end of src
    lea r12, [r13 + rcx]

    ; TODO: instead of handling one byte try to handle multiple at once
    .byte_loop:
        movzx eax, byte [r13]

        ; index in the byte table. since each element in the table is
        ; 64 bytes, the index should be multiplied by 64, which is 2**6
        shl ax, 6

        ; copy from the table to the destination
        vmovdqa64 zmm3, [table + eax]
        vmovdqu64 [r10], zmm3

        ; I'm not sure if this is the most efficient approach for the length
        ; but right now this isn't the bottleneck.
        popcnt rax, rax
        add r10, 56
        sub r10, rax

        ; if the next chunk can fill the buffer, flush now.
        cmp r10, buffer + BUFFER_CAP - 56
        jb .dont_flush

        ; can be inlined but barely impacts performance.
        call flush_buffer
        .dont_flush:

        ; continue looping if the end of src ptr (r12) is
        ; still bigger than the current src ptr (r13)
        inc r13
        cmp r12, r13
        ja .byte_loop

    ; one last flush. if there's nothing to flush then
    ; it's a small wasted syscall, but barely impacts performance.
    call flush_buffer

    call deinit_input
    call truncate_output
    call close_output
    jmp exit

close_output:
    mov rax, 3
    mov rdi, [output_fd]
    syscall
    ret

flush_buffer:
    mov rax, 1
    mov rdi, [output_fd]
    mov rsi, buffer
    lea rdx, [r10 - buffer]
    add [output_len], rdx
    syscall
    mov r10, buffer ; reset the buffer to the start
    ret

include 'common.asm'
include 'table.asm'
