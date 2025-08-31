segment readable writeable
; each chunk of 64 bytes will contain 64 "write calls".
; each "write call" is a pointer to the data and a length.
; size of a write call: 16 bytes
align 64
iovec_buffer:
rq 16 * 64

; offsets of `struct iovec` in the iovec buffer
align 64
offsets:
dq  0x00, 0x10, 0x20, 0x30,  0x40, 0x50, 0x60, 0x70

; indices to pick the bytes from the 64 bytes source register
align 64
indices:
dq 0x00
dq 0x08
dq 0x10
dq 0x18
dq 0x20
dq 0x28
dq 0x30
dq 0x38

segment readable
align 64
table:
db "<zero/><zero/><zero/><zero/><zero/><zero/><zero/><zero/>", 8 dup 0
db "<one/><zero/><zero/><zero/><zero/><zero/><zero/><zero/>", 9 dup 0
db "<zero/><one/><zero/><zero/><zero/><zero/><zero/><zero/>", 9 dup 0
db "<one/><one/><zero/><zero/><zero/><zero/><zero/><zero/>", 10 dup 0
db "<zero/><zero/><one/><zero/><zero/><zero/><zero/><zero/>", 9 dup 0
db "<one/><zero/><one/><zero/><zero/><zero/><zero/><zero/>", 10 dup 0
db "<zero/><one/><one/><zero/><zero/><zero/><zero/><zero/>", 10 dup 0
db "<one/><one/><one/><zero/><zero/><zero/><zero/><zero/>", 11 dup 0
db "<zero/><zero/><zero/><one/><zero/><zero/><zero/><zero/>", 9 dup 0
db "<one/><zero/><zero/><one/><zero/><zero/><zero/><zero/>", 10 dup 0
db "<zero/><one/><zero/><one/><zero/><zero/><zero/><zero/>", 10 dup 0
db "<one/><one/><zero/><one/><zero/><zero/><zero/><zero/>", 11 dup 0
db "<zero/><zero/><one/><one/><zero/><zero/><zero/><zero/>", 10 dup 0
db "<one/><zero/><one/><one/><zero/><zero/><zero/><zero/>", 11 dup 0
db "<zero/><one/><one/><one/><zero/><zero/><zero/><zero/>", 11 dup 0
db "<one/><one/><one/><one/><zero/><zero/><zero/><zero/>", 12 dup 0
db "<zero/><zero/><zero/><zero/><one/><zero/><zero/><zero/>", 9 dup 0
db "<one/><zero/><zero/><zero/><one/><zero/><zero/><zero/>", 10 dup 0
db "<zero/><one/><zero/><zero/><one/><zero/><zero/><zero/>", 10 dup 0
db "<one/><one/><zero/><zero/><one/><zero/><zero/><zero/>", 11 dup 0
db "<zero/><zero/><one/><zero/><one/><zero/><zero/><zero/>", 10 dup 0
db "<one/><zero/><one/><zero/><one/><zero/><zero/><zero/>", 11 dup 0
db "<zero/><one/><one/><zero/><one/><zero/><zero/><zero/>", 11 dup 0
db "<one/><one/><one/><zero/><one/><zero/><zero/><zero/>", 12 dup 0
db "<zero/><zero/><zero/><one/><one/><zero/><zero/><zero/>", 10 dup 0
db "<one/><zero/><zero/><one/><one/><zero/><zero/><zero/>", 11 dup 0
db "<zero/><one/><zero/><one/><one/><zero/><zero/><zero/>", 11 dup 0
db "<one/><one/><zero/><one/><one/><zero/><zero/><zero/>", 12 dup 0
db "<zero/><zero/><one/><one/><one/><zero/><zero/><zero/>", 11 dup 0
db "<one/><zero/><one/><one/><one/><zero/><zero/><zero/>", 12 dup 0
db "<zero/><one/><one/><one/><one/><zero/><zero/><zero/>", 12 dup 0
db "<one/><one/><one/><one/><one/><zero/><zero/><zero/>", 13 dup 0
db "<zero/><zero/><zero/><zero/><zero/><one/><zero/><zero/>", 9 dup 0
db "<one/><zero/><zero/><zero/><zero/><one/><zero/><zero/>", 10 dup 0
db "<zero/><one/><zero/><zero/><zero/><one/><zero/><zero/>", 10 dup 0
db "<one/><one/><zero/><zero/><zero/><one/><zero/><zero/>", 11 dup 0
db "<zero/><zero/><one/><zero/><zero/><one/><zero/><zero/>", 10 dup 0
db "<one/><zero/><one/><zero/><zero/><one/><zero/><zero/>", 11 dup 0
db "<zero/><one/><one/><zero/><zero/><one/><zero/><zero/>", 11 dup 0
db "<one/><one/><one/><zero/><zero/><one/><zero/><zero/>", 12 dup 0
db "<zero/><zero/><zero/><one/><zero/><one/><zero/><zero/>", 10 dup 0
db "<one/><zero/><zero/><one/><zero/><one/><zero/><zero/>", 11 dup 0
db "<zero/><one/><zero/><one/><zero/><one/><zero/><zero/>", 11 dup 0
db "<one/><one/><zero/><one/><zero/><one/><zero/><zero/>", 12 dup 0
db "<zero/><zero/><one/><one/><zero/><one/><zero/><zero/>", 11 dup 0
db "<one/><zero/><one/><one/><zero/><one/><zero/><zero/>", 12 dup 0
db "<zero/><one/><one/><one/><zero/><one/><zero/><zero/>", 12 dup 0
db "<one/><one/><one/><one/><zero/><one/><zero/><zero/>", 13 dup 0
db "<zero/><zero/><zero/><zero/><one/><one/><zero/><zero/>", 10 dup 0
db "<one/><zero/><zero/><zero/><one/><one/><zero/><zero/>", 11 dup 0
db "<zero/><one/><zero/><zero/><one/><one/><zero/><zero/>", 11 dup 0
db "<one/><one/><zero/><zero/><one/><one/><zero/><zero/>", 12 dup 0
db "<zero/><zero/><one/><zero/><one/><one/><zero/><zero/>", 11 dup 0
db "<one/><zero/><one/><zero/><one/><one/><zero/><zero/>", 12 dup 0
db "<zero/><one/><one/><zero/><one/><one/><zero/><zero/>", 12 dup 0
db "<one/><one/><one/><zero/><one/><one/><zero/><zero/>", 13 dup 0
db "<zero/><zero/><zero/><one/><one/><one/><zero/><zero/>", 11 dup 0
db "<one/><zero/><zero/><one/><one/><one/><zero/><zero/>", 12 dup 0
db "<zero/><one/><zero/><one/><one/><one/><zero/><zero/>", 12 dup 0
db "<one/><one/><zero/><one/><one/><one/><zero/><zero/>", 13 dup 0
db "<zero/><zero/><one/><one/><one/><one/><zero/><zero/>", 12 dup 0
db "<one/><zero/><one/><one/><one/><one/><zero/><zero/>", 13 dup 0
db "<zero/><one/><one/><one/><one/><one/><zero/><zero/>", 13 dup 0
db "<one/><one/><one/><one/><one/><one/><zero/><zero/>", 14 dup 0
db "<zero/><zero/><zero/><zero/><zero/><zero/><one/><zero/>", 9 dup 0
db "<one/><zero/><zero/><zero/><zero/><zero/><one/><zero/>", 10 dup 0
db "<zero/><one/><zero/><zero/><zero/><zero/><one/><zero/>", 10 dup 0
db "<one/><one/><zero/><zero/><zero/><zero/><one/><zero/>", 11 dup 0
db "<zero/><zero/><one/><zero/><zero/><zero/><one/><zero/>", 10 dup 0
db "<one/><zero/><one/><zero/><zero/><zero/><one/><zero/>", 11 dup 0
db "<zero/><one/><one/><zero/><zero/><zero/><one/><zero/>", 11 dup 0
db "<one/><one/><one/><zero/><zero/><zero/><one/><zero/>", 12 dup 0
db "<zero/><zero/><zero/><one/><zero/><zero/><one/><zero/>", 10 dup 0
db "<one/><zero/><zero/><one/><zero/><zero/><one/><zero/>", 11 dup 0
db "<zero/><one/><zero/><one/><zero/><zero/><one/><zero/>", 11 dup 0
db "<one/><one/><zero/><one/><zero/><zero/><one/><zero/>", 12 dup 0
db "<zero/><zero/><one/><one/><zero/><zero/><one/><zero/>", 11 dup 0
db "<one/><zero/><one/><one/><zero/><zero/><one/><zero/>", 12 dup 0
db "<zero/><one/><one/><one/><zero/><zero/><one/><zero/>", 12 dup 0
db "<one/><one/><one/><one/><zero/><zero/><one/><zero/>", 13 dup 0
db "<zero/><zero/><zero/><zero/><one/><zero/><one/><zero/>", 10 dup 0
db "<one/><zero/><zero/><zero/><one/><zero/><one/><zero/>", 11 dup 0
db "<zero/><one/><zero/><zero/><one/><zero/><one/><zero/>", 11 dup 0
db "<one/><one/><zero/><zero/><one/><zero/><one/><zero/>", 12 dup 0
db "<zero/><zero/><one/><zero/><one/><zero/><one/><zero/>", 11 dup 0
db "<one/><zero/><one/><zero/><one/><zero/><one/><zero/>", 12 dup 0
db "<zero/><one/><one/><zero/><one/><zero/><one/><zero/>", 12 dup 0
db "<one/><one/><one/><zero/><one/><zero/><one/><zero/>", 13 dup 0
db "<zero/><zero/><zero/><one/><one/><zero/><one/><zero/>", 11 dup 0
db "<one/><zero/><zero/><one/><one/><zero/><one/><zero/>", 12 dup 0
db "<zero/><one/><zero/><one/><one/><zero/><one/><zero/>", 12 dup 0
db "<one/><one/><zero/><one/><one/><zero/><one/><zero/>", 13 dup 0
db "<zero/><zero/><one/><one/><one/><zero/><one/><zero/>", 12 dup 0
db "<one/><zero/><one/><one/><one/><zero/><one/><zero/>", 13 dup 0
db "<zero/><one/><one/><one/><one/><zero/><one/><zero/>", 13 dup 0
db "<one/><one/><one/><one/><one/><zero/><one/><zero/>", 14 dup 0
db "<zero/><zero/><zero/><zero/><zero/><one/><one/><zero/>", 10 dup 0
db "<one/><zero/><zero/><zero/><zero/><one/><one/><zero/>", 11 dup 0
db "<zero/><one/><zero/><zero/><zero/><one/><one/><zero/>", 11 dup 0
db "<one/><one/><zero/><zero/><zero/><one/><one/><zero/>", 12 dup 0
db "<zero/><zero/><one/><zero/><zero/><one/><one/><zero/>", 11 dup 0
db "<one/><zero/><one/><zero/><zero/><one/><one/><zero/>", 12 dup 0
db "<zero/><one/><one/><zero/><zero/><one/><one/><zero/>", 12 dup 0
db "<one/><one/><one/><zero/><zero/><one/><one/><zero/>", 13 dup 0
db "<zero/><zero/><zero/><one/><zero/><one/><one/><zero/>", 11 dup 0
db "<one/><zero/><zero/><one/><zero/><one/><one/><zero/>", 12 dup 0
db "<zero/><one/><zero/><one/><zero/><one/><one/><zero/>", 12 dup 0
db "<one/><one/><zero/><one/><zero/><one/><one/><zero/>", 13 dup 0
db "<zero/><zero/><one/><one/><zero/><one/><one/><zero/>", 12 dup 0
db "<one/><zero/><one/><one/><zero/><one/><one/><zero/>", 13 dup 0
db "<zero/><one/><one/><one/><zero/><one/><one/><zero/>", 13 dup 0
db "<one/><one/><one/><one/><zero/><one/><one/><zero/>", 14 dup 0
db "<zero/><zero/><zero/><zero/><one/><one/><one/><zero/>", 11 dup 0
db "<one/><zero/><zero/><zero/><one/><one/><one/><zero/>", 12 dup 0
db "<zero/><one/><zero/><zero/><one/><one/><one/><zero/>", 12 dup 0
db "<one/><one/><zero/><zero/><one/><one/><one/><zero/>", 13 dup 0
db "<zero/><zero/><one/><zero/><one/><one/><one/><zero/>", 12 dup 0
db "<one/><zero/><one/><zero/><one/><one/><one/><zero/>", 13 dup 0
db "<zero/><one/><one/><zero/><one/><one/><one/><zero/>", 13 dup 0
db "<one/><one/><one/><zero/><one/><one/><one/><zero/>", 14 dup 0
db "<zero/><zero/><zero/><one/><one/><one/><one/><zero/>", 12 dup 0
db "<one/><zero/><zero/><one/><one/><one/><one/><zero/>", 13 dup 0
db "<zero/><one/><zero/><one/><one/><one/><one/><zero/>", 13 dup 0
db "<one/><one/><zero/><one/><one/><one/><one/><zero/>", 14 dup 0
db "<zero/><zero/><one/><one/><one/><one/><one/><zero/>", 13 dup 0
db "<one/><zero/><one/><one/><one/><one/><one/><zero/>", 14 dup 0
db "<zero/><one/><one/><one/><one/><one/><one/><zero/>", 14 dup 0
db "<one/><one/><one/><one/><one/><one/><one/><zero/>", 15 dup 0
db "<zero/><zero/><zero/><zero/><zero/><zero/><zero/><one/>", 9 dup 0
db "<one/><zero/><zero/><zero/><zero/><zero/><zero/><one/>", 10 dup 0
db "<zero/><one/><zero/><zero/><zero/><zero/><zero/><one/>", 10 dup 0
db "<one/><one/><zero/><zero/><zero/><zero/><zero/><one/>", 11 dup 0
db "<zero/><zero/><one/><zero/><zero/><zero/><zero/><one/>", 10 dup 0
db "<one/><zero/><one/><zero/><zero/><zero/><zero/><one/>", 11 dup 0
db "<zero/><one/><one/><zero/><zero/><zero/><zero/><one/>", 11 dup 0
db "<one/><one/><one/><zero/><zero/><zero/><zero/><one/>", 12 dup 0
db "<zero/><zero/><zero/><one/><zero/><zero/><zero/><one/>", 10 dup 0
db "<one/><zero/><zero/><one/><zero/><zero/><zero/><one/>", 11 dup 0
db "<zero/><one/><zero/><one/><zero/><zero/><zero/><one/>", 11 dup 0
db "<one/><one/><zero/><one/><zero/><zero/><zero/><one/>", 12 dup 0
db "<zero/><zero/><one/><one/><zero/><zero/><zero/><one/>", 11 dup 0
db "<one/><zero/><one/><one/><zero/><zero/><zero/><one/>", 12 dup 0
db "<zero/><one/><one/><one/><zero/><zero/><zero/><one/>", 12 dup 0
db "<one/><one/><one/><one/><zero/><zero/><zero/><one/>", 13 dup 0
db "<zero/><zero/><zero/><zero/><one/><zero/><zero/><one/>", 10 dup 0
db "<one/><zero/><zero/><zero/><one/><zero/><zero/><one/>", 11 dup 0
db "<zero/><one/><zero/><zero/><one/><zero/><zero/><one/>", 11 dup 0
db "<one/><one/><zero/><zero/><one/><zero/><zero/><one/>", 12 dup 0
db "<zero/><zero/><one/><zero/><one/><zero/><zero/><one/>", 11 dup 0
db "<one/><zero/><one/><zero/><one/><zero/><zero/><one/>", 12 dup 0
db "<zero/><one/><one/><zero/><one/><zero/><zero/><one/>", 12 dup 0
db "<one/><one/><one/><zero/><one/><zero/><zero/><one/>", 13 dup 0
db "<zero/><zero/><zero/><one/><one/><zero/><zero/><one/>", 11 dup 0
db "<one/><zero/><zero/><one/><one/><zero/><zero/><one/>", 12 dup 0
db "<zero/><one/><zero/><one/><one/><zero/><zero/><one/>", 12 dup 0
db "<one/><one/><zero/><one/><one/><zero/><zero/><one/>", 13 dup 0
db "<zero/><zero/><one/><one/><one/><zero/><zero/><one/>", 12 dup 0
db "<one/><zero/><one/><one/><one/><zero/><zero/><one/>", 13 dup 0
db "<zero/><one/><one/><one/><one/><zero/><zero/><one/>", 13 dup 0
db "<one/><one/><one/><one/><one/><zero/><zero/><one/>", 14 dup 0
db "<zero/><zero/><zero/><zero/><zero/><one/><zero/><one/>", 10 dup 0
db "<one/><zero/><zero/><zero/><zero/><one/><zero/><one/>", 11 dup 0
db "<zero/><one/><zero/><zero/><zero/><one/><zero/><one/>", 11 dup 0
db "<one/><one/><zero/><zero/><zero/><one/><zero/><one/>", 12 dup 0
db "<zero/><zero/><one/><zero/><zero/><one/><zero/><one/>", 11 dup 0
db "<one/><zero/><one/><zero/><zero/><one/><zero/><one/>", 12 dup 0
db "<zero/><one/><one/><zero/><zero/><one/><zero/><one/>", 12 dup 0
db "<one/><one/><one/><zero/><zero/><one/><zero/><one/>", 13 dup 0
db "<zero/><zero/><zero/><one/><zero/><one/><zero/><one/>", 11 dup 0
db "<one/><zero/><zero/><one/><zero/><one/><zero/><one/>", 12 dup 0
db "<zero/><one/><zero/><one/><zero/><one/><zero/><one/>", 12 dup 0
db "<one/><one/><zero/><one/><zero/><one/><zero/><one/>", 13 dup 0
db "<zero/><zero/><one/><one/><zero/><one/><zero/><one/>", 12 dup 0
db "<one/><zero/><one/><one/><zero/><one/><zero/><one/>", 13 dup 0
db "<zero/><one/><one/><one/><zero/><one/><zero/><one/>", 13 dup 0
db "<one/><one/><one/><one/><zero/><one/><zero/><one/>", 14 dup 0
db "<zero/><zero/><zero/><zero/><one/><one/><zero/><one/>", 11 dup 0
db "<one/><zero/><zero/><zero/><one/><one/><zero/><one/>", 12 dup 0
db "<zero/><one/><zero/><zero/><one/><one/><zero/><one/>", 12 dup 0
db "<one/><one/><zero/><zero/><one/><one/><zero/><one/>", 13 dup 0
db "<zero/><zero/><one/><zero/><one/><one/><zero/><one/>", 12 dup 0
db "<one/><zero/><one/><zero/><one/><one/><zero/><one/>", 13 dup 0
db "<zero/><one/><one/><zero/><one/><one/><zero/><one/>", 13 dup 0
db "<one/><one/><one/><zero/><one/><one/><zero/><one/>", 14 dup 0
db "<zero/><zero/><zero/><one/><one/><one/><zero/><one/>", 12 dup 0
db "<one/><zero/><zero/><one/><one/><one/><zero/><one/>", 13 dup 0
db "<zero/><one/><zero/><one/><one/><one/><zero/><one/>", 13 dup 0
db "<one/><one/><zero/><one/><one/><one/><zero/><one/>", 14 dup 0
db "<zero/><zero/><one/><one/><one/><one/><zero/><one/>", 13 dup 0
db "<one/><zero/><one/><one/><one/><one/><zero/><one/>", 14 dup 0
db "<zero/><one/><one/><one/><one/><one/><zero/><one/>", 14 dup 0
db "<one/><one/><one/><one/><one/><one/><zero/><one/>", 15 dup 0
db "<zero/><zero/><zero/><zero/><zero/><zero/><one/><one/>", 10 dup 0
db "<one/><zero/><zero/><zero/><zero/><zero/><one/><one/>", 11 dup 0
db "<zero/><one/><zero/><zero/><zero/><zero/><one/><one/>", 11 dup 0
db "<one/><one/><zero/><zero/><zero/><zero/><one/><one/>", 12 dup 0
db "<zero/><zero/><one/><zero/><zero/><zero/><one/><one/>", 11 dup 0
db "<one/><zero/><one/><zero/><zero/><zero/><one/><one/>", 12 dup 0
db "<zero/><one/><one/><zero/><zero/><zero/><one/><one/>", 12 dup 0
db "<one/><one/><one/><zero/><zero/><zero/><one/><one/>", 13 dup 0
db "<zero/><zero/><zero/><one/><zero/><zero/><one/><one/>", 11 dup 0
db "<one/><zero/><zero/><one/><zero/><zero/><one/><one/>", 12 dup 0
db "<zero/><one/><zero/><one/><zero/><zero/><one/><one/>", 12 dup 0
db "<one/><one/><zero/><one/><zero/><zero/><one/><one/>", 13 dup 0
db "<zero/><zero/><one/><one/><zero/><zero/><one/><one/>", 12 dup 0
db "<one/><zero/><one/><one/><zero/><zero/><one/><one/>", 13 dup 0
db "<zero/><one/><one/><one/><zero/><zero/><one/><one/>", 13 dup 0
db "<one/><one/><one/><one/><zero/><zero/><one/><one/>", 14 dup 0
db "<zero/><zero/><zero/><zero/><one/><zero/><one/><one/>", 11 dup 0
db "<one/><zero/><zero/><zero/><one/><zero/><one/><one/>", 12 dup 0
db "<zero/><one/><zero/><zero/><one/><zero/><one/><one/>", 12 dup 0
db "<one/><one/><zero/><zero/><one/><zero/><one/><one/>", 13 dup 0
db "<zero/><zero/><one/><zero/><one/><zero/><one/><one/>", 12 dup 0
db "<one/><zero/><one/><zero/><one/><zero/><one/><one/>", 13 dup 0
db "<zero/><one/><one/><zero/><one/><zero/><one/><one/>", 13 dup 0
db "<one/><one/><one/><zero/><one/><zero/><one/><one/>", 14 dup 0
db "<zero/><zero/><zero/><one/><one/><zero/><one/><one/>", 12 dup 0
db "<one/><zero/><zero/><one/><one/><zero/><one/><one/>", 13 dup 0
db "<zero/><one/><zero/><one/><one/><zero/><one/><one/>", 13 dup 0
db "<one/><one/><zero/><one/><one/><zero/><one/><one/>", 14 dup 0
db "<zero/><zero/><one/><one/><one/><zero/><one/><one/>", 13 dup 0
db "<one/><zero/><one/><one/><one/><zero/><one/><one/>", 14 dup 0
db "<zero/><one/><one/><one/><one/><zero/><one/><one/>", 14 dup 0
db "<one/><one/><one/><one/><one/><zero/><one/><one/>", 15 dup 0
db "<zero/><zero/><zero/><zero/><zero/><one/><one/><one/>", 11 dup 0
db "<one/><zero/><zero/><zero/><zero/><one/><one/><one/>", 12 dup 0
db "<zero/><one/><zero/><zero/><zero/><one/><one/><one/>", 12 dup 0
db "<one/><one/><zero/><zero/><zero/><one/><one/><one/>", 13 dup 0
db "<zero/><zero/><one/><zero/><zero/><one/><one/><one/>", 12 dup 0
db "<one/><zero/><one/><zero/><zero/><one/><one/><one/>", 13 dup 0
db "<zero/><one/><one/><zero/><zero/><one/><one/><one/>", 13 dup 0
db "<one/><one/><one/><zero/><zero/><one/><one/><one/>", 14 dup 0
db "<zero/><zero/><zero/><one/><zero/><one/><one/><one/>", 12 dup 0
db "<one/><zero/><zero/><one/><zero/><one/><one/><one/>", 13 dup 0
db "<zero/><one/><zero/><one/><zero/><one/><one/><one/>", 13 dup 0
db "<one/><one/><zero/><one/><zero/><one/><one/><one/>", 14 dup 0
db "<zero/><zero/><one/><one/><zero/><one/><one/><one/>", 13 dup 0
db "<one/><zero/><one/><one/><zero/><one/><one/><one/>", 14 dup 0
db "<zero/><one/><one/><one/><zero/><one/><one/><one/>", 14 dup 0
db "<one/><one/><one/><one/><zero/><one/><one/><one/>", 15 dup 0
db "<zero/><zero/><zero/><zero/><one/><one/><one/><one/>", 12 dup 0
db "<one/><zero/><zero/><zero/><one/><one/><one/><one/>", 13 dup 0
db "<zero/><one/><zero/><zero/><one/><one/><one/><one/>", 13 dup 0
db "<one/><one/><zero/><zero/><one/><one/><one/><one/>", 14 dup 0
db "<zero/><zero/><one/><zero/><one/><one/><one/><one/>", 13 dup 0
db "<one/><zero/><one/><zero/><one/><one/><one/><one/>", 14 dup 0
db "<zero/><one/><one/><zero/><one/><one/><one/><one/>", 14 dup 0
db "<one/><one/><one/><zero/><one/><one/><one/><one/>", 15 dup 0
db "<zero/><zero/><zero/><one/><one/><one/><one/><one/>", 13 dup 0
db "<one/><zero/><zero/><one/><one/><one/><one/><one/>", 14 dup 0
db "<zero/><one/><zero/><one/><one/><one/><one/><one/>", 14 dup 0
db "<one/><one/><zero/><one/><one/><one/><one/><one/>", 15 dup 0
db "<zero/><zero/><one/><one/><one/><one/><one/><one/>", 14 dup 0
db "<one/><zero/><one/><one/><one/><one/><one/><one/>", 15 dup 0
db "<zero/><one/><one/><one/><one/><one/><one/><one/>", 15 dup 0
db "<one/><one/><one/><one/><one/><one/><one/><one/>", 16 dup 0
