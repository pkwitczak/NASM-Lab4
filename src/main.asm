global _start

section .data
    liczba_a dd 2.5
    liczba_b dd 1.5

section .bss
    wynik resd 1

section .text
_start:
    finit                   ; inicjalizacja FPU

    fld dword [liczba_a]    ; wczytanie  pierwszaj liczby na stos FPU.
    fld dword [liczba_b]    ; wczytanie  drugiej liczby na stos FPU.

    faddp st1, st0

    fstp dword [wynik]      ; zdjecie wyniku ze stosu i zapis do zmiennej wynik

koniec:
    ; Ustaw tutaj breakpoint, aby sprawdzic wynik.
    mov rax, 60
    mov rdi, 0
    syscall
