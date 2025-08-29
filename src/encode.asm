; vim: set ft=fasm:
format ELF64 executable
entry _start

segment readable executable
_start:
    call init_input
    call mmap_input

    ; calculate the maximum possible length for the output
    mov rax, [input_len]  ; len
    shl rax, 6            ; rax *= 64
    mov [output_max_len], rax

    call init_output

    mov rdi, [output_mapped_ptr] ; dst mapped addr
    mov rsi, [input_mapped_ptr]  ; src mapped addr

    mov rcx, [input_len]

    ; pointer to the end of src
    lea rdx, [rsi + rcx]

    ; can't use constant in cmov lmao
    mov r8, 64

.64bytes_loop:
    ; read 64 bytes at once to `byte_buffer`
    ; this is fine to over-read.
    vmovdqa64 zmm1, [rsi]

    ; amount of bytes to process: r9 = min(64, src_end - src_ptr)
    ; either 64 at once or the leftover bytes if there's less than 64 left
    mov r9, rdx
    sub r9, rsi
    cmp r9, 64
    cmova r9, r8

    ; index inside zmm1
    xor rcx, rcx

    ; TODO: instead of handling one byte try to handle multiple at once
    .byte_loop:
        vpbroadcastb zmm2, cl    ; zmm2 = [ cl cl .. cl ]
        vpermb zmm0, zmm2, zmm1  ; zmm0 = [ zmm1[cl] zmm1[cl] .. zmm1[cl] ]
        vmovd eax, xmm0
        and rax, 0xFF

        ; index in the byte table. since each element in the table is
        ; 64 bytes, the index should be multiplied by 64, which is 8 * 2**3
        shl eax, 3

        ; copy from the table to the destination
        vmovdqa64 zmm3, [table + eax*8]
        vmovdqu64 [rdi], zmm3

        ; each length is 64 bit integer, hence indexing is prev mult by 8
        add rdi, qword [lengths + eax]

        inc rcx
        cmp rcx, r9
        jne .byte_loop

    add rsi, 64
    cmp rdx, rsi
    ja .64bytes_loop


    sub rdi, [output_mapped_ptr]
    mov [output_len], rdi
    call deinit_input
    call truncate_output
    call close_output
    jmp exit

close_output:
    mov rax, 3
    mov rdi, [output_fd]
    syscall
    ret
include 'common.asm'
include 'table.asm'
