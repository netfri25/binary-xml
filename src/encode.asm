; vim: set ft=fasm:
format ELF64 executable
entry _start

segment readable executable
_start:
    call init_input

    ; calculate the maximum possible length for the output
    mov rax, [input_len]  ; len
    mov rcx, 8 * zero.len ; max(zero.len, one.len) == zero.len + 2 bytes (alignment for <one/>)
    mul rcx
    mov [output_max_len], rax

    call init_output

    mov rdi, [output_mapped_ptr] ; dst mapped addr
    mov rbx, [input_mapped_ptr]  ; src mapped addr

    ; pointer to the end of the input
    mov rdx, [input_mapped_ptr]
    add rdx, [input_len]

    ; contains the strings to write, for faster mov
    mov r10, qword "<zero/>"
    mov r11, qword "<one/>"

    ; will be used to store an offset
    mov r13b, 0
.char_loop:
    ; iterate on each bit (from low to high) and print either "<one/>" or "<zero/>"
    mov r14b, [rbx]
    rept 8 counter {
        ; since the zero tag has one more character than the one tag, we want
        ; to offset by 1 on each 0 bit, so the setz instruction assigns r13b to be the offset
        test r14b, 1
        setz r13b
        mov rax, r11
        cmovz rax, r10
        mov [rdi+(counter-1)*one.len], rax
        add rdi, r13
        shr r14b, 1
    }

    add rdi, 8*one.len

    ; I tried using the `loop` instruction here, but it only supports rel8 jumps.
    inc rbx
    cmp rbx, rdx
    jb .char_loop

    sub rdi, [output_mapped_ptr]
    mov [output_len], rdi
    call deinit

    jmp exit

include 'common.asm'
