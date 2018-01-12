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
                XOR BX, BX
                oblicz:

                        XOR AX, AX                   ;Wyczysc gore rejestru AX
                        CMP CX, 4                    ;Porownaj czy koniec petli                                 !!!!!!!!!!!!!!!!!!!!!! 0.4846 warunkiem konca
                        JE koniec                       ;Jesli tak to zakoncz program

                        MOV [krok], CX                ;Przenies do zmiennej krok aktualna ilosc licznika petli
                        MOV AX, CX                    ;Kopiuj do rejestru AX wartosc licznika petli
                        INC CX                          ;Zwieksz licznik petli

                        MOV BL, 2                    ;Przenies do BL wartosc 2
                        DIV BL                         ;AL = (AX div BL), AH = (AX mod BL)

                        CMP AH, 0                   ;Czy parzysta
                        JE  parz                       ;Jesli tak wyswietl informacje ze parzysta jesli nie to wyswietl ze nieparzysta


                        ;JEDYNKA UJEMNA  (jeden)

                        XOR AX, AX
                        MOV AL, [jeden]
                        CMP AL, -1
                        JE et1
                        NEG AL
                    et1:
                        MOV [jeden], AL

                        MOV AH, 9
                        MOV DX, np1
                        INT 21H

                        JMP mnwnk

                   parz:
                         ;JEDYNKA DODATNIA  (jeden)
                        XOR AX, AX

                        MOV AL, [jeden]
                        CMP AL, 1
                        JE et2
                        NEG AL
                    et2:
                        MOV [jeden], AL

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
                        MOV [ilesilna], AX                    ; tu zmienna silnia = 1 ,3 ,5, 7  ale po wywolaniu procedury bedzie to obliczona wartosc 1 2 6 24 120 720 itd

                       ;XOR AX, AX
                       ; MOV AH, 2
                       ; XOR DX, DX
                       ; MOV DX, [ilesilna]
                       ; XOR DH, DH
                       ; ADD DL, 48
                       ;INT 21H

                       ;Wartosc ilesilnia jest liczona poprawnie tak wiec zjebalem cos przy liczeniu silni dla tej liczby

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
                       XOR DX, DX

                       ;Mamy wartosc mianownika, ktorej nie trzeba zmieniac gdy cala petla przekreci sie 
                       ;newsilna tez nie trzeba bo jest resetowana w procedurze 
                       ;temp1 nie trzeba 


                       MOV AX, [jeden]                ;Licznik czyli wlasciwie sama jedynka jest obliczana automatycznie wyzej
                       XOR AH, AH

                       MOV [part1], AX             ;obliczamy czy jedynka dodatnia czy ujemna, nie trzeba wczytywac wartosci 

                       ;Part2 to wynik potegowania zamienionych radianow 



                       MOV [temp1], CX              ;zapamietaj wartosc kroku

                        XOR CX, CX
                        MOV CX, 1

                        FLD qword [radx]     ;st0 = 0.506....
                        FLD qword [init]     ;st0 = 1.0 , st1 = 0.506...


           koploop:


                       ; XOR AX, AX
                       ; MOV AH, 2
                       ; XOR DX, DX
                       ; MOV DX, CX
                       ; XOR DH, DH
                       ; INT 21H

                        WAIT


                        FMUL st0, st1          
                        FWAIT
                        CMP CX, [ilesilna]                              ;petla oblicza potege x
                        JE  cont
                        INC CX  

               JMP koploop

                     
               cont:
                        MOV  CX, [temp1]              ;Wczytaj wartosc kroku

                        FSTP qword [part2]            ; part2 = radx^(2n+1)
                        FFREE st0

                        ;part1 * part2 = licznik




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

p1   DB  "Parzysta. $"
np1 DB   "Nieparzysta. $"

arg1   DQ    29.0
arg2   DQ   180.0
radx   DQ    0.0
check DQ    0.507

sinx    DQ    0.0

condit          DQ    0.4846
jeden          DB   1
mianow       DW  1

krok           DW  0
ilesilna        DW  1
temp1         DW  1
newsilna       DW 1
adr_init        DW  0


init        DQ 1.0

part1          DW 1
part2          DQ 1.0

licznik  DQ  1.0

iloraz          DQ 1.0

suma          DQ  0.0
;-------------------------------Silnia--------------------------------

silnia:

         XOR CX, CX
         MOV CX, 1
         XOR BX, BX
         XOR AX, AX

         MOV AX, [newsilna]
         XOR AX, AX
         MOV AX, 1
         MOV [newsilna], AX

         sloop:
                MOV AX, [newsilna]
                MOV BX, CX
                MUL BX
                XOR DX, DX
                MOV [newsilna], AX
                CMP CX, [ilesilna]
                JE lpEnd
                INC CX

         JMP sloop

         lpEnd:

         XOR   CX, CX
         XOR   AX, AX
         XOR   BX, BX

RET

;--------------------------------------------------------------------