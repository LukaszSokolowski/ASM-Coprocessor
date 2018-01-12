ORG 100H

    start:
            MOV AH, 9		;Funckja wywolujaca lancuch znakow o adresie z rejestru DX
            MOV DX, info 	;Skopiuj do DX ardes zmiennej info
            INT 21H		;Przerwanie DOS

            MOV DX, ent1	;Enter
            INT 21H		;Przerwanie DOS

            XOR AX, AX		;Wyczysc rejestr AX

                FINIT 			;Inicjalizacja koprocesora
                FLDPI                   ;St0 = Pi
                FLD qword [arg1]        ;St0 = 29.0 , st1 = Pi
                FMULP st1, st0          ;St0 = 29.0 * Pi ,st1 = null
                FLD qword [arg2]        ;St0 = 180.0 ,st1 = 29.0 * Pi
                FDIVP st1, st0          ;St0 = (29*pi)/180
                FSTP qword [radx]       ;Radx = (29*Pi)/180, all FPU registers are clean
                FWAIT

                MOV CX, 0		;Wyzeruj licznik
                XOR BX, BX		;Wyczysc rejestr BX

                oblicz:

                        XOR AX, AX	;Wyczysc rejestrAX
                        MOV AX, CX      ;Kopiuj do rejestru AX wartosc licznika petli
                       

                        MOV BL, 2       ;Przenies do BL wartosc 2
                        DIV BL          ;AL = (AX div BL), AH = (AX mod BL)

                        CMP AH, 0       ;Czy parzysta
                        JE  parz        ;Jesli tak wyswietl informacje ze parzysta jesli nie to wyswietl ze nieparzysta

                       		        ;JEDYNKA UJEMNA  (jeden)

                        XOR AX, AX	;Wyczysc AX
                        MOV AL, [jeden]	;Przenies wartosc zmiennej do AL
                        CMP AL, -1	;Porownaj czy ujemna
                        JE etyk1	;Jesli tak przejdz do etykiety etyk1
                        NEG AL		;Jesli nie to zaneguj aby otrzymac ujemna
               etyk1:
                        MOV [jeden], AL  ;Przenies wartosc AL (-1 lub +1) do zmiennej

                        MOV AH, 9	 ;Wyswietl informacje o nieparzystosci kroku
                        MOV DX, np1	 ;Przenies adres zmiennej np1 do DX
                        INT 21H	         ;Przerwanie DOS

                        JMP mnwnk	 ;Przejdz do etykiety mianownika

                parz:
                        		 ;JEDYNKA DODATNIA  (jeden)
                        XOR AX, AX	 ;Wyczysc rejestr AX
	
                        MOV AL, [jeden]	 ;Przenies do AL wartosc zmiennej jeden	
                        CMP AL, 1	 ;Porownaj czy wartosc AL jest rowna z 1	

                        JE et2		 ;Jesli tak przejdz do etykiety et2
                        NEG AL		 ;Jesli nie to zaneguj po to aby byla dodatnia
                 et2:
                        MOV [jeden], AL  ;Kopiuj do zmiennej jeden wartosc rejestru AL

                        MOV AH, 9	 ;Przenies do AH wartosc 9 funkcji wyswietlajacej lancuch znakow
                        MOV DX, p1	 ;Przenies do DX adres zmiennej p1
                        INT 21H		 ;Przerwanie DOS

             mnwnk:
                       			 ;Mamy znak licznika teraz mianownik
					 ;Obliczamy (2*krok + 1)

                        XOR AX, AX	 ;Wyczysc AX
                        MOV AX, [krok]	 ;Przenies do AX wartosc aktualnego kroku
                        MOV BX, 2        ;Przenies do BX wartosc 2
                        MUL BX		 ;Pomnoz AX razy BX
                        ADD AX, 1        ;Dodaj do AX 1
                        MOV [ilesilna], AX   ;Przenies do zmiennej ilesilnia wartosc AX czyli jaka silnie trzeba policzyc

                       MOV [temp1], CX    ;Zapamietaj chwilowo wartosc kroku
                       CALL silnia        ;Wywolaj procedure obliczenia silni
                       MOV  CX, [temp1]   ;Wczytaj wartosc kroku

                       XOR AX, AX         ;Wyzeruj AX
                       XOR BX, BX         ;Wyzeruj BX

                       MOV BX, [newsilna] ;Obliczona wartosc silni
                       MOV AX, [mianow]   ;Wartosc silni jest po prostu mianownikiem
                       MOV AX, BX         ;Kopiuj wartosc silni do mianownika      
                       MOV [mianow], AX   ;Zapisz wartosc mianownika
                     

                       XOR AX, AX	  ;Wyzeruj AX
                       XOR BX, BX	  ;Wyzeruj BX
                       XOR DX, DX	  ;Wyzeruj DX

                       ;Mamy wartosc mianownika (2 * krok + 1)!


                       MOV AX, [jeden]    ;Przenies wartosc jedynki do AX
                       XOR AH, AH         ;Wyzeruj gore AX
                       MOV [part1], AX    ;Przenies do zmiennej part1 czyli czesci licznika wartosc AX

                       			  ;Part2 to wynik potegowania zamienionych radianow 

                        MOV [krok], CX    ;Przenies do zmiennej krok aktualna ilosc licznika petli
                        INC CX            ;Zwieksz krok petli

                       MOV [temp1], CX    ;Zapamietaj wartosc kroku

                        XOR CX, CX        ;Wyzeruj CX
                        MOV CX, 1         ;Zaladuj 1 do CX

                        FLD qword [radx]     ;st0 = 0.506....
                        FLD qword [init]     ;st0 = 1.0 , st1 = 0.506...
						
			;Zmienna ilesilna to rowniez wartosc potegi
           koploop:

                        FMUL st0, st1          ;Tu obliczane sa kolejne potegi mnozac radx przez siebie odpowiednia ilosc razy
                        FWAIT		       ;Oczekiwanie koprocesora
                        CMP CX, [ilesilna]     ;Porownaj czy koniec oblicznia potegi
                        JE  cont	       ;Jesli tak to przejdz do etykiety cont
                        INC CX  	       ;Jesli nie to zwieksz CX i licz dalej
			JMP koploop 	       ;Kolejny krok

                     
               cont:
                        MOV  CX, [temp1]        ;Wczytaj wartosc kroku

                        FSTP qword [part2]      ;Part2 = radx^(2n+1)
                        FFREE st0		;Zwolnij rejestr st0
                        ;stos czysty
                        ;part1 * part2 = licznik

                      
                        FLD qword [part2]       ;St0 = part2 , 
                        FLD dword [part1]       ;St0 = part1 , St1 = part2      

                        FMULP st1, st0		;Pomnoz st1 razy st0 oraz zdejmij st0 a wiec st1 nowym st0

                        FSTP qword [licznik]	;Zrzuc st0 do zmiennej licznik

                        ;stos czysty

                        FLD qword [licznik]     ;St0 = licznik
                        FILD dword [mianow]     ;St0 = mianownik, st1 = licznik
                        FDIVP st1, st0          ;St0 = licznik/mianownik
                        FSTP qword [iloraz]   	;Iloraz = st0 ->> St0 = null, 	
                        FLD qword [suma]        ;St0 = suma ,
                        FLD qword [iloraz]      ;St0 = iloraz , st1 = suma

                        FADDP st1, st0          ;Dodaj do st1 wartosc st0 potem zrzuc st0 a nowym st0 = suma
                        FSTP qword [suma]       ;Suma= st0 ->> St0 czyste

                        FLD qword [condit]      ;St0 = 0.4846
                        FLD qword [suma]        ;St0 = suma , st1 = 0.4846

                        FCOMPP			;Porownaj st0 z st1 i zrzuc obydwa

                        FSTSW AX		;Zaladowanie stanu slowa statusu koprocesora do rejestru AX
                        SAHF			;Laduje bajt AH do rejestru znacznikow

                        JA czypier              ;Jesli suma wieksza od warunku to sprawdz czy nie pierwszy element
                        JMP oblicz		;Jesli nie to oblicz

            czypier: 

                        XOR BX, BX		;Wyzeruj BX
                        MOV BX, [krok]		;Przenies do BX wartosc zmiennej krok
                        CMP BX, 1		;Porownaj czy to pierwszy krok
                        JE oblicz		;Jesli tak to licz dalej mimo ze wieksze bo pierwszy raz bedzie to wieksze niz 0.4846
                        JMP koniec		;Jesli nie pierwszy to znaczy ze przekroczylismy warunek a to oznacza koniec zadania

    koniec:

                MOV AH, 9		;Przenies do AH wartosc 9 odpowiadajaca funckji wyswietlajacej lancuch znakow
                MOV DX, ent1		;Enter 
                INT 21H			;Przerwanie DOS

                MOV DX, info0		;Przenies do DX adres zmiennej info0
                INT 21H			;Przerwanie DOS

                MOV AH, 2		;Czytaj znak z DL
                MOV DX, [krok]          ;Kroki to 0, 1, 2 ale wyswietlam jako 3 OBROTY PETLI 
                XOR DH, DH		;Wyzeruj gore DH
                ADD DL, 49		;Dodaj aby wyswietlic cyfre
                INT 21H			;Przerwanie DOS

                MOV AH, 9		;Funkcja czytaj lancuch znakow z adresu z DX
		MOV DX, ent1		;Enter
		INT 21H			;Przerwanie DOSs

                MOV DX, info1		;Adres info1 do DX
                INT 21H			;Przerwanie DOS


                MOV AX, 4C00H		;Oddanie sterowania do systemu (program stop)
                INT 21H			;Przerwanie DOS
;---------------------------Zmienne------------------------------------------
info  DB "Witaj w programie wykonujacym dzialania na koprocesorze!$"
info0 DB "Ilosc obrotow petli potrzebnych do obliczenia to: $"
info1 DB "Dziekuje bardzo.$"
ent1  DB  10,13,36

p1      DB   "Mianownik dodatni. $"
np1     DB   "Mianownik ujemny. $"

arg1      DQ    29.0
arg2      DQ    180.0
radx      DQ    0.0
check     DQ    0.507

condit      DQ    0.4846
jeden       DB    1
mianow      DW    1
krok        DW    0
ilesilna    DW    1
temp1       DW    1
newsilna    DW    1
init        DQ    1.0
part1       DW    1
part2       DQ    1.0
licznik     DQ    1.0
iloraz      DQ    1.0
suma        DQ    0.0
;-------------------------------Silnia--------------------------------

silnia:

         XOR CX, CX		;Wyczysc CX
         MOV CX, 1		;Wrzuc do CX wartosc 1
         XOR BX, BX		;Wyczysc BX
         XOR AX, AX		;Wyczysc AX

         MOV AX, [newsilna]	;Przenies do AX wartosc zmiennej newsilna
         XOR AX, AX		;Wyczysc AX
         MOV AX, 1		;Przenies do AX wartosc 1
         MOV [newsilna], AX	;Przenies do zmiennej newsilna wartosc AX

         sloop:
                MOV AX, [newsilna]	;Zaladuj AX wartoscia zmiennej newsilna
                MOV BX, CX		;Przenies do BX wartosc CX
                MUL BX			;Pomnoz AX razy BX
                XOR DX, DX		;Wyzeruj DX
                MOV [newsilna], AX	;Przenies AX do wartosc zmiennej newsilna
                CMP CX, [ilesilna]	;Porownaj czy warunek konca petli spelniony
                JE lpEnd		;Jesli tak przejdz do etykiety konca procedury
                INC CX			;Jesli nie to zwieksz licznik i licz dalej

         JMP sloop			;Kolejny krok

         lpEnd:

         XOR   CX, CX			;Wyczysc CX
         XOR   AX, AX			;Wyczysc AX
         XOR   BX, BX			;Wyczysc BX
RET

;--------------------------------------------------------------------