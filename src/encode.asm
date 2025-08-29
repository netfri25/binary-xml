; vim: set ft=fasm:
format ELF64 executable
entry _start

BUFFER_CAP equ (1024 * 1024 * 2)

segment readable writeable
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

    ; can't use constant in cmov lmao
    mov r8, 64
    mov r15, 56

.64bytes_loop:
    ; read 64 bytes at once to `byte_buffer`
    ; this is fine to over-read.
    vmovdqa64 zmm1, [r13]
    vpbroadcastb zmm5, r15b  ; zmm5 = [ 56 56 .. 56 ]
    vpopcntb zmm4, zmm1      ; zmm4 = [ popcnt(zmm1[0]) popcnt(zmm1[1]) .. popcnt(zmm1[63]) ]
    vpsubb zmm4, zmm5, zmm4  ; zmm4 = [ len(zmm1[0]) len(zmm1[1]) .. len(zmm1[63]) ]

    ; amount of bytes to process: r9 = min(64, src_end - src_ptr)
    ; either 64 at once or the leftover bytes if there's less than 64 left
    mov r9, r12
    sub r9, r13
    cmp r9, 64
    cmova r9, r8

    ; index inside zmm1
    xor rcx, rcx

    ; TODO: instead of handling one byte try to handle multiple at once
    .byte_loop:
        vpbroadcastb zmm2, cl    ; zmm2 = [ cl cl .. cl ]
        vpermb zmm0, zmm2, zmm1  ; zmm0 = [ zmm1[cl] zmm1[cl] .. zmm1[cl] ]
        vpermb zmm6, zmm2, zmm4  ; zmm4 = [ len(zmm1[cl]) len(zmm1[cl]) .. len(zmm1[cl]) ]
        vmovd eax, xmm0
        and rax, 0xFF

        ; index in the byte table. since each element in the table is
        ; 64 bytes, the index should be multiplied by 64, which is 8 * 2**3
        shl eax, 3

        ; copy from the table to the destination
        vmovdqa64 zmm3, [table + eax*8]
        vmovdqu64 [r10], zmm3

        vmovd eax, xmm6
        and rax, 0xFF
        add r10, rax

        inc rcx
        cmp rcx, r9
        jne .byte_loop

    cmp r10, buffer + BUFFER_CAP - (56 * 64)
    jb .dont_flush
    call flush_buffer
    .dont_flush:

    add r13, 64
    cmp r12, r13
    ja .64bytes_loop

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
