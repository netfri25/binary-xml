; vim: set ft=fasm:
format ELF64 executable
entry _start

segment readable writeable
align 64
popcnt_buffer: db 64 dup 0
align 64
byte_buffer: db 64 dup 0

segment readable executable
_start:
    call init_input

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
    vmovdqa64 zmm1, [rsi]
    vmovdqa64 [byte_buffer], zmm1

    ; evaluate the popcnt of each of the bytes and store it in `popcnt_buffer`
    vpopcntb zmm2, zmm1
    vmovdqa64 [popcnt_buffer], zmm2

    ; bytes_to_process: r9 = min(64, src_end - src_ptr)
    mov r9, rdx
    sub r9, rsi
    cmp r9, 64
    cmova r9, r8

    ; index
    xor rcx, rcx

    .byte_loop:
        ; index in the byte table. since each element in the table is
        ; 64 bytes, the index should be multiplied by 64, which is 2**6
        movzx rax, byte [byte_buffer + rcx]
        shl rax, 6

        ; copy from the table to the destination
        vmovdqa64 zmm0, [table + rax]
        vmovdqu64 [rdi], zmm0

        ; the difference between the length of `<zero/>` and the length
        ; of `<one/>` is exactly 1 byte, so the difference when writing
        ; a full byte as "tag bits" is 8 * zero.len - popcnt
        add rdi, 8 * zero.len
        movzx rbx, byte [popcnt_buffer + rcx]
        sub rdi, rbx

        inc rcx
        cmp rcx, r9
        jne .byte_loop

    add rsi, 64
    cmp rdx, rsi
    ja .64bytes_loop


    sub rdi, [output_mapped_ptr]
    mov [output_len], rdi
    call deinit
    jmp exit

include 'common.asm'
include 'table.asm'
