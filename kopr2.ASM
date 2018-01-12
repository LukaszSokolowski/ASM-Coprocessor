ORG 100H

    start:
            MOV AH, 9
            MOV DX, info
            INT 21H

            MOV DX, ent1
            INT 21H

                XOR AX, AX

                FINIT 
                FLDPI                  ;st0 = Pi
                FLD qword [arg1]    ;st0 = 29.0 , st1 = Pi
                FMULP st1, st0       ;st0 = 29.0 * Pi ,st1 = null
                FLD qword [arg2]    ;st0 = 180.0 ,st1 = 29.0 * Pi
                FDIVP st1, st0         ;st0 = (29*pi)/180
                FSTP qword [radx]   ;radx = (29*Pi)/180, all FPU registers are clean
                FWAIT

                MOV CX, 0
                XOR AX, AX
                XOR BX, BX
                oblicz:
                        XOR AH, AH                  ;Wyczysc gore rejestru AX
                        CMP CX, 5                    ;Porownaj czy koniec petli
                        JE koniec                       ;Jesli tak to zakoncz program

                        MOV [krok], CX              ;Przenies do zmiennej krok aktualna ilosc licznika petli
                        MOV AX, CX                  ;Kopiuj do rejestru AX wartosc licznika petli
                        INC CX                          ;Zwieksz licznik petli
                        MOV BL, 2                   ;Przenies do BL wartosc 2

                        DIV BL                         ;div bl       ; AL = (AX div BL), AH = (AX mod BL)

                        CMP AH, 0                   ;Czy parzysta
                        JE  parz                       ;Jesli tak wyswietl informacje ze parzysta jesli nie to wyswietl ze nieparzysta


                        ;JEDYNKA UJEMNA  (licznik)
                        XOR AX, AX
                        MOV AL, [licznik]
                        CMP AL, -1
                        JE et1
                        NEG AL
                    et1:
                        MOV [licznik], AL

                        MOV AH, 9
                        MOV DX, np1
                        INT 21H

                        JMP oblicz

                   parz:
                         ;JEDYNKA DODATNIA  (licznik)
                        XOR AX, AX

                        MOV AL, [licznik]
                        CMP AL, 1
                        JE et2
                        NEG AL
                    et2:
                        MOV [licznik], AL
                        MOV AH, 9
                        MOV DX, p1
                        INT 21H


                        ;MAMY LICZNIK teraz mianownik

                        XOR AX, AX
                        MOV AX, [krok]
                        MOV BX, 2                              ; <---- Z tego policzyc silnie 
                        MUL BX
                        ADD AX, 1
                        MOV [silnia], AX


                       ; liczymy silnie 






                JMP oblicz

    koniec:
                MOV AH, 9
                MOV DX, ent1
                INT 21H

                MOV DX, info1
                INT 21H

                MOV AX, 4C00H
                INT 21H

info  DB "Witaj w programie wykonujacym dzialania na koprocesorze!$"
info1 DB "Koniec programu.$"
ent1  DB  10,13,36

p1   DB  "Parzyste. $"
np1 DB   "NIeparz. $"

arg1   DQ    29.0
arg2   DQ   180.0
radx   DQ    0.0
check DQ    0.507

condit   DQ    0.4846
licznik   DB   1
mianow DW  1
suma    DQ  0.0
krok     DW  0
parz1    DB  2
silnia    DW 1