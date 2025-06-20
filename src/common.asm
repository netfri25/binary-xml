; vim: set ft=fasm:
segment readable executable

init_input:
    ; go to the end of redirected stdin and get the size
    mov rdx, 2  ; SEEK_END
    call seek_stdin
    mov [input_len], rax

    ; seek to the start of redirected stdin
    mov rdx, 0  ; SEEK_SET
    call seek_stdin

    ; map the redirected stdin to memory
    ; mmap(NULL, len, PROT_READ, MAP_PRIVATE, fd=0, offset=0)
    mov rsi, [input_len]  ; length
    mov rdx, 1      ; PROT_READ
    mov r10, 2      ; MAP_PRIVATE
    mov r8, 0       ; fd = 0 (stdin)
    call mmap
    mov [input_mapped_ptr], rax ; src mapped file

    ; advise sequential input, so that the kernel can release pages that have already been used
    ; in sequential order.
    ; madvise(input_mapped_ptr, input_len, MADV_SEQUENTIAL)
    mov rdi, [input_mapped_ptr]
    mov rsi, [input_len]
    mov rdx, 2 ; MADV_SEQUENTIAL
    call madvise
    ret

; [output_max_len]: output maximum length
init_output:
    ; this is kind of a hack. since I want to apply efficient writing to redirected stdout using mmap,
    ; I need to pass a fd that has been opened using O_RDWR, but redirected stdout is opened using O_WRONLY.
    ; this "hack" opens `/proc/self/fd/1` using the O_RDWR flag and then maps it to memory using mmap.
    ; open(proc_stdout_path, O_RDWR)
    mov rdi, proc_stdout_path
    mov rsi, 0x0202 ; O_RDWR | O_CREAT
    call open
    mov [output_fd], rax ; save the fd

    ; truncate the output file to have the maximum possible size
    mov rdi, [output_fd]
    mov rsi, [output_max_len]
    call ftruncate

    ; mmap output file to memory
    mov rsi, [output_max_len]
    mov r8,  [output_fd]
    mov rdx, 2 ; PROT_WRITE
    mov r10, 1 ; MAP_SHARED
    call mmap
    mov [output_mapped_ptr], rax

    ; madvise(output_mapped_ptr, output_max_len, MADV_SEQUENTIAL)
    mov rdi, rax
    mov rsi, [output_max_len]
    mov rdx, 2
    call madvise
    ret

deinit:
    ; munmap the mapped region, so that all of the pages are flushed
    mov rdi, [output_mapped_ptr]
    mov rsi, [output_max_len]
    call munmap

    mov rdi, [input_mapped_ptr]
    mov rsi, [input_len]
    call munmap

    ; truncate the output file to have the size of the amount of data written
    mov rdi, [output_fd]
    mov rsi, [output_len]
    call ftruncate
    ret

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

; rdx: seek direction (SEEK_END, SEEK_SET, SEEK_CUR)
; rax => cursor position
seek_stdin:
    ; rax = lseek(stdin, 0, rdx)
    mov rax, 8
    mov rdi, 0
    mov rsi, 0
    syscall
    cmp rax, 0
    jl .error
    ret
.error:
    mov rsi, seek_error_msg.text
    mov rdx, seek_error_msg.len
    jmp error

; rsi: len
; rdx: read write flags
; r10: visibility flags
; r8: fd
; rax => result of mmap
mmap:
    ; mmap(NULL, len, rdx, r10, r8, offset=0)
    mov rax, 9      ; syscall: mmap
    mov rdi, 0      ; addr = NULL
    mov r9, 0       ; offset = 0
    syscall
    cmp rax, 0
    jl .error
    ret
.error:
    mov rsi, mmap_error_msg.text
    mov rdx, mmap_error_msg.len
    jmp error

; rdi: ptr
; rsi: len
; rax => result of munmap
munmap:
    ; munmap(ptr, len)
    mov rax, 11     ; syscall: munmap
    syscall
    cmp rax, 0
    jl .error
    ret
.error:
    mov rsi, munmap_error_msg.text
    mov rdx, munmap_error_msg.len
    jmp error


; rdi: path
; rsi: options
; rax => fd
open:
    ; open(path, options)
    mov rax, 2
    syscall
    cmp rax, 0
    jl .error
    ret
.error:
    mov rsi, open_error_msg.text
    mov rdx, open_error_msg.len
    jmp error

; rdi: fd
; rsi: size
; rax => 0 on success
ftruncate:
    mov rax, 77
    syscall
    cmp rax, 0
    jl .error
    ret
.error:
    mov rsi, open_error_msg.text
    mov rdx, open_error_msg.len
    jmp error

; rdi: addr
; rsi: length
; rdx: flags
madvise:
    mov rax, 28
    syscall
    cmp rax, 0
    jl .error
    ret
.error:
    mov rsi, madvise_error_msg.text
    mov rdx, madvise_error_msg.len
    jmp error

segment readable writeable
error_code dq 0

segment readable writeable
input_len rq 1
input_mapped_ptr rq 1
output_len rq 1
output_max_len rq 1
output_fd rq 1
output_mapped_ptr rq 1

segment readable
seek_error_msg:
.text db "can't seek file", 10
.len = $ - .text

mmap_error_msg:
.text db "can't mmap file", 10
.len = $ - .text

munmap_error_msg:
.text db "can't munmap file", 10
.len = $ - .text

open_error_msg:
.text db "can't open file", 10
.len = $ - .text

ftruncate_error_msg:
.text db "can't ftruncate file", 10
.len = $ - .text

madvise_error_msg:
.text db "can't madvise file", 10
.len = $ - .text

one:
align 8
.text dq "<one/>"
.len = 6

zero:
align 8
.text dq "<zero/>"
.len = 7

proc_stdout_path: db "/proc/self/fd/1", 0
