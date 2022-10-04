.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Minion Rush 2D",0
area_width EQU 640
area_height EQU 480
area DD 0
x dd 100
y dd 100
poz_minion_x dd 300
poz_minion_y dd 340 
poz_banana_x dd 200
poz_banana_y dd 90
poz_caramida_x dd 250
poz_caramida_y dd 90
counter DD 90 ; numara evenimentele de tip timer
afisare db "%d ", 0
counter1 dd 210
counter2 dd 150
counter3 dd 270
counter4 dd 90
counter5 dd 90
counter6 dd 90
counter7 dd 150 
counter8 dd 90
scor dd 0


arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

xa EQU 190
ya EQU 90
xb EQU 190
yb EQU 390
xc equ 440
yc equ 90
line_orizontal_size EQU 250
line_vertical_size EQU 300
;butonul stanga
x1b equ 215
y1b equ 407
len_buttom1 equ 80
len_buttom2 equ 50
y2b equ 457
x2b equ 295
;butonul dreapta
x3b equ 325
x4b equ 405

symbol_width EQU 10
symbol_height EQU 20

latime_simbol equ 30
inaltime_simbol equ 50

include digits.inc
include letters.inc
include simbolu.inc



.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
	
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

make_text_simbolu proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	sub eax, '('
	lea esi, simbolu
	
	make_simbolu:
    mov ebx, latime_simbol
	mul ebx
	mov ebx, inaltime_simbol
	mul ebx
	add esi, eax
	mov ecx, inaltime_simbol
	
	bucla_simbol_linii_simbolu:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, inaltime_simbol
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, latime_simbol
	
	bucla_simbol_coloane_simbolu:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb_simbolu
	cmp byte ptr [esi], 1
	je simbol_pixel_negru_simbolu
	cmp byte ptr[esi], 2
	je simbol_pixel_fundal_simbolu
	cmp byte ptr[esi], 3
	je simbol_pixel_galben_simbolu
	cmp byte ptr[esi], 4
	je simbol_pixel_albastru
	 cmp byte ptr [esi], 5
	 je simbol_pixel_maro_simbolu
	
	
	simbol_pixel_alb_simbolu:
	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_next_simbolu
	simbol_pixel_negru_simbolu:
	mov dword ptr [edi],0
	jmp simbol_pixel_next_simbolu
	simbol_pixel_albastru:
	mov dword ptr[edi], 17157Bh
	jmp simbol_pixel_next_simbolu
	simbol_pixel_fundal_simbolu:
	mov dword ptr [edi], 6ffh
	jmp simbol_pixel_next_simbolu
	simbol_pixel_galben_simbolu:
	mov dword ptr[edi], 0FFFF00h
	jmp simbol_pixel_next_simbolu
	simbol_pixel_maro_simbolu:
	mov dword ptr[edi], 7B2715h

	
simbol_pixel_next_simbolu:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane_simbolu
	pop ecx
	loop bucla_simbol_linii_simbolu
	
	popa
	mov esp, ebp
	pop ebp
	ret
make_text_simbolu endp
	

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_text_macro_simbolu macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text_simbolu
	add esp, 16
endm

line_horizontal macro x, y, len, color
; POZ= (Y*AREA_WIDTH + X) *4;
local loop1, iesire
mov EAX, y
mov EBX, area_width
mul ebx
add EAX, x
shl eax, 2
add eax, area
xor esi, esi
mov edx, len 
loop1:
cmp esi, edx
jae iesire
mov dword ptr[eax], color
add eax, 4
inc esi
jmp loop1
iesire:
endm

line_vertical macro x, y, len, color
; POZ= (Y*AREA_WIDTH + X) *4;
local loop1, iesire
mov EAX, y
mov EBX, area_width
mul ebx
add EAX, x
shl eax, 2
add eax, area
xor esi, esi
mov edx, len 
loop1:
cmp esi, edx
jae iesire
mov dword ptr[eax], color
add eax, area_width*4
inc esi
jmp loop1
iesire:
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y

draw proc
	push ebp
	mov ebp, esp
	pusha
   
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	; mov eax, area_width
	; mov ebx, area_height
	; mul ebx 
	; shl eax, 2
	; push eax
	; push 255
	; push area
	; call memset
	; add esp, 12
	;AICI PUNEM LINIILE ORIZ SI VERTIC
	line_horizontal xa, ya , line_orizontal_size, 0
	line_vertical xa, ya, line_vertical_size, 0
	line_horizontal xb, yb, line_orizontal_size, 0
	line_vertical xc, yc, line_vertical_size, 0
	mov ecx, 390
	loop2 :
	line_horizontal 190, ecx, line_orizontal_size+2,6ffh
     cmp ecx, 90
	 jne continuare
	 mov ecx, 1
	 continuare:
	loop loop2
	
	line_vertical 190, 90, line_vertical_size, 0
	line_vertical 240, 90, line_vertical_size, 0
	line_vertical 290, 90, line_vertical_size, 0
	line_vertical 340, 90, line_vertical_size, 0
	line_vertical 390, 90, line_vertical_size, 0
	line_vertical 440, 90, line_vertical_size, 0
	
	mov ecx, 407
	
	loop5:
	cmp ecx, 457
	jg continuare5
	line_horizontal 215, ecx, len_buttom1, 6ffh
	inc ecx
	jmp loop5
	continuare5:
	
	mov ecx, 407	
	loop6:
	cmp ecx, 457
	jg continuare6
	line_horizontal 325, ecx, len_buttom1, 6ffh
	inc ecx
	jmp loop6
	continuare6:
	    make_text_macro_simbolu '+', area, 350, 408   ; + = sageata dreapta
		make_text_macro_simbolu ',', area, 240, 408   ; , =sageata stanga
		make_text_macro_simbolu '(', area, poz_minion_x, poz_minion_y    ; ( - minion
			
			; creeare linii butoane
		line_horizontal 215, 407 , len_buttom1, 0
		line_vertical 215, 407, len_buttom2, 0
		line_horizontal 215, 457, len_buttom1, 0
		line_vertical 295, 407, len_buttom2, 0

        line_horizontal 325, 407, len_buttom1, 0
		line_vertical 325, 407, len_buttom2, 0
		line_vertical 405, 407, len_buttom2, 0
		line_horizontal 325, 457, len_buttom1, 0 
	jmp afisare_litere

		
evt_click:
    
	mov eax, [ebp+arg2]
	cmp eax, 215
	jl verif2
	cmp eax, 295
	jg verif2
	mov eax, [ebp+arg3]
	cmp eax, 407
	jl verif2
	cmp eax, 457
	jg verif2
	mov eax, poz_minion_x
	cmp eax, 200
	je final_draw
	make_text_macro_simbolu '-', area, poz_minion_x, poz_minion_y    ;- fundal
	sub poz_minion_x, 50
		make_text_macro_simbolu '(', area, poz_minion_x, poz_minion_y    ; ( - minion
		verif2:
    mov eax, [ebp+arg2]
	cmp eax, 325
	jl button_fail
	cmp eax, 405
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, 407
	jl button_fail
	cmp eax, 457
	jg button_fail
	mov eax, poz_minion_x
	cmp eax, 400
	je final_draw
	make_text_macro_simbolu '-', area, poz_minion_x, poz_minion_y 
	add poz_minion_x, 50
	make_text_macro_simbolu '(', area, poz_minion_x, poz_minion_y    ; ( - minion
	
	
	
	button_fail:	 
	jmp afisare_litere
	
	incrementare_scor:
	inc scor
	jmp revenire1
	verificare1:
	cmp ebx, 200
	je incrementare_scor
	jmp revenire1

	
evt_timer:
	inc counter
	inc counter
	inc counter
	inc counter
	inc counter
	cmp counter, 340
	jne cont
	make_text_macro_simbolu '-', area, 200, counter
	mov eax, 90
	mov counter, eax
	cont:
		make_text_macro_simbolu '(', area, 200, counter
	mov edx, counter
	sub edx, 1
make_text_macro_simbolu '-', area, 200, edx
make_text_macro_simbolu ')', area, 200, counter
	
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	inc counter1
	mov eax, poz_minion_y
	mov ebx, poz_minion_x
	cmp counter1, eax
	je verificare1
	revenire1:
	cmp counter1, 340
	jne cont1
	make_text_macro_simbolu '-', area, 400, counter1
	mov eax, 90
	mov counter1, eax
	cont1:
		mov edx, counter1
	sub edx, 1
make_text_macro_simbolu '-', area, 400, edx
make_text_macro_simbolu ')', area, 400, counter1
make_text_macro_simbolu '-', area, 400, edx
inc counter2	
inc counter2	
inc counter2	
inc counter2	
inc counter2	
cmp counter2, 340
jne cont2
make_text_macro_simbolu '-', area, 200, counter2
mov eax, 200
mov counter2, eax
cont2:
mov edx, counter2
sub edx, 1
make_text_macro_simbolu '-', area, 200, edx
make_text_macro_simbolu '*', area, 200, counter2


inc counter3
inc counter3
inc counter3
inc counter3
inc counter3
cmp counter3, 340
jne cont3
make_text_macro_simbolu '-', area, 250, counter3
mov eax, 250
mov counter3, eax
cont3:
mov edx, counter3
sub edx, 1
make_text_macro_simbolu '-', area, 250, edx
make_text_macro_simbolu ')', area, 250, counter3

inc counter4
inc counter4
inc counter4
inc counter4
inc counter4
cmp counter4, 340
jne cont4
make_text_macro_simbolu '-', area, 250, counter4
mov eax, 90
mov counter4, eax
cont4:
mov edx, counter4
sub edx, 1
make_text_macro_simbolu '-', area, 250, edx
make_text_macro_simbolu '*', area, 250, counter4

inc counter5
inc counter5
inc counter5
inc counter5
inc counter5
cmp counter5, 340
jne cont5
make_text_macro_simbolu '-', area, 400, counter5
mov eax, 90
mov counter5, eax
cont5:
mov edx, counter5
sub edx, 1
make_text_macro_simbolu '-', area, 400, edx
make_text_macro_simbolu '*', area, 400, counter5

inc counter6
inc counter6
inc counter6
inc counter6
inc counter6
cmp counter6, 340
jne cont6
make_text_macro_simbolu '-', area, 300, counter6
mov eax, 90
mov counter6, eax
cont6:
mov edx, counter6
sub edx, 1
make_text_macro_simbolu '-', area, 300, edx
make_text_macro_simbolu ')', area, 300, counter6

inc counter7
inc counter7
inc counter7
inc counter7
inc counter7
cmp counter7, 340
jne cont7
make_text_macro_simbolu '-', area, 300, counter7
mov eax, 150
mov counter7, eax
cont7:
mov edx, counter7
sub edx, 1
make_text_macro_simbolu '-', area, 300, edx
make_text_macro_simbolu '*', area, 300, counter7

inc counter8
inc counter8
inc counter8
inc counter8
inc counter8
cmp counter8, 340
jne cont8
make_text_macro_simbolu '-', area, 350, counter8
mov eax, 150
mov counter8, eax
cont8:
mov edx, counter8
sub edx, 1
make_text_macro_simbolu '-', area, 350, edx
make_text_macro_simbolu ')', area, 350, counter8

afisare_litere:
make_text_macro 'S', area, 10, 10
make_text_macro 'C', area, 20, 10
make_text_macro 'O', area, 30, 10
make_text_macro 'R', area, 40, 10
	;afisam valoarea scor-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, scor
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 80, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 70, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 60, 10

	;scriem un mesaj
	make_text_macro 'M', area, 240, 50
	make_text_macro 'I', area, 250, 50
	make_text_macro 'N', area, 260, 50
	make_text_macro 'I', area, 270, 50
	make_text_macro 'O', area, 280, 50
	make_text_macro 'N', area, 290, 50
	
	
	make_text_macro 'R', area, 320, 50
	make_text_macro 'U', area, 330, 50
	make_text_macro 'S', area, 340, 50
	make_text_macro 'H', area, 350, 50
	
	make_text_macro '2', area, 380, 50
	make_text_macro 'D', area, 390, 50
	
	; AICI PUNEM LINIILE ORIZ SI VERTIC
	; line_horizontal xa, ya , line_orizontal_size, 0
	; line_vertical xa, ya, line_vertical_size, 0
	; line_horizontal xb, yb, line_orizontal_size, 0
	; line_vertical xc, yc, line_vertical_size, 0
	;mov esi, 230
	
	
		
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:

	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20	
	;terminarea programului
	push 0
	call exit
end start
