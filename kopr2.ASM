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
                        CMP CX, 5                    ;Porownaj czy koniec petli                                 !!!!!!!!!!!!!!!!!!!!!! 0.4846 warunkiem konca
                        JE koniec                       ;Jesli tak to zakoncz program

                        MOV [krok], CX              ;Przenies do zmiennej krok aktualna ilosc licznika petli
                        MOV AX, CX                  ;Kopiuj do rejestru AX wartosc licznika petli
                        INC CX                          ;Zwieksz licznik petli
                        MOV BL, 2                   ;Przenies do BL wartosc 2

                        DIV BL                         ;AL = (AX div BL), AH = (AX mod BL)

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

                        JMP mnwnk

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

             mnwnk:
                        ;MAMY LICZNIK teraz mianownik

                        XOR AX, AX
                        MOV AX, [krok]
                        MOV BX, 2                              ; <---- Z tego policzyc silnie 
                        MUL BX
                        ADD AX, 1
                        MOV [ilesilnia], AX                    ; tu zmienna silnia = 1 ,3 ,5, 7  ale po wywolaniu procedury bedzie to obliczona wartosc 1 2 6 24 120 720 itd





                        XOR AX, AX
                        XOR DX, DX

                        MOV AH, 2
                        MOV DL, [ilesilnia]
                        ADD DL, 48
                        INT 21H

                        XOR AX, AX
                        XOR DX, DX






                       ; liczymy silnie 

                       MOV [temp1], CX              ;zapamietaj wartosc kroku
                       CALL silnia                          ;Wywolaj procedure obliczenia silni
                       MOV  CX, [temp1]              ;Wczytaj wartosc kroku

                       XOR AX, AX                       ;Wyzeruj AX
                       XOR BX, BX                       ;Wyzeruj BX

                       MOV BX, [newsilna]                 ;Obliczona wartosc silni
                       MOV AX, [mianow]           ;Wartosc silni jest po prostu mianownikiem
                       MOV AX, BX                      ;Kopiuj wartosc silni do mianownika      
                       MOV [mianow], AX          ;Zapisz wartosc mianownika

                       XOR AX, AX
                       XOR BX, BX










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
ilesilnia    DW  1
temp1   DW  0
newsilna DW 1
adr_init  DW  0


;-------------------------------Silnia--------------------------------

silnia:
         POP AX                  ;Zrzuc adres powrotu
         MOV [adr_init], AX      ;Przenies adres do AX

         MOV CX, 1
         XOR BX, BX


         sloop:
                XOR AX, AX
                CMP CX, [ilesilnia]
                JE lpEnd
                INC CX

                MOV AX, [newsilna]
                MOV BX, CX
                MUL BX
                MOV [newsilna], AX

                XOR DX, DX
                XOR BX, BX

                MOV AH, 2
                MOV DL, 'X'
                INT 21H
           
         JMP sloop

         lpEnd:

         XOR   CX, CX
         XOR   AX, AX
         XOR   BX, BX
         MOV  AX, [adr_init]      ;Do AX wartosc adresu powrotu
         PUSH AX                 ;Wrzuc adres powrotu na stos
RET

;--------------------------------------------------------------------