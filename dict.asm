%include "lib.inc"

section .text

global find_word

find_word:
    .loop:
        test rsi, rsi
        jz .fin
        push rdi
        push rsi
        call string_equals
        pop rsi
        pop rdi

        .rstr:
            mov r9b, byte[rsi]
            test r9b, r9b
            jnz .nonz
        
        inc rsi
        test rax, rax
        jz .noneq
        ;
        add rsi, 8
        mov rax, rsi
        ret
    .fin:
        xor rax, rax
        ret
    .nonz:
        inc rsi
        jmp .rstr
    .noneq:
        mov rsi, [rsi]
        jmp .loop

        