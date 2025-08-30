bits 16			; use 16bit registers
org 100h		; the address for .com (MS-DOS) executable


section .data

	color_grnw			dw 0A0h		; green background and white text
	color_yblk			dw 0E0h		; yellow background and black text
	color_blkw			dw 00Fh		; black background and white text
	color_wy			dw 0FEh		; white background and yellow text
	color_grnblk		dw 0A0h		; green bg and black txt
	color_blkgry		dw 008h		; black bg and gray txt
	color_wblk			dw 0F0h		; white bg and black txt
	color_blw			dw 01Fh		; blue bg and white text

	screen_size			dw 2000		; screen size, 80*25 = 2000 scans

	game_name			db "NUMSEQ - Number sequence guessing game", 0
	game_name2			db "NUMSEQ", 0

	mode_easy			db "Easy", 0
	mode_medium			db "Medium", 0
	mode_hard			db "Hard", 0

	text_opt1			db "   Play    ", 0
	text_opt2			db "   Quit    ", 0

	opt_selected		db 0	; 0 - play, 1 - quit

	selector_left		db ">", 0
	selector_right		db "<", 0
	selector_help1		db "Press SPACE to select", 0
	selector_help2		db "Press ENTER to confirm selection", 0

	key_escape			db 27
	key_enter			db 13
	key_up				db 105		; key letter 'i'
	key_down			db 107		; key letter 'k'
	key_left			db 106		; key letter 'j'
	key_right			db 108		; key letter 'l'

	easy_array			db 1,2,3,4,5,6,7,8,9
	easy_array_empty	db 9 dup(0) ; used for checking

	medium_array		db 4,9,8,1,5,1,7,2,6,2,6,3,7,3,5,4
	medium_array_empty	db 16 dup(0)

	hard_array			db 1,4,1,5,9,5,2,6,8,7,3,6,3,7,4,8,7,9,4,1,6,2,2,3,5
	hard_array_empty	db 25 dup(0)

	mode				db 0 ; 0 - easy, 1 - meduim, 2 - hard

	cursor_position		dw 0 ; cursor position (in 1-dimensional)

	wrongcount			db 0

	help				db "Press the I,J,K,L keys to move/select in the grid.", 0
	help2				db "Press the NUMBER keys to input your guess.", 0
	help3				db "Press the ENTER key to confirm your guess.", 0

	cursorstartx		db 36
	cursorstarty		db 7

	message1			db "Incorrect guess. :(", 0
	message2			db "Correct guess. ;D", 0

	num					db 0	; convert the keycode AL into number
	temp				dw 0	; used to store BX value temporarily

	guesscount			db 0	; counts the number of guesses (used for the scoring)
								; each score depends on which mode you made the guess.
								; for example, easy mode has the score of 20
								; medium mode has the score of 80
								; hard mode has the score of 100
								; so adding all of it will give you score of 200

	msg1				db "Well done genius, You guessed all of them!", 0
	msg2				db "You did not guessed it all, try again.", 0
	msg2_1				db "You can do it I believe in you ;)", 0
	msg3				db "You're almost there!, keep trying ;)", 0

	scores1				db "Your score is 20", 0
	scores2				db "Your score is 80", 0
	scores3				db "Your score is 100", 0

	totalscores			db "Total score of 200", 0

	itsend				db 0	; flag to end the game

	presskey1			db "Press SPACE key to play again", 0
	presskey2			db "Press Q key to exit the game", 0


section .text

	global main

main:

	mov byte [guesscount], 0	; 
	mov byte [mode], 0			; go to easy mode
	mov byte [itsend], 0		; we're back to beningging XD
	mov byte [opt_selected], 0

	xor ax, ax					; clear some trash a bit
	xor bx, bx
	xor cx, cx
	xor dx, dx

	mov ah, 0
	mov al, 03h					; 03h for 80x25 characters screen size
	int 10h

	call enablelightcolors		; enable bright colors

	mov dl, 0
	mov dh, 0
	call movecursor

	call hidecursor

	mov bh, 0
	mov bl, [color_blkw]
	mov cx, 2000				; clear all screen
	call clearbackground

	.title:

		mov dx, 0
		call movecursor

		mov bh, 0
		mov bl, [color_yblk]
		mov cx, 80
		call clearbackground

		mov dh, 0
		mov dl, 19
		call movecursor

		mov si, game_name
		call printstring

	.gamemenu:

		mov dh, 1
		mov dl, 0
		call movecursor

		; draw background

		mov bh, 0
		mov bl, [color_blkw]
		mov cx, 1920				; clear all screen
		call clearbackground

		mov dh, 3
		mov dl, 37
		call movecursor

		mov si, game_name2
		call printstring

		; Normal Mode Button

		mov cl, 34
		mov ch, 6
		mov dl, 13
		mov dh, 3
		mov bl, [color_grnblk]
		call rectshape

		mov dl, 35
		mov dh, 7
		call movecursor

		mov si, text_opt1
		call printstring

		; Quit Mode Button

		mov cl, 34
		mov ch, 10
		mov dl, 13
		mov dh, 3
		mov bl, [color_grnblk]
		call rectshape

		mov dh, 11
		mov dl, 35
		call movecursor

		mov si, text_opt2
		call printstring

		; Show help info

		mov dh, 18
		mov dl, 19
		call movecursor

		mov si, selector_help1
		call printstring

		inc dh
		call movecursor

		mov si, selector_help2
		call printstring

		.selector:

			cmp byte [opt_selected], 0
			je .select_normal

			jmp .select_quit

			.select_normal:

				mov byte [.selector_x], 32
				mov byte [.selector_y], 7

				mov byte dl, [.selector_x]
				mov byte dh, [.selector_y]
				call movecursor

				jmp .draw_selectors

			.select_quit:

				mov byte [.selector_x], 32
				mov byte [.selector_y], 11

				mov byte dl, [.selector_x]
				mov byte dh, [.selector_y]
				call movecursor

			.draw_selectors:

				mov si, selector_left
				call printstring

				mov byte [.selector_x], 48

				mov byte dl, [.selector_x]
				call movecursor

				mov si, selector_right
				call printstring

			.selector_x		db 0
			.selector_y		db 0

			.checkforkey:

				call keypress

				cmp al, ' '
				je .selectopt

				cmp al, [key_escape]				; ESCAPE key
				je exit

				cmp al, [key_enter]
				je .checkselection

				jmp .checkforkey

			.selectopt:

				xor byte [opt_selected], 1

				jmp .gamemenu

			.checkselection:

				cmp byte [opt_selected], 0
				je playgame

				jmp exit


playgame:

	mov word [cursor_position], 0
	mov byte [num], 0
	mov byte [wrongcount], 0

	call initrandseed

	call showcursor

	mov dx, 0
	call movecursor

	mov bh, 0
	mov cx, [screen_size]
	mov bl, [color_blkw]
	call clearbackground

	mov dx, 0
	call movecursor

	mov bh, 0
	mov bl, [color_yblk]
	mov cx, 80
	call clearbackground		; draw line

	mov dh, 0
	mov dl, 19
	call movecursor

	mov si, game_name
	call printstring			; draw text

	cmp byte [itsend], 1
	je .checkguesscount

	jmp .gotomodes

	.checkguesscount:
	
		cmp byte [guesscount], 1
		je final1

		cmp byte [guesscount], 2
		je final2

		cmp byte [guesscount], 3
		je final3

	.gotomodes:

		cmp byte [mode], 0
		je easymode
	
		cmp byte [mode], 1
		je mediummode
	
		cmp byte [mode], 2
		je hardmode


; GAME MODES


easymode:

	mov word [cursor_position], 0
	mov byte [wrongcount], 0
	mov byte [num], 0

	mov dh, 2
	mov dl, 1
	call movecursor

	mov si, mode_easy
	call printstring

	mov cx, 9
	mov bx, 0

	.clearloop:

		mov byte [easy_array_empty + bx], 0		; Clear array that we're using

		inc bx

		dec cx

		cmp cx, 0
		jne .clearloop

	mov byte cl, 33
	mov byte ch, 5
	mov byte dl, 11
	mov byte dh, 9
	mov bl, [color_wy]
	call rectshape

	mov byte cl, 34
	mov byte ch, 6
	mov byte dl, 9
	mov byte dh, 7
	mov bl, [color_grnblk]
	call rectshape

	mov cx, 0
	mov bx, 0

	mov byte [cursorstartx], 36
	mov byte [cursorstarty], 7

	mov byte dl, [cursorstartx]
	mov byte dh, [cursorstarty]
	call movecursor

	.drawnumbers:

		mov word [temp], 0

		cmp cx, 3
		je .newline

		cmp cx, 6
		je .newline

		jmp .skipornah

		.newline:

			add dh, 2
			sub dl, 6
			call movecursor

		.skipornah:

			push cx

			mov word [temp], bx

			mov ax, 1
			mov bx, 2
			call randomrange

			cmp cx, 2
			je .draw

			jmp .next

		.draw:

			mov bx, [temp]

			mov ah, 0

			mov al, [easy_array + bx]		; print all numbers from the array (loads effective address)
			mov byte [easy_array_empty + bx], al

			call inttostring

			mov si, ax
			call printstring

		.next:

			pop cx

			mov bx, [temp]

			inc cx
			inc bx

			add dl, 2
			call movecursor

			cmp cx, 9
			jne .drawnumbers

	; Draw help information

	mov dl, 3
	mov dh, 18
	call movecursor

	mov si, help
	call printstring

	inc dh
	call movecursor
	mov si, help2
	call printstring

	inc dh
	call movecursor
	mov si, help3
	call printstring

	mov byte dl, [cursorstartx]
	mov byte dh, [cursorstarty]
	call movecursor

	.keywait:

		call keypress

		cmp al, [key_enter]
		je .check

		cmp al, [key_escape]
		je exit

		cmp al, [key_left]
		je .moveleft

		cmp al, [key_right]
		je .moveright

		cmp al, [key_up]
		je .moveup

		cmp al, [key_down]
		je .movedown

		cmp al, 49
		jge .checknumber

		jmp .keywait

		.checknumber:

			cmp al, 57
			jle .analyzenumber

			jmp .keywait

	.moveleft:

		cmp dl, 36
		jle .stopmove1

		dec dl
		dec dl
		call movecursor

		dec word [cursor_position]

		.stopmove1:

			jmp .keywait

	.moveright:

		cmp dl, 40
		jge .stopmove2

		inc dl
		inc dl
		call movecursor

		inc word [cursor_position]

		.stopmove2:

			jmp .keywait

	.moveup:

		cmp dh, 7
		jle .stopmove3

		dec dh
		dec dh
		call movecursor

		dec word [cursor_position]
		dec word [cursor_position]
		dec word [cursor_position]

		.stopmove3:

			jmp .keywait

	.movedown:

		cmp dh, 11
		jge .stopmove4

		inc dh
		inc dh
		call movecursor

		inc word [cursor_position]
		inc word [cursor_position]
		inc word [cursor_position]

		.stopmove4:

			jmp .keywait

	.analyzenumber:

		pusha

		mov byte [num], al
		sub byte [num], 48

		mov byte dl, [num]
		mov bx, [cursor_position]
		mov byte [easy_array_empty + bx], dl

		popa

		mov cx, 1
		mov bh, 0
		call printcharacter			; print character from AL register

		jmp .keywait

	.check:

		pusha

		mov cx, 9
		mov bx, 0

		.checkloop1:

			mov byte al, [easy_array + bx]
			mov byte dl, [easy_array_empty + bx]

			cmp dl, al
			jne .countwrong

			jmp .skip

			.countwrong:

				inc byte [wrongcount]

			.skip:

				inc bx

				dec cx

				cmp cx, 0
				jne .checkloop1

		popa

		cmp byte [wrongcount], 0
		jne incorrect

		jmp correct



mediummode:

	mov word [cursor_position], 0
	mov byte [wrongcount], 0
	mov byte [num], 0

	mov dh, 2
	mov dl, 1
	call movecursor

	mov si, mode_medium
	call printstring

	mov cx, 16
	mov bx, 0

	.clearloop:

		mov byte [medium_array_empty + bx], 0		; Clear array that we're using

		inc bx

		dec cx

		cmp cx, 0
		jne .clearloop

	mov byte cl, 31
	mov byte ch, 4
	mov byte dl, 13
	mov byte dh, 11
	mov bl, [color_wy]
	call rectshape

	mov byte cl, 32
	mov byte ch, 5
	mov byte dl, 11
	mov byte dh, 9
	mov bl, [color_grnblk]
	call rectshape

	mov cx, 0
	mov bx, 0

	mov byte [cursorstartx], 34
	mov byte [cursorstarty], 6

	mov byte dl, [cursorstartx]
	mov byte dh, [cursorstarty]
	call movecursor

	.drawnumbers:

		mov word [temp], 0

		cmp cx, 4
		je .newline

		cmp cx, 8
		je .newline

		cmp cx, 12
		je .newline

		jmp .skipornah

		.newline:

			add dh, 2
			sub dl, 8
			call movecursor

		.skipornah:

			push cx

			mov word [temp], bx

			mov ax, 1
			mov bx, 3
			call randomrange

			cmp cx, 2
			je .draw

			jmp .next

		.draw:

			mov bx, [temp]

			mov ah, 0

			mov al, [medium_array + bx]		; print all numbers from the array (loads effective address)
			mov byte [medium_array_empty + bx], al

			call inttostring

			mov si, ax
			call printstring

		.next:

			pop cx

			mov bx, [temp]

			inc cx
			inc bx

			add dl, 2
			call movecursor

			cmp cx, 16
			jne .drawnumbers

	; Draw help information

	mov dl, 3
	mov dh, 18
	call movecursor

	mov si, help
	call printstring

	inc dh
	call movecursor
	mov si, help2
	call printstring

	inc dh
	call movecursor
	mov si, help3
	call printstring

	mov byte dl, [cursorstartx]
	mov byte dh, [cursorstarty]
	call movecursor

	.keywait:

		call keypress

		cmp al, [key_enter]
		je .check

		cmp al, [key_escape]
		je exit

		cmp al, [key_left]
		je .moveleft

		cmp al, [key_right]
		je .moveright

		cmp al, [key_up]
		je .moveup

		cmp al, [key_down]
		je .movedown

		cmp al, 49
		jge .checknumber

		jmp .keywait

		.checknumber:

			cmp al, 57
			jle .analyzenumber

			jmp .keywait

	.moveleft:

		cmp byte dl, [cursorstartx]
		jle .stopmove1

		dec dl
		dec dl
		call movecursor

		dec word [cursor_position]

		.stopmove1:

			jmp .keywait

	.moveright:

		cmp dl, 40
		jge .stopmove2

		inc dl
		inc dl
		call movecursor

		inc word [cursor_position]

		.stopmove2:

			jmp .keywait

	.moveup:

		cmp byte dh, [cursorstarty]
		jle .stopmove3

		dec dh
		dec dh
		call movecursor

		dec word [cursor_position]
		dec word [cursor_position]
		dec word [cursor_position]
		dec word [cursor_position]

		.stopmove3:

			jmp .keywait

	.movedown:

		cmp dh, 12
		jge .stopmove4

		inc dh
		inc dh
		call movecursor

		inc word [cursor_position]
		inc word [cursor_position]
		inc word [cursor_position]
		inc word [cursor_position]

		.stopmove4:

			jmp .keywait

	.analyzenumber:

		pusha

		mov byte [num], al
		sub byte [num], 48

		mov byte dl, [num]
		mov bx, [cursor_position]
		mov byte [medium_array_empty + bx], dl

		popa

		mov cx, 1
		mov bh, 0
		call printcharacter			; print character from AL register

		jmp .keywait


	.check:

		pusha

		mov cx, 16
		mov bx, 0

		.checkloop1:

			mov byte al, [medium_array + bx]
			mov byte dl, [medium_array_empty + bx]

			cmp dl, al
			jne .countwrong

			jmp .skip

			.countwrong:

				inc byte [wrongcount]

			.skip:

				inc bx

				dec cx

				cmp cx, 0
				jne .checkloop1

		popa

		cmp byte [wrongcount], 0
		jne incorrect

		jmp correct


hardmode:

	mov word [cursor_position], 0
	mov byte [wrongcount], 0
	mov byte [num], 0

	mov dh, 2
	mov dl, 1
	call movecursor

	mov si, mode_hard
	call printstring

	mov cx, 25
	mov bx, 0

	.clearloop:

		mov byte [hard_array_empty + bx], 0		; Clear array that we're using

		inc bx

		dec cx

		cmp cx, 0
		jne .clearloop

	mov byte cl, 31
	mov byte ch, 3
	mov byte dl, 15
	mov byte dh, 13
	mov bl, [color_wy]
	call rectshape

	mov byte cl, 32
	mov byte ch, 4
	mov byte dl, 13
	mov byte dh, 11
	mov bl, [color_grnblk]
	call rectshape

	mov cx, 0
	mov bx, 0

	mov byte [cursorstartx], 34
	mov byte [cursorstarty], 5

	mov byte dl, [cursorstartx]
	mov byte dh, [cursorstarty]
	call movecursor

	.drawnumbers:

		mov word [temp], 0

		cmp cx, 5
		je .newline

		cmp cx, 10
		je .newline

		cmp cx, 15
		je .newline

		cmp cx, 20
		je .newline

		jmp .skipornah

		.newline:

			add dh, 2
			sub dl, 10
			call movecursor

		.skipornah:

			push cx

			mov word [temp], bx

			mov ax, 1
			mov bx, 5
			call randomrange

			cmp cx, 3
			je .draw

			jmp .next

		.draw:

			mov bx, [temp]

			mov ah, 0

			mov al, [hard_array + bx]		; print all numbers from the array (loads effective address)
			mov byte [hard_array_empty + bx], al

			call inttostring

			mov si, ax
			call printstring

		.next:

			pop cx

			mov bx, [temp]

			inc cx
			inc bx

			add dl, 2
			call movecursor

			cmp cx, 25
			jne .drawnumbers

	; Draw help information

	mov dl, 3
	mov dh, 18
	call movecursor

	mov si, help
	call printstring

	inc dh
	call movecursor
	mov si, help2
	call printstring

	inc dh
	call movecursor
	mov si, help3
	call printstring

	mov byte dl, [cursorstartx]
	mov byte dh, [cursorstarty]
	call movecursor

	.keywait:

		call keypress

		cmp al, [key_enter]
		je .check

		cmp al, [key_escape]
		je exit

		cmp al, [key_left]
		je .moveleft

		cmp al, [key_right]
		je .moveright

		cmp al, [key_up]
		je .moveup

		cmp al, [key_down]
		je .movedown

		cmp al, 49
		jge .checknumber

		jmp .keywait

		.checknumber:

			cmp al, 57
			jle .analyzenumber

			jmp .keywait

	.moveleft:

		cmp byte dl, [cursorstartx]
		jle .stopmove1

		dec dl
		dec dl
		call movecursor

		dec word [cursor_position]

		.stopmove1:

			jmp .keywait

	.moveright:

		cmp dl, 42
		jge .stopmove2

		inc dl
		inc dl
		call movecursor

		inc word [cursor_position]

		.stopmove2:

			jmp .keywait

	.moveup:

		cmp byte dh, [cursorstarty]
		jle .stopmove3

		dec dh
		dec dh
		call movecursor

		dec word [cursor_position]
		dec word [cursor_position]
		dec word [cursor_position]
		dec word [cursor_position]
		dec word [cursor_position]

		.stopmove3:

			jmp .keywait

	.movedown:

		cmp dh, 12
		jge .stopmove4

		inc dh
		inc dh
		call movecursor

		inc word [cursor_position]
		inc word [cursor_position]
		inc word [cursor_position]
		inc word [cursor_position]
		inc word [cursor_position]

		.stopmove4:

			jmp .keywait

	.analyzenumber:

		pusha

		mov byte [num], al
		sub byte [num], 48

		mov byte dl, [num]
		mov bx, [cursor_position]
		mov byte [hard_array_empty + bx], dl

		popa

		mov cx, 1
		mov bh, 0
		call printcharacter			; print character from AL register

		jmp .keywait


	.check:

		pusha

		mov cx, 25
		mov bx, 0

		.checkloop1:

			mov byte al, [hard_array + bx]
			mov byte dl, [hard_array_empty + bx]

			cmp dl, al
			jne .countwrong

			jmp .skip

			.countwrong:

				inc byte [wrongcount]

			.skip:

				inc bx

				dec cx

				cmp cx, 0
				jne .checkloop1

		popa

		mov byte [itsend], 1

		cmp byte [wrongcount], 0
		jne incorrect

		jmp correct



incorrect:

	mov dx, 0
	call movecursor

	mov bh, 0
	mov bl, [color_blkw]
	mov word cx, [screen_size]
	call clearbackground

	mov dh, 12
	mov dl, 31
	call movecursor

	mov si, message1
	call printstring

	mov cx, 5
	call delay

	mov cx, 5
	call delay

	mov cx, 5
	call delay

	mov cx, 5
	call delay

	mov cx, 5
	call delay

	cmp byte [mode], 2
	jl .countlevel

	.countlevel:

		inc byte [mode]	; increase mode each correct guesses
		; inc byte [guesscount] ; we do not count as the player didn't guess it

	jmp playgame



correct:

	mov dx, 0
	call movecursor

	mov bh, 0
	mov bl, [color_blw]
	mov word cx, [screen_size]
	call clearbackground

	mov dh, 12
	mov dl, 31
	call movecursor

	mov si, message2
	call printstring

	mov cx, 5
	call delay

	mov cx, 5
	call delay

	mov cx, 5
	call delay

	mov cx, 5
	call delay

	mov cx, 5
	call delay

	cmp byte [mode], 2
	jl .countlevel

	.countlevel:

		inc byte [mode]	; increase mode each correct guesses
		inc byte [guesscount] ; also increase guess count

	jmp playgame


final1:

	mov dx, 0
	call movecursor

	mov bh, 0
	mov bl, [color_blw]
	mov cx, [screen_size]
	call clearbackground

	mov dh, 4
	mov dl, 35
	call movecursor

	mov si, .gameovertext
	call printstring

	mov dh, 7
	mov dl, 32
	call movecursor

	mov si, scores1
	call printstring

	mov dh, 12
	
	mov dl, 21
	call movecursor

	mov si, msg2
	call printstring

	inc dh
	mov dl, 24
	call movecursor

	mov si, msg2_1
	call printstring

	add dh, 8
	mov dl, 26
	call movecursor

	mov si, presskey1
	call printstring

	inc dh
	mov dl, 26
	call movecursor

	mov si, presskey2
	call printstring

	.keywait:

		call keypress

		cmp al, ' '
		je main

		cmp al, 'q'
		je exit

		jmp .keywait

	.gameovertext	db "GAME OVER", 0



final2:

	mov dx, 0
	call movecursor

	mov bh, 0
	mov bl, [color_blw]
	mov word cx, [screen_size]
	call clearbackground

	mov dh, 4
	mov dl, 35
	call movecursor

	mov si, .gameovertext
	call printstring

	mov dh, 7
	mov dl, 32
	call movecursor

	mov si, scores2
	call printstring

	mov dh, 12
	
	mov dl, 21
	call movecursor

	mov si, msg3
	call printstring

	add dh, 8
	mov dl, 26
	call movecursor

	mov si, presskey1
	call printstring

	inc dh
	mov dl, 26
	call movecursor

	mov si, presskey2
	call printstring

	.keywait:

		call keypress

		cmp al, ' '
		je main

		cmp al, 'q'
		je exit

		jmp .keywait

	.gameovertext	db "GAME OVER", 0



final3:

	mov dx, 0
	call movecursor

	mov bh, 0
	mov bl, [color_blw]
	mov word cx, [screen_size]
	call clearbackground

	mov dh, 4
	mov dl, 35
	call movecursor

	mov si, .gameovertext
	call printstring

	mov dh, 7
	mov dl, 32
	call movecursor

	mov si, scores3
	call printstring

	inc dh
	mov dl, 31
	call movecursor

	mov si, totalscores
	call printstring

	mov dh, 12
	
	mov dl, 21
	call movecursor

	mov si, msg1
	call printstring

	add dh, 8
	mov dl, 26
	call movecursor

	mov si, presskey1
	call printstring

	inc dh
	mov dl, 26
	call movecursor

	mov si, presskey2
	call printstring

	.keywait:

		call keypress

		cmp al, ' '
		je main

		cmp al, 'q'
		je exit

		jmp .keywait

	.gameovertext	db "GAME OVER", 0




exit:

	call showcursor

	mov dx, 0
	call movecursor

	mov bh, 0
	mov bl, 007h
	mov cx, [screen_size]				; clear all screen
	call clearbackground

	mov dx, 0
	call movecursor

	int 20h








; input:		cx = delay in milliseconds
delay:

	push ax
	mov ah, 86h
	int 15h
	pop ax
	ret


; input:		cx = how many times the character will be drawn
;				bl = color of the character
;				bh = page number
clearbackground:

	mov al, ' '
	mov bh, 0
	mov ah, 09h
	int 10h
	ret			; return

; input:		si = string to print
printstring:

	pusha
	mov ah, 0Eh
	.repeat:
		lodsb
		int 10h
		cmp al, 0
		jne .repeat
	popa
	ret

; input:		dh = cursor y position
;				dl = cursor x position
movecursor:

	pusha
	mov bh, 0
	mov ah, 2
	int 10h
	popa
	ret

; input:		None
enablelightcolors:

	pusha
	mov ax, 1003h
	mov bx, 0
	int 10h
	popa
	ret

; output:		al = key that is pressed
keypress:

	mov ah, 00h
	int 16h
	ret

; input:		al = character to display
;				bh = page number
;				cx = number of times
printcharacter:

	pusha
	mov ah, 0Ah
	int 10h
	popa
	ret

; input:		ax = number to be converted
; output:		ax = string number
inttostring:

	pusha
	mov cx, 0
	mov bx, 10				; Set BX 10, for division and mod
	mov di, .t				; Get our pointer ready
	.pushh:
		mov dx, 0
		div bx				; Remainder in DX, quotient in AX
		inc cx				; Increase pop loop counter
		push dx				; Push remainder, so as to reverse order when popping
		test ax, ax			; Is quotient zero?
		jnz .pushh			; If not, loop again
	.popp:
		pop dx				; Pop off values in reverse order, and add 48 to make them digits
		add dl, '0'			; And save them in the string, increasing the pointer each time
		mov [di], dl
		inc di
		dec cx
		jnz .popp
	mov byte [di], 0		; Zero-terminate string
	popa
	mov ax, .t				; Return location of string
	ret
	.t times 7 db 0

; input:		None
initrandseed:

	push bx
	push ax
	mov bx, 0
	mov al, 0x02				; Minute
	out 0x70, al
	in al, 0x71
	mov bl, al
	shl bx, 8
	mov al, 0					; Second
	out 0x70, al
	in al, 0x71
	mov bl, al
	mov word [rseed], bx		; Seed will be something like 0x4435 (if it were 44 minutes and 35 seconds after the hour)
	pop ax
	pop bx
	ret
	rseed	dw 0

; input			ax = low int
;				bx = high int
;				cx = random number
randomrange:

	push dx
	push bx
	push ax
	sub bx, ax				; We want a number between 0 and (high-low)
	call .genrandom
	mov dx, bx
	add dx, 1
	mul dx
	mov cx, dx
	pop ax
	pop bx
	pop dx
	add cx, ax				; Add the low offset back
	ret
	.genrandom:
		push dx
		mov ax, [rseed]
		mov dx, 23167
		mul dx				; DX:AX = AX * DX
		add ax, 12409
		adc dx, 0
		mov [rseed], ax
	 	pop dx
		ret


; input:		cl = x position
;				ch = y position
;				dl = width of the shape
;				dh = height of the shape
;				bl = color
rectshape:

	pusha

	mov byte [.width], dl
	mov byte [.height], dh
	mov byte [.xpos], cl
	mov byte [.ypos], ch
	mov [.color], bl
	xor cx, cx
	xor bx, bx
	xor dx, dx
	mov byte dh, [.ypos]
	mov byte dl, [.xpos]
	call movecursor
	mov byte cl, [.height]
	.shape_height:
		.shape_width:
			push cx
			mov bh, 0
			mov bl, [.color]
			mov cx, [.width]
			call clearbackground
			pop cx
		inc dh
		mov byte dl, [.xpos]
		call movecursor
		dec cl
		cmp cl, 0
		jne .shape_height

	popa

	ret

	.width		dw 0
	.height		dw 0
	.xpos		db 0
	.ypos		db 0
	.color		dw 0

; input:		si = string to print
;				bl = color
;				dh = cursor y position
;				dl = cursor x position
;				cx = length of the chars
printcolstring:

	pusha

	mov bh, 0

	call movecursor
	call clearbackground
	call printstring

	popa
	ret

showcursor:

	pusha
	mov ch, 6
	mov cl, 7
	mov ah, 1
	int 10h
	popa
	ret

hidecursor:

	pusha
	mov ch, 32
	mov ah, 1
	int 10h
	popa
	ret








