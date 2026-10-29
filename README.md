# NASM-Lab4

Czwarte laboratorium z NASM przygotowane do pracy w środowisku GitHub Codespaces.

## Cel laboratorium

Celem zajęć jest zapoznanie studenta z:

- deklarowaniem liczb zmiennoprzecinkowych typu float,
- działaniem stosu jednostki zmiennoprzecinkowej x87,
- rejestrami `st0` i `st1`,
- instrukcjami `fld`, `faddp` i `fstp`,
- wykonywaniem obliczeń zmiennoprzecinkowych,
- przetwarzaniem tablic,
- obserwowaniem rejestrów i pamięci w debuggerze GDB.

## Struktura projektu

- `src/main.asm` — program początkowy.
- `Makefile` — konfiguracja budowania programu.
- `.vscode/launch.json` — konfiguracja debugowania.
- `.vscode/tasks.json` — zadanie budowania programu.

Korzystamy ze skonfigurowanego środowiska GitHub Codespaces.

Program działa w systemie Linux x86-64. Punktem wejścia jest `_start`, a zakończenie programu odbywa się przez `syscall`.

Wyniki obliczeń sprawdzamy w debuggerze. Nie implementujemy wypisywania liczb zmiennoprzecinkowych na konsolę.

## Uruchamianie i debugowanie

1. Otwórz repozytorium w GitHub Codespaces.
2. Otwórz plik `src/main.asm`.
3. Ustaw breakpoint przy instrukcji `finit`.
4. Przejdź do panelu Run and Debug po lewej stronie VS Code.
5. Wybierz skonfigurowany profil debugowania.
6. Uruchom debugowanie przyciskiem Start Debugging lub klawiszem `F5`.
7. Wykonuj program krokowo, obserwując rejestry i pamięć.

Panel Run and Debug można otworzyć skrótem `Ctrl+Shift+D`.

Debugowanie można również uruchomić przez `Ctrl+Shift+P`, wybierając polecenie Debug: Start Debugging.

Ustaw dodatkowy breakpoint przy instrukcji:

```nasm
koniec:
    mov rax, 60
```

W tym miejscu wynik jest już zapisany w pamięci, ale program jeszcze się nie zakończył.

Debugger zatrzymuje program przed wykonaniem zaznaczonej instrukcji. Aby zobaczyć jej efekt, wykonaj krok i sprawdź wartości przy następnej instrukcji.

## Program początkowy

Plik `src/main.asm`:

```nasm
global _start

section .data
    liczba_a dd 2.5
    liczba_b dd 1.5

section .bss
    wynik resd 1

section .text
_start:
    ; Zainicjalizuj jednostke zmiennoprzecinkowa.
    finit

    ; Wczytaj pierwsza liczbe na stos FPU.
    ; st0 = 2.5
    fld dword [liczba_a]

    ; Wczytaj druga liczbe na stos FPU.
    ; st0 = 1.5
    ; st1 = 2.5
    fld dword [liczba_b]

    ; Dodaj st0 do st1 i zdejmij wierzcholek stosu.
    ; Po operacji: st0 = 4.0
    faddp st1, st0

    ; Zapisz wynik jako float i zdejmij go ze stosu.
    fstp dword [wynik]

koniec:
    ; Ustaw tutaj breakpoint, aby sprawdzic wynik.
    mov rax, 60
    mov rdi, 0
    syscall
```

## Liczby zmiennoprzecinkowe w pamięci

W tym laboratorium wykorzystujemy 4-bajtowe liczby zmiennoprzecinkowe pojedynczej precyzji, odpowiadające typowi `float`.

Przykładowe deklaracje:

```nasm
section .data
    a dd 2.5
    b dd -1.25
    c dd 4.0
```

Liczby zmiennoprzecinkowe w NASM zapisujemy z kropką dziesiętną.

Należy odróżnić:

```nasm
calkowita dd 5
zmiennoprzecinkowa dd 5.0
```
Obie deklaracje zajmują po 4 bajty, ale zapisują inne reprezentacje danych:

Miejsce na jeden 4-bajtowy wynik rezerwujemy następująco:

```nasm
section .bss
    wynik resd 1
```

Przy odczycie i zapisie danych typu float używamy rozmiaru `dword`:

```nasm
fld dword [a]
fstp dword [wynik]
```

## Stos jednostki x87

Jednostka x87 udostępnia osiem pozycji stosu rejestrów: `st0`–`st7`.

- `st0` oznacza aktualny wierzchołek stosu.
- `st1` oznacza element znajdujący się pod nim.
- Instrukcja `fld` dodaje liczbę na wierzchołek.
- Dotychczasowe `st0` staje się wtedy `st1`.

Jest to osobny stos jednostki zmiennoprzecinkowej, a nie stos programu obsługiwany przez `rsp`.

Przykład:

```nasm
fld dword [liczba_a] ; st0 = liczba_a
fld dword [liczba_b] ; st0 = liczba_b, st1 = liczba_a

```

Nie wczytujemy drugiej liczby bezpośrednio do `st1`. Dodajemy nową wartość jako `st0`, a poprzednia wartość przesuwa się na pozycję `st1`.

## Podstawowe instrukcje

| Instrukcja | Działanie |
|---|---|
| `finit` | Inicjalizuje jednostkę x87, między innymi oznaczając stos jako pusty. |
| `fld dword [a]` | Wczytuje 4-bajtową liczbę zmiennoprzecinkową na stos FPU. |
| `faddp st1, st0` | Dodaje `st0` do `st1`, a następnie zdejmuje wierzchołek stosu. |
| `fstp dword [wynik]` | Zapisuje `st0` do pamięci jako float i zdejmuje go ze stosu. |

Po wykonaniu:

```nasm
    faddp st1, st0
```

suma znajduje się w nowym `st0`.

Do obliczania bardziej złożonych wyrażeń można również wykorzystać:

```nasm
    fadd dword [b]       ; st0 = st0 + b
    fmul dword [c]       ; st0 = st0 * c
    fdiv dword [d]       ; st0 = st0 / d
```

Powyższe trzy instrukcje nie dodają nowego elementu na stos. Modyfikują wartość znajdującą się w `st0`.

## Obserwowanie zmiennych w WATCH

W programie asemblerowym debugger nie zawsze zna typ danych zapisanych w pamięci. Dlatego w WATCH podajemy wyrażenie określające sposób odczytania zmiennej.

### Jak dodać zmienną?

1. Uruchom debugowanie.
2. Zatrzymaj program na breakpoincie.
3. W panelu Run and Debug rozwiń sekcję WATCH.
4. Kliknij `+`.
5. Wpisz wyrażenie i zatwierdź klawiszem Enter.

Każde wyrażenie dodaj osobno.

Wyrażenia wpisujemy do WATCH, a nie do pliku `main.asm`.

### Zmienne typu float

Dla programu początkowego dodaj:

```text
*(float*)&liczba_a
```

```text
*(float*)&liczba_b
```

```text
*(float*)&wynik
```

Wyrażenie:

```text
*(float*)&wynik
```

oznacza: odczytaj pamięć pod adresem `wynik` jako 4-bajtową liczbę zmiennoprzecinkową typu float.

Nie używaj tutaj `double`, ponieważ nasze zmienne zajmują po 4 bajty, a nie po 8.

Wartość zmiennej `wynik` sprawdzaj po wykonaniu:

```nasm
fstp dword [wynik]
```

Najprościej zatrzymać program na instrukcji `mov rax, 60`.

### Rejestry stosu FPU

Do WATCH dodaj:

```text
$st0
```

```text
$st1
```

Nazwy rejestrów w wyrażeniach GDB poprzedzamy znakiem `$`.

Uwaga: po zdjęciu elementu ze stosu debugger może nadal pokazywać dawną wartość znajdującą się w fizycznym rejestrze. Nie oznacza to, że dana pozycja stosu pozostaje zajęta.

Aby obejrzeć pełny stan FPU, otwórz Debug Console i wpisz:

```text
-exec info float
```

### Tablica liczb typu float

Dla tablicy:

```nasm
tablica dd 1.5, 2.5, 3.0, 4.0, 6.5
```

dodaj do WATCH:

```text
*(float (*))&tablica
```

Rozwiń wynik w WATCH, aby zobaczyć poszczególne elementy.

Do obserwowania pojedynczego elementu możesz użyć:

```text
((float*)&tablica)
```

Indeks `0` oznacza pierwszy element, a indeks `4` — piąty.

### Rejestry używane w pętli

Do WATCH możesz dodać:

```text
$rcx
```

```text
$rsi
```

Jeżeli `rsi` wskazuje poprawny element tablicy typu float, wartość tego elementu odczytasz przez:

```text
*(float*)$rsi
```

Po przejściu za koniec tablicy nie interpretuj tego odczytu jako kolejnego elementu.

## Zadanie 1: analiza programu początkowego

1. Uruchom program w debuggerze.
2. Dodaj do WATCH:
   - `$st0`,
   - `$st1`,
   - `*(float*)&liczba_a`,
   - `*(float*)&liczba_b`,
   - `*(float*)&wynik`.
3. Wykonuj program instrukcja po instrukcji.
4. Zapisz stan stosu FPU:
   - po wczytaniu pierwszej liczby,
   - po wczytaniu drugiej liczby,
   - po wykonaniu dodawania,
   - po zapisaniu wyniku do pamięci.
5. Sprawdź wynik zapisany w zmiennej `wynik`.
6. Opisz, jakie zadanie wykonuje program.
7. Wyjaśnij:
   - gdzie trafia liczba wczytana przez `fld`,
   - co dzieje się z poprzednią wartością `st0`,
   - gdzie znajduje się wynik po `faddp`,
   - co robi `fstp`.

Następnie zmień dane na:

```nasm
    liczba_a dd 7.5
    liczba_b dd -2.5
```

Przed uruchomieniem przewidź wynik, a następnie sprawdź go w debuggerze.

## Zadanie 2: obliczanie wartości wyrażenia

Zmodyfikuj program tak, aby obliczał:

wynik = ((a + b) * c) / d

Dane wejściowe:

```nasm
section .data
    a dd 2.5
    b dd 1.5
    c dd 3.0
    d dd 2.0

section .bss
    wynik resd 1
```

Wymagania:

1. Wykonaj obliczenia za pomocą instrukcji x87.
2. Nie zapisuj wyników pośrednich do pamięci.
3. Zapisz wynik końcowy w zmiennej `wynik`.
4. Sprawdź w debuggerze wartości pośrednie.
5. Po zapisaniu wyniku stos FPU powinien być pusty.

Możesz wykorzystać instrukcje:

- `fld`,
- `fadd`,
- `fmul`,
- `fdiv`,
- `fstp`.

Pamiętaj o rozmiarze `dword` przy operacjach na zmiennych w pamięci.

Oczekiwany wynik:

```text
6.0
```

W WATCH dodaj:

```text
$st0
```

```text
*(float*)&wynik
```

Następnie dobierz własny zestaw danych, dla którego wynik będzie ujemny.

Przyjmij, że dzielnik `d` jest różny od zera.

## Zadanie 3: suma elementów tablicy

Napisz program obliczający sumę pięciu liczb zmiennoprzecinkowych.

Dane wejściowe:

```nasm
section .data
    tablica dd 1.5, 2.5, 3.0, 4.0, 6.5
    zero dd 0.0

section .bss
    suma resd 1
```

Wymagania:

1. Przed rozpoczęciem pętli wczytaj `0.0` jako początkową sumę.
2. Wykorzystaj:
   - `rsi` jako adres aktualnego elementu,
   - `rcx` jako licznik pięciu elementów.
3. W każdej iteracji:
   - wczytaj aktualny element na stos FPU,
   - dodaj go do dotychczasowej sumy,
   - przejdź do następnego elementu.
4. Po każdej iteracji na stosie powinna pozostawać tylko bieżąca suma.
5. Po zakończeniu pętli zapisz wynik w zmiennej `suma`.
6. Sprawdź wynik w debuggerze.

Każdy element tablicy zajmuje 4 bajty. Przejście do następnego elementu wymaga zwiększenia adresu o 4.

Przykład odczytania elementu wskazywanego przez `rsi`:

```nasm
    fld dword [rsi]
```

Oczekiwany wynik:

```text
17.5
```

Do WATCH dodaj:

```text
*(float (*))&tablica
```

```text
*(float*)&suma
```

```text
$st0
```

```text
$st1
```

```text
$rcx
```

```text
$rsi
```

## Zadanie 4: średnia arytmetyczna

Rozbuduj program o obliczenie średniej.

Do odpowiednich sekcji dodaj:

```nasm
section .data
    liczba_elementow dd 5.0

section .bss
    srednia resd 1
```

Zachowaj w pamięci zarówno sumę, jak i średnią.

Oczekiwane wyniki:

```text
suma = 17.5
srednia = 3.5
```

Dodaj do WATCH:

```text
*(float*)&srednia
```

## Uwagi

- Liczby zmiennoprzecinkowe zapisuj z kropką dziesiętną.
- W pamięci używamy danych typu float: `dd` i `resd`.
- Przy operacjach na `st0`-`st7` na tych danych stosuj rozmiar `dword`.

*Last updated: 2026-10-29*
