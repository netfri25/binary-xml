; vim: set ft=fasm:
format ELF64 executable
entry _start

; TODO: try to increase the buffer for writev

segment readable executable
_start:
    call init_input
    call mmap_input

    ; calculate the maximum possible length for the output
    mov rax, [input_len]  ; len
    shl rax, 6            ; rax *= 64
    mov [output_max_len], rax

    call init_output

    mov r13, [input_mapped_ptr]  ; src mapped addr
    mov rcx, [input_len]

    ; pointer to the last 64 bytes of src
    lea r12, [r13 + rcx - 64]

    vzeroall

    mov cl, 56
    vpbroadcastb zmm6, cl

    mov cl, 1
    vpbroadcastb zmm7, cl

    .64bytes_loop:
        ; read 64 bytes at once to zmm0
        ; this is fine to over-read.
        vmovdqa64 zmm0, [r13]

        ; length = 56 - popcnt
        vpopcntb zmm1, zmm0
        vpsubb zmm1, zmm6, zmm1

        vmovdqa64 zmm2, [indices]

        mov r11, 0
        .process:
            ; select bytes using the indices given in zmm2
            ; only write to the low bytes, so they can be treated as qword
            ; zmm3 = [ k1 ? zmm0[zmm2] : 0 ]
            ; NOTE: don't forget to increment each of the bytes in zmm2
            ; zmm3 = [ byte0, byte8, byte16, .. byte56 ]
            mov rcx, 0x0101010101010101
            kmovq k1, rcx
            vpermb zmm3{k1}{z}, zmm2, zmm0

            ; zmm3 = [ table + byte0*64, table + byte8*64, .. table + byte56*64 ]
            ; each element in the table is 64 in size
            vpsllq zmm3, zmm3, 6  ; x << 6 == x * 64
            mov rcx, table
            vpbroadcastq zmm4, rcx
            vpaddq zmm3, zmm3, zmm4

            ; load the offsets inside of `iovec_buffer`
            vmovdqa64 zmm4, [offsets]

            ; iovec_ptr = iovec_buffer + sizeof(iovec) * i
            mov r10, r11
            shl r10, 4 ; x << 4 == x * 16
            add r10, iovec_buffer

            ; scatter the pointers to the iovec_buffer
            ; *8 since it's calculated in transposed chunks of 8 bytes in a 8*8 grid
            mov rcx, 0xFFFFFFFFFFFFFFFF
            kmovq k2, rcx
            vpscatterqq [r10 + zmm4*8]{k2}, zmm3

            ; scatter the lengths in the iovec_buffer
            mov rcx, 0x0101010101010101
            kmovq k1, rcx
            vpermb zmm3{k1}{z}, zmm2, zmm1

            mov rcx, 0xFFFFFFFFFFFFFFFF
            kmovq k2, rcx
            vpscatterqq [r10 + zmm4*8 + 8]{k2}, zmm3

            ; increment the indices for the next round
            vpaddq zmm2, zmm2, zmm7

            inc r11
            cmp r11, 8
            jne .process


        mov rax, 0x14
        mov rdi, [output_fd]
        mov rsi, iovec_buffer

        cmp r13, r12
        jae .last_bytes

        mov rdx, 64
        syscall

        ; the result of the `writev` syscall is
        ; the amount of bytes written to the file
        add [output_len], rax

        add r13, 64
        jmp .64bytes_loop

    .last_bytes:
        lea rdx, [r12 + 64]
        sub rdx, r13
        syscall
        add [output_len], rax

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
