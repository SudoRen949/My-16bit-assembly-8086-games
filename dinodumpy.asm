


BITS 16
ORG 0x100



section .data

	color_cyanwhite		db 03Fh
	color_whiteblack	db 0F0h
	color_greenblack	db 020h
	color_redblack		db 040h
	color_skywhite		db 0BFh
	color_blacklgray	db 007h
	color_lgrayblack	db 070h
	color_blackwhite	db 00Fh
	color_brownwhite	db 06Fh
	color_blueyellow	db 01Eh
	color_bluewhite		db 01Fh
	color_redyellow		db 0CEh
	color_graywhite		db 08Fh
	color_yellowblack	db 0E0h
	color_redwhite		db 04Fh

	randomseed			db 0
	
	screensize			dw 2000
	
	gamename			db "      DINODUMPY     ", 0
	
	menu_play			db "    Start    ", 0
	menu_exit			db "    Exit     ", 0

	option				db 0

	key_escape			db 27
	key_enter			db 13
	key_space			db ' ', 0

	; GAME VARIABLES

	score				dw 0
	score_text			db "Score:", 0
	score_delay			db 0

	obstacle_xpos		db 0
	obstacle_ypos		db 0
	obstacle_height		db 3

	dino_jump			db 0
	dino_onfall			db 0
	dino_canjump		db 1
	dino_ypos			db 0
	dino_speed			db 5

	cloud_counter		db 25

	diamond_counter		db 0

	is_diamond			db 0




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



menu:

	call initrandomseed

	; backgrounds

	mov bl, [color_skywhite]
	mov cx, [screensize]
	call clearbackground

	mov cl, 0
	mov ch, 2
	mov dl, 8
	mov bl, [color_lgrayblack]
	call drawclouds							; clouds shadow

	mov cl, 0
	mov ch, 1
	mov dl, 8
	mov bl, [color_whiteblack]
	call drawclouds							; clouds

	; ground

	mov cl, 0
	mov ch, 19
	mov dl, 80
	mov dh, 6
	mov bl, [color_brownwhite]
	call drawbox

	; box

	mov cl, 25
	mov ch, 16
	mov bl, [color_redblack]
	mov dl, 6
	mov dh, 3
	call drawbox

	; dino *rawrrr*

	mov cl, 12
	mov ch, 12
	mov bl, [color_greenblack]
	call drawdino

	; title

	mov cl, 31
	mov ch, 2
	mov dl, 21
	mov dh, 3
	mov bl, [color_graywhite]
	call drawbox

	mov cl, 30
	mov ch, 1
	mov dl, 21
	mov dh, 3
	mov bl, [color_blueyellow]
	call drawbox

	mov dl, 30
	mov dh, 2
	call movecursor

	mov si, gamename
	call printstring

	.buttons:

		cmp byte [option], 0
		je .setb1red

		jmp .setb1blue

		.setb1red:

			mov bl, [color_redyellow]

			jmp .button1

		.setb1blue:

			mov bl, [color_bluewhite]

		.button1:

			push bx
			
			mov cl, 34
			mov ch, 9
			mov dh, 3
			mov dl, 13
			mov bl, [color_graywhite]
			call drawbox

			pop bx

			mov cl, 33
			mov ch, 8
			mov dh, 3
			mov dl, 13
			call drawbox

			mov dl, 33
			mov dh, 9
			call movecursor

			mov si, menu_play
			call printstring

		cmp byte [option], 1
		je .setb2red

		jmp .setb2blue

		.setb2red:

			mov bl, [color_redyellow]

			jmp .button2

		.setb2blue:

			mov bl, [color_bluewhite]

		.button2:

			push bx
			
			mov cl, 34
			mov ch, 14
			mov dh, 3
			mov dl, 13
			mov bl, [color_graywhite]
			call drawbox

			pop bx

			mov cl, 33
			mov ch, 13
			mov dh, 3
			mov dl, 13
			call drawbox

			mov dl, 33
			mov dh, 14
			call movecursor

			mov si, menu_exit
			call printstring

	.keywait:

		call keypress

		cmp al, ' '
		je .chooseopt

		cmp al, [key_escape]
		je exit

		cmp al, [key_enter]
		je .whatoption

		jmp .keywait

	.chooseopt:

		xor byte [option], 1

		jmp .buttons

	.whatoption:

		cmp byte [option], 0
		je playgame

		cmp byte [option], 1
		je exit

		jmp .keywait



playgame:

	; RESET GAME VARIABLES

	mov word [score], 0
	mov byte [obstacle_xpos], 72
	mov byte [obstacle_ypos], 16
	mov byte [dino_ypos], 6
	mov byte [is_diamond], 0
	mov byte [diamond_counter], 0
	mov byte [dino_speed], 4

	.ground:

		mov cl, 0
		mov ch, 19
		mov dl, 80
		mov dh, 6
		mov bl, [color_brownwhite]
		call drawbox

	.background:

		mov cx, 2
		call delay

		mov dx, 0
		call movecursor

		mov bl, [color_skywhite]
		mov cx, 1520
		call clearbackground

		mov cl, 2
		mov ch, 1
		mov dl, 6
		mov dh, 4
		mov bl, [color_whiteblack]
		call drawbox

		mov cl, 3
		mov ch, 2
		mov dl, 4
		mov dh, 2
		mov bl, [color_yellowblack]
		call drawbox

		mov cl, 0
		mov ch, 2
		mov dl, 8
		mov bl, [color_lgrayblack]
		call drawclouds							; clouds shadow
	
		mov cl, 0
		mov ch, 1
		mov dl, 8
		mov bl, [color_whiteblack]
		call drawclouds							; clouds

	.score:

		mov cl, 62
		mov ch, 1
		mov dl, 15
		mov dh, 3
		mov bl, [color_bluewhite]
		call drawbox

		mov dl, 64
		mov dh, 2
		call movecursor

		mov si, score_text
		call printstring

		mov ax, [score]
		call wordtostring
		mov si, ax
		call printstring

		inc byte [score_delay]

		cmp byte [score_delay], 5
		je .increasescore

		jmp .player

		.increasescore:

			mov byte [score_delay], 0

			inc word [score]

			cmp word [score], 50
			jge .aa

			jmp .bb

			.aa:

				cmp word [score], 51
				jl .speedup

				jmp .player

			.bb:

				cmp word [score], 100
				jge .cc					; at score 100 maintain the speed

				jmp .player

				.cc:

					cmp word [score], 101
					jl .speedup

					jmp .player

			.speedup:

				add byte [dino_speed], 2

	.player:

		
		cmp byte [dino_jump], 0
		jne .jumpnow

		jmp .fallback

		.jumpnow:

			mov byte [dino_ypos], 6

			inc byte [dino_onfall]
			
			jmp .drawdino

		.fallback:

			mov byte [dino_ypos], 12

		.drawdino:

			mov cl, 10
			mov byte ch, [dino_ypos]
			mov bl, [color_greenblack]
			call drawdino
			
			cmp byte [dino_onfall], 6
			jge .resetjump

			jmp .obstacle

			.resetjump:

				mov byte [dino_onfall], 0

				mov byte [dino_jump], 0

	.obstacle:

		cmp byte [diamond_counter], 15
		je .drawdiamond
		
		cmp byte [diamond_counter], 16
		je .resetdiacount

		jmp .drawbox

		.resetdiacount:

			mov byte [diamond_counter], 0
			mov byte [is_diamond], 0

			jmp .drawbox

		.drawdiamond:

			mov byte [is_diamond], 1

			mov byte cl, [obstacle_xpos]
			mov byte ch, 13
			mov bl, [color_cyanwhite]
			call drawdiamond

			jmp .moveobs

		.drawbox:
	
			mov byte cl, [obstacle_xpos]
			mov byte ch, [obstacle_ypos]
			mov byte dh, [obstacle_height]
			mov bl, [color_redblack]
			mov dl, 7
			call drawbox

		.moveobs:

			push ax

			mov byte al, [dino_speed]
			sub byte [obstacle_xpos], al

			pop ax

			; ----- SIMPLE COLLISION DETECTION ----

			cmp byte [obstacle_xpos], 6
			jle .checkypos

			jmp .contchecking
		
			.checkypos:
	
				cmp byte [dino_ypos], 6
				je .contchecking				; ignore if the dino jumped

				.checkifdiamond:				; but before we end the game, check if its a diamond first

					cmp byte [is_diamond], 1
					je .addbonus				; check if collided with the diamond

					jmp endgame					; if not a diamond then game over

					.addbonus:

						add word [score], 5		; else add its bonus score

			.contchecking:
		
				cmp byte [obstacle_xpos], 2
				jle .resetxpos
		
				jmp .maintainxpos
		 
			.resetxpos:
	
				mov byte [obstacle_xpos], 72

				inc byte [diamond_counter]
	
				mov ax, 1
				mov bx, 3
				call randomrange
		
				cmp cx, 2
				je .maketall
		
				mov byte [obstacle_height], 3
				mov byte [obstacle_ypos], 16
	
				jmp .maintainxpos
		
				.maketall:
		
					mov byte [obstacle_height], 5
					mov byte [obstacle_ypos], 14
	
			.maintainxpos:
	
				pusha
		
				call checkkey
		
				cmp al, 0
				jne .keypresses
		
				popa
	
				mov byte [dino_canjump], 1
	
				jmp .background

	.keypresses:

		call keypress

		cmp byte al, [key_escape]
		je main

		cmp byte al, [key_space]
		je .canijump

		jmp .background

	.canijump:

		cmp byte [dino_canjump], 0
		jne .jump

		jmp .background

	.jump:

		mov byte [dino_jump], 1
		mov byte [dino_canjump], 0

		jmp .background


endgame:

	mov dx, 0
	call movecursor

	mov bl, [color_redwhite]
	mov cx, 2000
	call clearbackground

	mov dh, 2
	mov dl, 35
	call movecursor

	mov si, .gameover
	call printstring

	mov dh, 9
	mov dl, 31
	call movecursor

	mov si, .hscore
	call printstring

	mov word ax, [score]
	call wordtostring

	mov si, ax
	call printstring		; print score

	mov dh, 18

	mov dl, 30
	call movecursor

	mov si, .presskey1
	call printstring

	inc dh
	mov dl, 28
	call movecursor

	mov si, .presskey2
	call printstring

	.keywait:

		call keypress

		cmp al, 'p'
		je main

		cmp al, 'P'
		je main

		cmp byte al, [key_escape]
		je exit

		jmp .keywait

	.gameover		db "GAME OVER", 0
	.hscore			db "Highest Score: ", 0
	.presskey1		db "Press P to play again.", 0
	.presskey2		db "Press ESC to accept faith.", 0


exit:

	call showcursor

	mov dx, 0
	call movecursor

	mov bl, [color_blacklgray]
	mov cx, 2000
	call clearbackground

	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0

	int 20h








; HELPFUL FUNCTIONS









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








; DRAWABLE OBJECTS











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


; variables:		cl = x position
;					ch = y position
;					bl = color
drawdiamond:

	push ax
	
	mov byte [.position], cl
	mov byte [.position+1], ch
	mov byte dl, [.position]
	mov byte dh, [.position+1]
	call movecursor
	
	mov cx, 1
	call clearbackground
	
	dec dl
	inc dh
	call movecursor
	
	mov cx, 3
	call clearbackground

	dec dl
	inc dh
	call movecursor
	
	mov cx, 5
	call clearbackground
	
	inc dl
	inc dh
	call movecursor
	
	mov cx, 3
	call clearbackground

	inc dl
	inc dh
	call movecursor
	
	mov cx, 1
	call clearbackground
	
	pop ax
	
	
	ret
	
	.position	db 0,0


; variables:		cl = x position
;					ch = y position
;					dl = count (how many clouds)
;					bl = color
drawclouds:

	pusha

	mov byte [.position], cl
	mov byte [.position+1], ch
	mov byte [.count], dl

	mov ax, 0
	mov cx, 0
	mov dx, 0

	mov byte cl, [.count]

	.draw:

		push cx
		push bx

		mov ax, 1
		mov bx, 65
		call randomrange

		mov byte [.position], cl

		pop bx

		mov byte dl, [.position]
		mov byte dh, [.position+1]
		call movecursor

		mov cx, 5
		call clearbackground

		pop cx

		dec cl

		cmp cl, 0
		jne .draw
	
	popa
	ret
	
	.position		db 0,0
	.count			db 0


; variables:		cl = x position
;					ch = y position
;					dh = height, limited to 1,2,3. 3 = the tallest
;					bl = color
drawspike:

	pusha

	cmp dh, 2
	jg .done

	cmp dh, 0
	je .done

	mov byte [.position], cl
	mov byte [.position+1], ch
	mov byte [.height], dh

	mov cx, 0
	mov dx, 0

	mov byte dl, [.position]
	mov byte dh, [.position+1]
	call movecursor

	cmp byte [.height], 1
	je .drawsmall

	cmp byte [.height], 2
	je .drawtall

	jmp .done

	.drawsmall:

		inc dl
		call movecursor

		mov cx, 1
		call clearbackground

		dec dl
		inc dh
		call movecursor

		mov cx, 3
		call clearbackground

		jmp .done

	.drawtall:

		inc dl
		call movecursor

		mov cx, 1
		call clearbackground

		dec dl
		inc dh
		call movecursor

		mov cx, 3
		call clearbackground

		dec dl
		inc dh
		call movecursor

		mov cx, 5
		call clearbackground

		jmp .done

	.done:
	
		popa
	
		ret

	.position	db 0,0
	.height		db 0


; variables:		cl = x position
;					ch = y position
;					bl = color
drawdino:

	pusha

	mov byte [.position], cl
	mov byte [.position+1], ch

	mov cx, 0

	xor byte [.feetanimation], 1

	; head

 	mov byte dl, [.position]
	mov byte dh, [.position+1]
	call movecursor

	mov cx, 5
	call clearbackground

	; neck

	dec dl
	inc dh
	call movecursor

	mov cx, 6
	call clearbackground

	; tail & chin

	sub dl, 5
	inc dh
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 4
	call movecursor

	mov cx, 4
	call clearbackground

	; tail 2 and hand

	sub dl, 4
	inc dh
	call movecursor

	mov cx, 7
	call clearbackground

	add dl, 8
	call movecursor

	mov cx, 1
	call clearbackground

	; buttock

	sub dl, 6
	inc dh
	call movecursor

	mov cx, 5
	call clearbackground

	; feet & its animation

	cmp byte [.feetanimation], 0
	je .feetup

	jmp .feetdown

	.feetup:

		; left foot

		add dl, 1
		
		inc dh
		call movecursor

		mov cx, 1
		call clearbackground

		inc dh
		call movecursor

		mov cx, 1
		call clearbackground

		; right foot

		add dl, 2
		dec dh
		call movecursor

		mov cx, 1
		call clearbackground

		jmp .done

	.feetdown:

		; left foot

		add dl, 1
		
		inc dh
		call movecursor

		mov cx, 1
		call clearbackground

		; right foot

		add dl, 2
		call movecursor

		mov cx, 1
		call clearbackground

		inc dh
		call movecursor

		mov cx, 1
		call clearbackground

	.done:

		mov byte dl, [.position]
		mov byte dh, [.position+1]
	
		add dl, 2
		call movecursor
	
		push bx
		
		mov cx, 1
		mov bl, [color_blackwhite]
		call clearbackground
	
		pop bx
	
		popa
	
		ret

	.feetanimation	db 0
	.position		db 0,0









