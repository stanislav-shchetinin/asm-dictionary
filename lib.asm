section .text
; Принимает код возврата и завершает текущий процесс

global exit
global string_length
global print_string
global print_newline
global print_char
global print_uint
global print_int
global string_equals
global read_char
global read_word
global parse_uint
global parse_int
global string_copy

exit: 
    mov rax, 60
    syscall
    ret 
; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    xor rax, rax
    .loop:
        mov r10b, [rdi + rax]
        inc rax
        test r10b, r10b
        jnz .loop 
    dec rax
    ret
; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
    push rdi;
    call string_length
    pop rsi;
    mov rdx, rax
    mov rdi, 1
    mov rax, 1
    syscall
    ret
; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rdi, 0xA

; Принимает код символа и выводит его в stdout
print_char:
    push rdi
    mov rsi, rsp-1
    mov rdx, 1
    mov rdi, 1
    mov rax, 1
    syscall
    pop rdi
    ret
; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    mov r10, 0xA
    mov r9, rsp
    mov rax, rdi
    push 0
    .loop:
        xor rdx, rdx
        div r10
        add dl, 48 ;rdx
        mov dh, byte[rsp]
        inc rsp
        push dx
        test rax, rax
        jnz .loop
    mov rdi, rsp
    push r9
    call print_string
    pop rsp
    ret
; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    mov r10, rdi
    test rdi, rdi
    jns print_uint
    mov dil, '-'
    push r10
    call print_char
    pop rdi
    neg rdi
    jmp print_uint
; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
    xor rax, rax
    .loop:
        mov r9b, byte[rdi]
        cmp r9b, byte[rsi]
        jne  .nonzero
        test r9b, r9b
        jz .iszero
        inc rdi
        inc rsi
        jmp .loop
    .iszero:
        inc rax
        ret
    .nonzero:
        ret
; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    xor rax, rax
    xor rdi, rdi
    mov rdx, 1
    push 0
    mov rsi, rsp
    syscall
    cmp rax, -1
    je .err
    test rax, rax
    jz .err
    pop rax
    ret
    .err:
        pop r10
        xor rax, rax
        ret
; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор
read_word:
    xor rax, rax
    push r12
    push r13
    push r14
    mov r12, rdi
    mov r13, rdi
    mov r14, rsi
    .read_start_word:
        call read_char
        cmp al, 0x20
        je .read_start_word
        cmp al, 0x9
        je .read_start_word
        cmp al, 0xA
        je .read_start_word
    .read:
        test rax, rax
        je .null_term
        cmp al, 0x20
        je .null_term
        cmp al, 0x9
        je .null_term
        cmp al, 0xA
        je .null_term
        dec r14
        test r14, r14
        jz .err
        mov byte[r13], al
        inc r13
        call read_char
        jmp .read
    .null_term:
        mov byte[r13], 0
        mov rax, r12
        sub r13, r12
        mov rdx, r13
        jmp .ext
    .err:
        xor rax, rax
        jmp .ext
    .ext:
        pop r12
        pop r13
        pop r14
        ret
; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
    xor rax, rax
    xor r10, r10 ;длина
    mov rcx, 10
    .loop:
        mov r9, rax
        xor rax, rax
        mov al, byte[rdi]
        test rax, rax
        jz .ok
        mov rsi, rax ;rsi - считаная цифра
        mov rax, r9 ;число из пршлых итерация
        sub sil, '0'
        cmp sil, 0
        jb .null
        cmp sil, 10
        ja .ok
        mul rcx
        add rax, rsi
        inc r10
        inc rdi
        jmp .loop
    .ok:
        mov rax, r9
        mov rdx, r10
        ret
    .null:
        xor rdx, rdx
        ret
; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int:
    mov al, byte[rdi]
    cmp al, '-'
    je .isnint
    cmp al, '+'
    jne parse_uint
    inc rdi
    call parse_uint
    test rdx, rdx
    jz .err
    inc rdx
    ret
    .isnint:    
        inc rdi
        call parse_uint
        neg rax
        test rdx, rdx
        jz .err
        inc rdx
        ret
    .err:
        ret
    
; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    .loop:
        mov r8b, byte[rdi]
        test r8b, r8b
        jz .ok
        dec rdx
        jbe .null
        mov r9, [rdi]
        mov [rsi], r9
        inc rdi
        inc rsi
        jmp .loop
    .ok:
        mov byte[rsi], 0
        mov rax, r10
        ret
    .null:
        xor rax, rax
        ret
