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

                        XOR AX, AX
                        MOV AX, CX                    ;Kopiuj do rejestru AX wartosc licznika petli
                       

                        MOV BL, 2                    ;Przenies do BL wartosc 2
                        DIV BL                         ;AL = (AX div BL), AH = (AX mod BL)

                        CMP AH, 0                   ;Czy parzysta
                        JE  parz                       ;Jesli tak wyswietl informacje ze parzysta jesli nie to wyswietl ze nieparzysta


                        ;JEDYNKA UJEMNA  (jeden)

                        XOR AX, AX
                        MOV AL, [jeden]
                        CMP AL, -1
                        JE etyk1
                        NEG AL
                    etyk1:
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


                                                           ;Zwieksz licznik petli
                        MOV [krok], CX                ;Przenies do zmiennej krok aktualna ilosc licznika petli
                        INC CX

                       MOV [temp1], CX              ;zapamietaj wartosc kroku

                        XOR CX, CX
                        MOV CX, 1

                        FLD qword [radx]     ;st0 = 0.506....
                        FLD qword [init]     ;st0 = 1.0 , st1 = 0.506...


           koploop:

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
                
                      
                        ;stos czysty
                        ;part1 * part2 = licznik

                      
                        FLD qword [part2]       ;st0 =  part2 , 
                        FLD dword [part1]        ;st0 = part1 , st1 = part2      

                        FMULP st1, st0

                        FSTP qword [licznik]

                        ;stos czysty

                        FLD qword [licznik]     ;st0 = licznik
                        FILD dword [mianow]     ;st0 = mianownik, st1 = licznik
                        FDIVP st1, st0          ;st0 = licznik/mianownik

                        FSTP qword [iloraz]   

                       
                        FLD qword [suma]     ;st0 = suma ,
                        FLD qword [iloraz]     ;st0 = iloraz , st1 = suma

                        FADDP st1, st0          ;st0 = suma
                        FSTP qword [suma]     ;st0 czyste


                        FLD qword [condit]      ;st0 = 0.4846
                        FLD qword [suma]       ;st0 = suma , st1 = 0.4846

                        FCOMPP

                        FSTSW AX

                        SAHF
                        ;stos czysty


                        JA czypier                      ; jesli suma wieksza od warunku to koniec zadania

                        JMP oblicz

            czypier: 

                        XOR BX, BX
                        MOV BX, [krok]
                        CMP BX, 1
                        JE oblicz

                        JMP koniec

    koniec:

                   


                MOV AH, 9
                MOV DX, ent1
                INT 21H

                MOV DX, info0
                INT 21H

                MOV AH, 2
                MOV DX, [krok]   ; 0, 1, 2 ale wyswietlam jako 3 OBROTY PETLI 
                XOR DH, DH
                ADD DL, 49
                INT 21H

                 MOV AH, 9
                MOV DX, info1
                INT 21H



                MOV DX, ent1
                INT 21H

                MOV AX, 4C00H
                INT 21H

info  DB "Witaj w programie wykonujacym dzialania na koprocesorze!$"
info0 DB "Ilosc obrotow petli potrzebnych do obliczenia to: $"
info1 DB "Koniec programu.$"
ent1  DB  10,13,36

p1   DB  "Parzysta. $"
np1 DB   "Nieparzysta. $"

arg1   DQ    29.0
arg2   DQ   180.0
radx   DQ    0.0
check DQ    0.507

condit          DQ    0.4846
jeden          DB   1
mianow       DW  1
krok           DW  0
ilesilna        DW  1
temp1         DW  1
newsilna       DW 1
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