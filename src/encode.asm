; vim: set ft=fasm:
format ELF64 executable
entry _start

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

.char_loop:
    movzx rax, byte [rsi]
    popcnt rbx, rax

    ; index in the table. since each element in the table is 64 bytes
    ; the index should be multiplied by 64, which is 2**6
    shl rax, 6

    ; copy from the table to the destination
    vmovdqa64 zmm0, [table + rax]
    vmovdqu64 [rdi], zmm0

    ; the difference between the length of `<zero/>` and the length of `<one/>` is exactly 1 byte,
    ; so the difference when writing a full byte as "tag bits" is 8 * zero.len - popcnt
    add rdi, 8 * zero.len
    sub rdi, rbx
    inc rsi

    loop .char_loop

    sub rdi, [output_mapped_ptr]
    mov [output_len], rdi
    call deinit

    jmp exit

include 'common.asm'
include 'table.asm'
