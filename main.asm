%include "words.inc"
%include "lib.inc"
%include "dict.inc"

section .data
    fail1: db 'Strign too large', 0x0A
    fail2: db '----Not found---', 0x0A

section .bss
    txt: resb 256

section .text

global _start

_start:
    mov rdi, txt
    mov rsi, 255
    call read_word
    mov rdi, fail1
    test rax, rax
    jz .err_i
    mov rdi, rax
    mov rsi, first_word
    call find_word
    mov rdi, fail2
    test rax, rax
    jz .err_i
    mov rdi, rax
    call print_string
    xor rdi, rdi
    jmp exit

;rdi - адрес ошибки
.err_i:
    mov     rsi, rdi     ; string address
    mov     rax, 1           ; 'write' syscall number
    mov     rdi, 2        ; stderr descriptor
    
    mov     rdx, 17          ; string length in bytes
    syscall
    mov rdi, 1
    jmp exit

