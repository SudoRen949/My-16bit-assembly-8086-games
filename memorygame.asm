BITS 16
ORG 100h

section .data

	color_yellowblack		dw 0E0h
	color_blackwhite		dw 00Fh
	color_blacklgray		dw 007h
	color_cyanwhite			dw 03Fh
	color_brownwhite		dw 06Fh
	color_magentawhite		dw 05Fh
	color_redwhite			dw 04Fh
	color_bluewhite			dw 01Fh
	color_whiteblack		dw 0F0h
	color_greenwhite		dw 02Fh
	color_grayblack			dw 08Fh
	
	randomseed				db 0
	
	screensize				dw 2000
	
	array					db 9 dup(0)
	
	menu_play				db "    Start    ", 0
	menu_quit				db "    Quit   	 ", 0
	menu_lsel				db '>', 0
	menu_rsel				db '<', 0
	menu_selected			db 0
	menu_help				db "", 0

	key_escape				db 27
	key_enter				db 13
	key_space				db ' ', 0
	
	; Game Variables
	
	score					dw 0
	score_text				db "High Score: ", 0
	score_delay				db 0
	
	timer					dw 0
	timer_text				db "Timer:", 0
	timer_delay				db 0
	
	game_pause				db "    Pause     ", 0
	game_reset				db "    Reset     ", 0
	game_name				db "      MEMORY TILES     ", 0
	
	color_arrays3x3			db 1,2,3,4,5,6,7,8,9
	color_array3x3_empty	db 0,0,0,0,0,0,0,0,0
	guess_array3x3			db 0,0,0,0,0,0,0,0,0
	
	difficulty				db 0		; 0 = easy, 1 = medium, 2 = hard
	
	array_position			db 0,0		; index 0 = x, index 1 = y
	
	flashed					db 0		; boolean
	flash_speed				dw 25		;
	
	input_text				db "Input Guess: ", 0
	
section .text

	global main

main:

	xor ax, ax
	mov es, ax
	
	mov ah, 0
	mov al, 03h
	int 10h			; setup video mode (80x25 16 colors, 8 pages)

	mov ax, 1003h
	mov bx, 0
	int 10h			; enable bright colors
	
	call hidecursor
	
	.menu:
	
		mov byte [difficulty], 1
		mov word [flash_speed], 25
		mov word [score], 0
		mov byte [array_position], 0
		mov byte [array_position+1], 0
	
		mov dx, 0
		call movecursor
		
		mov cx, [screensize]
		mov bl, [color_blackwhite]
		call clearbackground
		
		mov cl, 29
		mov ch, 3
		mov dl, 23
		mov dh, 3
		mov bl, [color_yellowblack]
		call drawbox
		
		mov dl, 29
		mov dh, 4
		call movecursor
		
		mov si, game_name
		call printstring
		
		.buttons:
		
			mov cl, 34
			mov ch, 11
			mov dl, 13
			mov dh, 3
			mov bl, [color_yellowblack]
			call drawbox
			
			mov dl, 34
			mov dh, 12
			call movecursor
			
			mov si, menu_play
			call printstring
			
			mov cl, 34
			mov ch, 15
			mov dl, 13
			mov dh, 3
			mov bl, [color_yellowblack]
			call drawbox
			
			mov dl, 34
			mov dh, 16
			call movecursor
			
			mov si, menu_quit
			call printstring
			
		.selector:
		
			cmp byte [menu_selected], 0
			je .selectplay
			
			jmp .selectquit
			
			.selectplay:
		
				mov dh, 12
				
				jmp .drawbuttons
				
			.selectquit:
			
				mov dh, 16
			
			.drawbuttons:
			
				mov dl, 32
				call movecursor
				
				mov si, menu_lsel
				call printstring
				
				mov dl, 48
				call movecursor
				
				mov si, menu_rsel
				call printstring
			
		.keywait:
		
			call keypress
			
			cmp byte al, [key_space]
			je .select
			
			cmp byte al, [key_enter]
			je .confirmselect
			
			jmp .keywait
			
		.select:
		
			xor byte [menu_selected], 1
			
			jmp .menu
			
		.confirmselect:
		
			cmp byte [menu_selected], 0
			jne quitgame
			
			jmp playgame

playgame:

	mov byte [flashed], 0
	
	call hidecursor
	
	; clear arrays
	
	mov cx, 9
	mov bx, 0
	
	.scan1:
	
		mov byte [color_array3x3_empty + bx], 0
		mov byte [guess_array3x3 + bx], 0
	
		inc bx
	
		loop .scan1

	call initrandomseed
	
	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, [color_blackwhite]
	call clearbackground
	
	.scorebar:
		
		mov cx, 80
		mov bl, [color_cyanwhite]
		call clearbackground
		
		mov dl, 30
		mov dh, 0
		call movecursor
		
		mov si, score_text
		call printstring
		
		mov ax, [score]
		call wordtostring
		
		mov si, ax
		call printstring
		
	.timerdraw:
		
		mov dl, 65
		mov dh, 4
		call movecursor
		
		;mov si, timer_text
		;call printstring
		
		;mov ax, [timer]
		;call wordtostring
		
		;mov si, ax
		;call printstring
		
		;inc byte [timer_delay]
		
		;cmp byte [timer_delay], 15
		;je .inctimer
		
		;jmp .inputfield
		
		;.inctimer:
		
		;	inc word [timer]
		
	.inputfield:
	
		mov dl, 27
		mov dh, 22
		call movecursor
		
		mov si, input_text
		call printstring
	
	.drawgrid:
		
		.drawgridnow:
			
			mov word [.num], 1
			mov byte [.onrow], 0
			mov byte [.oncol], 0
			
			mov byte [array_position], 25
			mov byte [array_position+1], 4
			
			mov byte cl, [array_position]
			mov byte ch, [array_position+1]
			mov dl, 30
			mov dh, 16
			mov bl, [color_yellowblack]
			call drawbox
			
			mov cx, 0
			mov bx, 0
			mov byte [.onrow], 0
			mov byte [.oncol], 0
			
			.loops1:
			
				push cx
				
				.setupcell:
				
					cmp byte [color_arrays3x3+bx], 1
					je .colorred
					
					cmp byte [color_arrays3x3+bx], 2
					je .colorgreen
					
					cmp byte [color_arrays3x3+bx], 3
					je .colorblue
					
					cmp byte [color_arrays3x3+bx], 4
					je .colorlgray
					
					cmp byte [color_arrays3x3+bx], 5
					je .colormagenta
					
					cmp byte [color_arrays3x3+bx], 6
					je .colorcyan
					
					cmp byte [color_arrays3x3+bx], 7
					je .colorblack
					
					cmp byte [color_arrays3x3+bx], 8
					je .colorwhite
					
					cmp byte [color_arrays3x3+bx], 9
					je .colorbrown
					
					.colorred:
						
						push bx
						
						mov bl, [color_redwhite]
						
						jmp .drawcell
						
					.colorgreen:
					
						push bx
					
						mov bl, [color_greenwhite]
						
						jmp .drawcell
						
					.colorblue:
					
						push bx
					
						mov bl, [color_bluewhite]
						
						jmp .drawcell
						
					.colorlgray:
					
						push bx
					
						mov bl, [color_grayblack]
						
						jmp .drawcell
						
					.colormagenta:
					
						push bx
					
						mov bl, [color_magentawhite]
						
						jmp .drawcell
						
					.colorcyan:
					
						push bx
					
						mov bl, [color_cyanwhite]
						
						jmp .drawcell
						
					.colorblack:
					
						push bx
					
						mov bl, [color_blackwhite]
						
						jmp .drawcell
						
					.colorwhite:
					
						push bx
					
						mov bl, [color_whiteblack]
						
						jmp .drawcell
						
					.colorbrown:
					
						push bx
					
						mov bl, [color_brownwhite]
						
					.drawcell:
					
						mov byte cl, [array_position]
						mov byte dl, [array_position]
						
						cmp byte [.oncol], 0
						je .gocol1
						
						cmp byte [.oncol], 1
						je .gocol2
						
						cmp byte [.oncol], 2
						je .gocol3
						
						jmp .checky
						
						.gocol1:
						
							add cl, 1
							add dl, 4
							
							jmp .checky
							
						.gocol2:
						
							add cl, 11
							add dl, 14
							
							jmp .checky
							
						.gocol3:
						
							add cl, 21
							add dl, 24
							
						.checky:
						
							mov byte ch, [array_position+1]
							mov byte dh, [array_position+1]
							
							cmp byte [.onrow], 0
							je .gorow1
							
							cmp byte [.onrow], 1
							je .gorow2
							
							cmp byte [.onrow], 2
							je .gorow3
							
							jmp .contdraw
							
							.gorow1:
							
								add ch, 1
								add dh, 2
								
								jmp .contdraw
								
							.gorow2:
							
								add ch, 6
								add dh, 7
								
								jmp .contdraw
								
							.gorow3:
							
								add ch, 11
								add dh, 12
						
						.contdraw:
						
							push dx
							
							mov dl, 8
							mov dh, 4
							call drawbox
							
							pop dx
							
							call movecursor
							
							pop bx
							
							mov ax, [.num]
							call wordtostring
							
							mov si, ax
							call printstring							

				pop cx
				
				inc bx
				inc byte [.oncol]
				inc word [.num]
				
				cmp cx, 2
				je .updateonrow
				
				cmp cx, 5
				je .updateonrow
				
				jmp .contend
				
				.updateonrow:
				
					inc byte [.onrow]
					mov byte [.oncol], 0
				
				.contend:
				
					inc cx
				
					cmp cx, 9
					jne .loops1
				
			cmp byte [flashed], 1
			je .setupinput
			
			jmp .flash
			
			.onrow	db 0
			.oncol	db 0
			.num	dw 1
		
	.flash:
	
		; creates box to hide the colors
		
		cmp byte [difficulty], 0
		je .easymode
		
		cmp byte [difficulty], 1
		je .mediummode
		
		cmp byte [difficulty], 2
		je .hardmode
		
		.easymode:
		
			mov cx, 1
			mov word [flash_speed], 25
			
			jmp .scan2
			
		.mediummode:
		
			mov cx, 2
			mov word [flash_speed], 15
			
			jmp .scan2
			
		.hardmode:
		
			mov cx, 3
			mov word [flash_speed], 5
		
		.scan2:
		
			push cx
			
			mov byte cl, [array_position]
			mov byte ch, [array_position+1]
			
			push cx
			
			mov word cx, [flash_speed]
			call delay
			
			mov ax, 1
			mov bx, 9
			call randomrange
			
			cmp cx, 1
			je .go1
			
			cmp cx, 2
			je .go2
			
			cmp cx, 3
			je .go3
			
			cmp cx, 4
			je .go4
			
			cmp cx, 5
			je .go5
			
			cmp cx, 6
			je .go6
			
			cmp cx, 7
			je .go7
			
			cmp cx, 8
			je .go8
			
			cmp cx, 9
			je .go9
			
			.go1:

				mov byte [guess_array3x3 + 0 * 8], 1

				pop cx
			
				add cl, 1
				add ch, 1
				
				jmp .drawflash
			
			.go2:
			
				mov byte [guess_array3x3 + 1 * 8], 2

				pop cx
			
				add cl, 11
				add ch, 1
				
				jmp .drawflash
				
			.go3:
			
				mov byte [guess_array3x3 + 2 * 8], 3

				pop cx
			
				add cl, 21
				add ch, 1
				
				jmp .drawflash
				
			.go4:
			
				mov byte [guess_array3x3 + 3 * 8], 4

				pop cx
				
				add cl, 1
				add ch, 6
				
				jmp .drawflash
				
			.go5:
			
				mov byte [guess_array3x3 + 4 * 8], 5

				pop cx
			
				add cl, 11
				add ch, 6
				
				jmp .drawflash
				
			.go6:
			
				mov byte [guess_array3x3 + 5 * 8], 6

				pop cx
			
				add cl, 21
				add ch, 6
				
				jmp .drawflash
				
			.go7:
			
				mov byte [guess_array3x3 + 6 * 8], 7

				pop cx
			
				add cl, 1
				add ch, 11
				
				jmp .drawflash
				
			.go8:
			
				mov byte [guess_array3x3 + 7 * 8], 8

				pop cx
			
				add cl, 11
				add ch, 11
				
				jmp .drawflash
				
			.go9:
			
				mov byte [guess_array3x3 + 8 * 8], 9

				pop cx
			
				add cl, 21
				add ch, 11
			
			.drawflash:
				
				mov dl, 8
				mov dh, 4
				mov bl, [color_yellowblack]
				call drawbox
			
			.done:
			
				pop cx
			
				dec cx
				
				cmp cx, 0
				jne .scan2
			
		mov byte [flashed], 1
		
	.redraw:
	
		jmp .drawgrid

	.setupinput:
	
		mov dl, 41
		mov dh, 22
		call movecursor
		
		call showcursor
		
	.key:
	
		call keypress
		
		cmp byte al, [key_escape]
		je quitgame
		
		cmp byte al, [key_enter]
		je .confirm
		
		.checknum:
		
			; scans if the element is zero then put the number in that index,
			; else if not 0 then skip that index.
			
			cmp al, '1'
			je .add1
			
			cmp al, '2'
			je .add2
			
			cmp al, '3'
			je .add3
			
			cmp al, '4'
			je .add4
			
			cmp al, '5'
			je .add5
			
			cmp al, '6'
			je .add6
			
			cmp al, '7'
			je .add7
			
			cmp al, '8'
			je .add8
			
			cmp al, '9'
			je .add9
			
			jmp .key
			
			.add1:
			
				mov byte [color_array3x3_empty + 0 * 8], 1
				
				jmp .printkey
						
			.add2:
			
				mov byte [color_array3x3_empty + 1 * 8], 2
				
				jmp .printkey
				
			.add3:
			
				mov byte [color_array3x3_empty + 2 * 8], 3
						
				jmp .printkey
				
			.add4:
			
				mov byte [color_array3x3_empty + 3 * 8], 4
						
				jmp .printkey
				
			.add5:
			
				mov byte [color_array3x3_empty + 4 * 8], 5
						
				jmp .printkey
				
			.add6:
			
				mov byte [color_array3x3_empty + 5 * 8], 6
						
				jmp .printkey
				
			.add7:
			
				mov byte [color_array3x3_empty + 6 * 8], 7
						
				jmp .printkey
				
			.add8:
			
				mov byte [color_array3x3_empty + 7 * 8], 8
						
				jmp .printkey
				
			.add9:
			
				mov byte [color_array3x3_empty + 8 * 8], 9
				
	.printkey:
	
		mov ah, 0Ah
		mov bh, 0
		mov cx, 1
		int 10h				; print that number
	
		add dl, 2
		call movecursor
	
		jmp .key
		
	.confirm:
	
		mov byte [.wrongcount], 0
	
		mov cx, 9
		mov bx, 0
		
		; 1,0,0,0,0
		; 1,0,0,0,0
		
		.scan:
		
			mov byte al, [guess_array3x3 + bx]
			mov byte dl, [color_array3x3_empty + bx]
			
			cmp dl, al
			jne .countwrong
			
			jmp .skip
			
			.countwrong:
			
				inc byte [.wrongcount]
		
			.skip:
				
				inc bx
				
				loop .scan
		
		cmp byte [.wrongcount], 0
		jne gameover
		
		add word [score], 10
		
		inc byte [difficulty]
		
		cmp byte [difficulty], 2
		jg youwin
		
		jmp playgame
		
		.wrongcount		db 0

youwin:

	call hidecursor
	
	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, [color_cyanwhite]
	call clearbackground
	
	mov dl, 22
	mov dh, 10
	call movecursor
	
	mov si, .text1
	call printstring
	
	mov dl, 26
	mov dh, 13
	call movecursor
	
	mov si, .text2
	call printstring
	
	.key:
	
		call keypress
		
		cmp al, 0
		jne main.menu
	
		jmp .key
	
	.text1		db "Congrats, you guessed all of them. :)", 0
	.text2		db "Press any key to start again.", 0
	
gameover:

	call hidecursor

	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, [color_redwhite]
	call clearbackground
	
	mov dl, 29
	mov dh, 10
	call movecursor
	
	mov si, .text1
	call printstring
	
	mov dl, 26
	mov dh, 13
	call movecursor
	
	mov si, .text2
	call printstring
	
	.key:
	
		call keypress
		
		cmp al, 0
		jne main.menu
	
		jmp .key
	
	.text1		db "Sorry, wrong guess :(", 0
	.text2		db "Press any key to start again.", 0

quitgame:

	mov dx, 0
	call movecursor
	
	mov cx, [screensize]
	mov bl, [color_blacklgray]
	call clearbackground
	
	call showcursor
	
	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx
	
	int 20h











; variables:		si = string to be printed
printstring:

	pusha
	
	mov ah, 0Eh
	
	.scan:
	
		lodsb
	
		int 10h
		
		cmp al, 0
		jne .scan
	
	popa
	
	ret

; variables:		cx = number of scans
;					bl = background and foreground color
clearbackground:

	push ax
	
	mov bh, 0
	mov al, ' '
	mov ah, 09h
	int 10h
	
	pop ax
	
	ret

; variables:		dh = y
;					dl = x
movecursor:

	push ax
	push bx
	
	mov bh, 0
	mov ah, 2
	int 10h
	
	pop bx
	pop ax
	
	ret

; variables:		none
hidecursor:

	pusha
	
	mov ah, 1
	mov ch, 32
	int 10h
	
	popa
	
	ret

; variables:		none
showcursor:

	pusha
	
	mov ah, 1
	mov ch, 6
	mov cl, 7
	
	int 10h
	
	popa
	
	ret

; variables:		none
initrandomseed:

	pusha
	
	mov bx, 0
	mov al, 0x02				; MINUTE
	out 0x70, al				; send signal to the system clock
	in al, 0x71					; get the value of system clock (minute)
	mov bl, al					; transfer it to BL register
	shl bx, 8					; shift BX to left (BL value moves to BH register)
	mov al, 0					; SECOND
	out 0x70, al
	in al, 0x71
	
	mov bl, al
	mov word [randomseed], bx	; Seed will be something like 0x4435 (if it were 44 minutes and 35 seconds after the hour)
	
	popa
	
	ret

; variables:		ax = high int
;					bx = low int
;					cx = random int (output)
randomrange:

	push ax
	push bx
	push dx
	
	sub bx, ax				; We want a number between 0 and (high-low)
	call .genrandom
	
	mov dx, bx
	add dx, 1
	mul dx
	mov cx, dx
	
	pop dx
	pop bx
	pop ax
	
	add cx, ax				; Add the low offset back
	
	ret
	
	.genrandom:
		
		push dx
		
		mov ax, [randomseed]
		mov dx, 23167
		mul dx				; DX:AX = AX * DX
		
		add ax, 12409
		adc dx, 0
		mov [randomseed], ax
	 	
		pop dx
		
		ret

; variables:		al = key (output)
checkkey:

	mov ah, 0Bh
	
	int 21h

	ret

; variables:		al = key (output)
keypress:

	mov ah, 00h

	int 16h

	ret

; variables:		cx = delay in microseconds
delay:

	mov ah, 86h
	
	int 15h

	ret

; variables:		ax = word data
;					ax = string data (output)
wordtostring:

	pusha
	
	mov cx, 0		; loop counter
	mov bx, 10		; divisor
	mov di, .arr	; destination pointer for our string

	.pusher:

		mov dx, 0		; remainder
		div bx			; divide AX by 10, AX*BX
		inc cx			; loop counter
		
		push dx			; confine the qoutient
		
		test ax, ax		; is qoutient zero?
		jnz .pusher		; if not, loop back

	.popper:

		pop dx			; get back our qoutient
		
		add dl, '0' 	; add character 48 to it
		mov [di], dl 	; put it to the array
		inc di
		dec cx			; decrease loop counter
		jnz .popper		; loop again if not zero

	mov byte [di], 0
	
	popa

	mov ax, .arr

	ret

	.arr	times 7 db 0

; variables:		cl = x position
;					ch = y position
;					dl = width
;					dh = height
;					bl = color
drawbox:

	push ax
	
	mov byte [.position], cl
	mov byte [.position+1], ch
	mov byte [.size], dl
	mov byte [.size+1], dh
	mov byte dl, [.position]
	mov byte dh, [.position+1]
	call movecursor
	
	mov byte cl, [.size+1]
	
	.height:
		
		push cx
		
		mov byte cl, [.size]
		
		.width:
			
			push cx
			
			mov cx, 1
			call clearbackground
			
			pop cx
			
			dec cl

			inc dl
			call movecursor
			
			cmp cl, 0
			jne .width
		
		pop cx
		
		dec cl

		mov byte dl, [.position]

		inc dh
		call movecursor
		
		cmp cl, 0
		jne .height
	
	pop ax
	ret
	
	.position	db 0,0
	.size		db 0,0





