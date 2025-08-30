

bits 16
org 100h

section .data

	randomseed					dw 0

	color_greenblack			db 0A0h
	color_brownwhite			db 06Fh
	color_yellowblack			db 0E0h
	color_blacklgray			db 007h
	color_skyblack				db 0B0h
	color_dgreenblack			db 02Fh
	color_graywhite				db 08Fh
	
	game_title					db "  PINYA PACKER!  ", 0

	menu_play					db "   Play   ", 0
	menu_exit					db "   Exit   ", 0
	menu_lsel					db "> ", 0
	menu_rsel					db " <", 0
	menu_selected				db 0
	
	key_space					db 32
	key_escape					db 27
	key_enter					db 13
	
	timer						db "Timer: ", 0
	timer_count					dw 0
	timer_delay					db 0
	
	life						db "Life: ", 0
	life_count					dw 3
	
	level						dw 1
	level_set					db 0
	level_text					db "Level: ", 0

	score						db "Score: ", 0
	score_count					dw 0
	
	highscore					db "Highest Score: ", 0
	highscore_count				dw 0
	
	draw_pinyas					db 0
	
	pinya_packed				db "Pinya Packed: ", 0
	pinya_packed_count			db 0
	
	leaderboard1				dw 0

section .text

	global mainapp

mainapp:

	mov ax, 0
	mov es, ax
	
	mov ah, 00h
	mov al, 03h
	int 10h
	
	mov ax, 1003h
	int 10h
	
	call hidecursor
	
menu:

	call hidecursor

	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, [color_yellowblack]
	call clearbackground
	
	.title:
	
		mov cl, 32
		mov ch, 4
		mov dl, 17
		mov dh, 3
		mov bl, [color_greenblack]
		mov si, game_title
		call drawbutton

	.buttons:
	
		mov cl, 35
		mov ch, 10
		mov dl, 10
		mov dh, 3
		mov bl, [color_greenblack]
		mov si, menu_play
		call drawbutton
		
		mov cl, 35
		mov ch, 14
		mov dl, 10
		mov dh, 3
		mov bl, [color_greenblack]
		mov si, menu_exit
		call drawbutton
		
	.otherstlyes:
	
		mov cl, 0
		mov ch, 20
		mov dl, 5
		mov dh, 5
		mov bl, [color_brownwhite]
		call drawbox
		
		mov cl, 0
		mov ch, 23
		mov dl, 12
		mov dh, 2
		mov bl, [color_brownwhite]
		call drawbox
		
		mov cl, 72
		mov ch, 0
		mov dl, 5
		mov dh, 2
		mov bl, [color_brownwhite]
		call drawbox
		
		mov cl, 77
		mov ch, 0
		mov dl, 3
		mov dh, 5
		mov bl, [color_brownwhite]
		call drawbox
		
		mov cl, 10
		mov ch, 5
		call drawpinya
		
		mov cl, 55
		mov ch, 14
		call drawpinya
		
		mov cl, 25
		mov ch, 17
		call drawpinya
		
	.selector:
	
		cmp byte [menu_selected], 0
		je .sfirst
		
		jmp .ssecond
	
		.sfirst:
		
			mov dh, 11
			
			jmp .drawselector
			
		.ssecond:
		
			mov dh, 15
		
		.drawselector:
		
			mov dl, 33
			call movecursor
			
			mov si, menu_lsel
			call printstring
			
			mov dl, 45
			call movecursor
			
			mov si, menu_rsel
			call printstring
		
	.key:
	
		call keypress
		
		cmp byte al, [key_space]
		je .select
		
		cmp byte al, [key_enter]
		je .confirm
		
		cmp byte al, [key_escape]
		je exit
		
		jmp .key
		
	.select:
	
		xor byte [menu_selected], 1
		
		jmp menu
		
	.confirm:
	
		cmp byte [menu_selected], 0
		je playgame
		
		cmp byte [menu_selected], 1
		je exit
		
		jmp .key

exit:

	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, [color_blacklgray]
	call clearbackground
	
	int 20h

playgame:

	mov byte [level], 1
	mov word [life_count], 3
	mov word [timer_count], 0
	mov word [randomseed], 0
	mov byte [timer_delay], 0
	mov byte [draw_pinyas], 1
	mov word [pinya_packed_count], 0
	
	mov byte [.presstimer], 0

	mov ax, 0

	call initrandomseed			; initialize randomization

	.background:
	
		mov dx, 0
		call movecursor
		
		mov cx, 960
		mov bl, [color_skyblack]
		call clearbackground
		
		; ground
		
		mov dh, 12
		mov dl, 0
		call movecursor
		
		mov cx, 1040
		mov bl, [color_dgreenblack]
		call clearbackground
	
	.timerandlifescore:
	
		mov word ax, [pinya_packed_count]
		mov word [score_count], ax
	
		mov cx, 2
		call delay
	
		mov dh, 1
		mov dl, 1
		call movecursor
		
		mov si, score
		call printstring
		mov ax, [score_count]
		call wordtostring
		mov si, ax
		call printstring
		
		mov dl, 36
		call movecursor
		
		mov si, level_text
		call printstring
		
		mov ax, [level]
		call wordtostring
		mov si, ax
		call printstring
		
		mov dl, 68
		call movecursor

		mov si, life
		call printstring
		mov ax, [life_count]
		call wordtostring
		mov si, ax
		call printstring
		
		mov dl, 1
		mov dh, 23
		call movecursor
		
		mov si, pinya_packed
		call printstring
		mov ax, [pinya_packed_count]
		call wordtostring
		mov si, ax
		call printstring
		
		mov dl, 68
		mov dh, 23
		call movecursor
		
		mov si, timer
		call printstring
		mov ax, [timer_count]
		call wordtostring
		mov si, ax
		call printstring
		
		cmp word [life_count], 0
		je lose
		
		cmp byte [draw_pinyas], 1
		je .spawnpinyas
		
		cmp word [timer_count], 10
		je .nextlevel
		
		inc byte [timer_delay]
		
		cmp byte [timer_delay], 5
		je .inctimer
		
		pusha
		
		call checkkey
		
		cmp al, 0
		jne .key
		
		popa
		
		jmp .timerandlifescore
		
		.inctimer:
		
			mov byte [timer_delay], 0
			
			inc word [timer_count]

			jmp .timerandlifescore
			
		.nextlevel:
		
			inc word [level]
			
			mov word [timer_count], 0
			
			dec word [life_count]
		
	.spawnpinyas:
	
		mov dh, 12
		mov dl, 0
		call movecursor
		
		mov cx, 1040
		mov bl, [color_dgreenblack]
		call clearbackground
		
		mov byte cl, [level]
		mov bx, 0
		
		.spawn:
		
			push cx
			push bx
			
			mov ax, 5
			mov bx, 70
			call randomrange
			
			pop bx
			mov byte [.pinyapositionx+bx], cl
			push bx
			
			mov ax, 12
			mov bx, 19
			call randomrange
			
			pop bx
			
			mov byte [.pinyapositiony+bx], cl
			mov byte cl, [.pinyapositionx+bx]
			mov byte ch, [.pinyapositiony+bx]
			call drawpinya
			
			pop cx
			
			dec cl
			inc bx
			
			cmp cl, 0
			jne .spawn
			
		mov byte [draw_pinyas], 0
		
		cmp word [level], 5
		jg win

		jmp .timerandlifescore
	
	.key:
	
		call keypress
		
		cmp al, [key_escape]
		je exit
		
		cmp al, '1'
		je .pack1
		
		cmp al, '2'
		je .pack2
		
		cmp al, '3'
		je .pack3
		
		cmp al, '4'
		je .pack4
		
		cmp al, '5'
		je .pack5
		
		jmp .timerandlifescore
		
	.pack1:
	
		mov byte cl, [.pinyapositionx]
		mov byte ch, [.pinyapositiony]
		mov dl, 5
		mov dh, 5
		mov bl, [color_graywhite]
		call drawbox
		
		inc byte [.presstimer]
		
		cmp byte [.presstimer], 2
		je .now1
		
		jmp .timerandlifescore
		
		.now1:
		
		mov byte [.presstimer], 0
		
		inc word [pinya_packed_count]
		
		.contcmp:
		
			cmp word [level], 1
			je .updateanddrawpinyas1
			
			jmp .timerandlifescore
		
		.updateanddrawpinyas1:
		
			mov byte [draw_pinyas], 1
			
			inc word [level]
		
			jmp .timerandlifescore
		
	.pack2:
		
		cmp word [level], 1
		je .timerandlifescore
		
		mov byte cl, [.pinyapositionx+1]
		mov byte ch, [.pinyapositiony+1]
		mov dl, 5
		mov dh, 5
		mov bl, [color_graywhite]
		call drawbox
		
		inc byte [.presstimer]
		
		cmp byte [.presstimer], 2
		je .now2
		
		jmp .timerandlifescore
		
		.now2:
		
		mov byte [.presstimer], 0
		
		inc word [pinya_packed_count]
		
		cmp word [level], 2
		je .updateanddrawpinyas2
		
		jmp .timerandlifescore
		
		.updateanddrawpinyas2:
		
			mov byte [draw_pinyas], 1
			
			inc word [level]
		
			jmp .timerandlifescore
		
	.pack3:
		
		cmp word [level], 2
		jle .timerandlifescore
	
		mov byte cl, [.pinyapositionx+2]
		mov byte ch, [.pinyapositiony+2]
		mov dl, 5
		mov dh, 5
		mov bl, [color_graywhite]
		call drawbox
		
		inc byte [.presstimer]
		
		cmp byte [.presstimer], 2
		je .now3
		
		jmp .timerandlifescore
		
		.now3:
		
		mov byte [.presstimer], 0
		
		inc word [pinya_packed_count]
		
		cmp word [level], 3
		je .updateanddrawpinyas3
		
		jmp .timerandlifescore
		
		.updateanddrawpinyas3:
		
			mov byte [draw_pinyas], 1
			
			inc word [level]
		
			jmp .timerandlifescore
		
	.pack4:
	
		cmp word [level], 3
		jle .timerandlifescore
	
		mov byte cl, [.pinyapositionx+3]
		mov byte ch, [.pinyapositiony+3]
		mov dl, 5
		mov dh, 5
		mov bl, [color_graywhite]
		call drawbox
		
		inc byte [.presstimer]
		
		cmp byte [.presstimer], 2
		je .now4
		
		jmp .timerandlifescore
		
		.now4:
		
		mov byte [.presstimer], 0
		
		inc word [pinya_packed_count]
		
		cmp word [level], 4
		je .updateanddrawpinyas4
		
		jmp .timerandlifescore
		
		.updateanddrawpinyas4:
		
			mov byte [draw_pinyas], 1
			
			inc word [level]
		
			jmp .timerandlifescore
		
	.pack5:
	
		cmp word [level], 4
		jle .timerandlifescore
		
		mov byte cl, [.pinyapositionx+4]
		mov byte ch, [.pinyapositiony+4]
		mov dl, 5
		mov dh, 5
		mov bl, [color_graywhite]
		call drawbox
		
		inc byte [.presstimer]
		
		cmp byte [.presstimer], 2
		je .now5
		
		jmp .timerandlifescore
		
		.now5:
		
		mov byte [.presstimer], 0
		
		inc word [pinya_packed_count]
		
		cmp word [level], 5
		je .updateanddrawpinyas5
		
		jmp .timerandlifescore
		
		.updateanddrawpinyas5:
		
			mov byte [draw_pinyas], 1
			
			inc word [level]
		
			jmp .timerandlifescore
	
	.pinyapositionx		db 5 dup(0)
	.pinyapositiony		db 5 dup(0)
	.presstimer			db 0

lose:

win:

	mov dl, 0
	mov dh, 0
	call movecursor
	
	mov cx, 5
	
	.curtain:
	
		push cx
		
		mov cx, 2
		call delay
		
		mov cx, 400
		mov bl, [color_yellowblack]
		call clearbackground
		
		pop cx
		
		add dh, 5
		call movecursor
	
		loop .curtain
	
	;mov dl, 36
	;mov dh, 5
	;call movecursor
	
	;mov si, .say
	;call printstring
	
	mov ax, 0
	
	mov cl, 22
	mov ch, 10
	mov dl, 35
	mov dh, 5
	mov si, .ask
	mov bl, 04Fh
	call drawinput
	
	mov word [leaderboard1], ax
	
	jmp showleaderboard
	
	.say		db "You Win!", 0
	.ask		db "Write your name:", 0

showleaderboard:

	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, [color_yellowblack]
	call clearbackground
	
	mov dl, 34
	mov dh, 5
	call movecursor
	
	mov si, .text
	call printstring
	
	mov dl, 25
	mov dh, 8
	call movecursor
	
	mov si, [leaderboard1]
	call printstring
	
	mov dl, 50
	call movecursor
	
	mov ax, [score_count]
	call wordtostring
	mov si, ax
	call printstring
	
	.key:
		
		call keypress
		
		cmp al, 0
		jne menu
		
		jmp .key
	
	.text		db "Leaderboard", 0
	.hint		db "Press any key to continue.", 0


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

	pusha
	
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
	
	popa
	
	ret
	
	.position	db 0,0
	.size		db 0,0

; variables:		cl:ch = position
drawpinya:

	pusha
	
	mov byte [.position], cl
	mov byte [.position+1], ch
	
	mov cx, 0
	
	mov byte dl, [.position]
	mov byte dh, [.position+1]
	
	.firstline:
	
		mov bl, [color_greenblack]
	
		inc dl
		call movecursor
		
		mov cx, 1
		call clearbackground
		
		inc dl
		inc dl
		call movecursor
		
		mov cx, 1
		call clearbackground
		
	.secondline:
	
		dec dl
		inc dh
		call movecursor
		
		mov cx, 1
		call clearbackground
		
	.thirdline:
	
		mov bl, [color_brownwhite]
		
		dec dl
		inc dh
		call movecursor
		
		mov cx, 3
		call clearbackground
		
	.fourthline:
	
		dec dl
		inc dh
		call movecursor
		
		mov cx, 5
		call clearbackground
		
	.fifthline:
	
		inc dl
		inc dh
		call movecursor
		
		mov cx, 3
		call clearbackground
	
	popa
	
	ret
	
	.position	db 0,0

; variables:		cl:ch = position
;					dl:dh = size
;					si = string
;					bl = color
drawbutton:

	pusha
	
	mov byte [.position], cl
	mov byte [.position+1], ch
	
	call drawbox
	
	mov byte dl, [.position]
	mov byte dh, [.position+1]
	add dh, 1
	call movecursor
	
	call printstring
	
	popa
	
	ret
	
	.position	db 0,0

; variables:		cl:ch = position
;					dl:dh = size
;					si = string
;					bl = color
;					ax = string (output)
drawinput:

	pusha
	
	mov byte [.position], cl
	mov byte [.position+1], ch

	call drawbox
	
	add ch, 3
	add cl, 2
	sub dl, 4
	mov dh, 1
	mov bl, 0F0h
	call drawbox
	
	mov byte dl, [.position]
	add dl, 2
	mov byte dh, [.position+1]
	add dh, 1
	call movecursor
	
	call printstring
	
	mov byte dl, [.position]
	add dl, 2
	mov byte dh, [.position+1]
	add dh, 3
	call movecursor
	
	call showcursor
	
	; clear string array
	
	mov cx, 7
	mov bx, 0
	
	.clearstring:
	
		mov word [.nstring+bx], 0
		inc bx
		loop .clearstring
	
	mov cx, 20
	mov di, .nstring
	
	.write:
	
		mov ah, 1
		int 21h
		
		mov [di], al
		inc di
		
		cmp byte al, [key_enter]
		je .stop
		
		jmp .cont
		
		.stop:
		
			mov cx, 1
		
		.cont:

			dec cx
	
			cmp cx, 0
			jne .write
	
	call hidecursor
	
	popa
	
	mov ax, .nstring
	
	ret
	
	.position	db 0,0
	.nstring	times 7 db 0
