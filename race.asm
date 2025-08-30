

; ---------------------------------------------------------------------------
;
; Racing car game made purely in Assembly language.
;
; Developer/s:   		Catucod, Renato Jr.		- Programmer / Sound design
; 						Piagola, Loraine Mae	- Car & Terrain design
;						Pangan, Jeffrey	  		- Game Mechanics
;						Abaja, Adrian			- Game Menu/Prompts
;
; Date Created (Started): 	09-07-24
; Date Finished (Ended):	10-06-24
; 
; As an intended project for CpE-Special Course
;
; ---------------------------------------------------------------------------


bits 16				; we only use 16-bit register
org 100h			; address for MS-DOS executable

global main			; target execution procedure

jmp main

section .data		; data section

	presskey 				db "> Press SPACE to get help <", 0
	presstoplay				db ">    Press P to start     <", 0
	version 				db "Version 1.0", 0
	scoretext 				db "Score: ", 0
	goodmessage				db "YOU WIN!", 0
	badmessage				db "YOU CRASHED!", 0
	spacekey				db "Press SPACE to play again", 0
	esckey					db "Press ESC to exit the game", 0
	leveluptext				db "LEVEL UP!", 0

	screensize				dw 2000		; 2000 for 80x25 size
	scorevalue				dw 0
	direction				db 0		; 0 - stop, 1 - left, 2 - right
	updatescore				db 0
	updateland				db 0
	movefast				db 0		; sets 1 if the user speed up the car
	firststart				db 0		; flag that the game is freshly starts
	track_animate			db 1
	obstacle_spawn			db 0
	obstacle_yposition		db 0		; obstacle y position (relative to its y origin)
	obstacle_cooldown		db 50		; cool down to when the next obstacle to spawn
	player_positionx		db 0
	player_positiony		db 0
	player_levelup			db 0		; flag for leveling up
	color_black				dw 0Fh
	color_purple			dw 9Fh

section .text		; a section for code

main:

	xor ax, ax
	mov es, ax

	; text mode 80x25 screen size 16 colors 8 pages, 15 colors
	mov ah, 00h
	mov al, 03h
	int 10h

	; blue background on white foreground colors
	mov al, ' '
	mov bl, 1Fh
	mov bh, 0
	mov word cx, [screensize]
	call clearbg

	mov al, 0
	call selectpage

	; enables intensive colors (bright colors)
	mov ax, 1003h
	mov bx, 0
	int 10h
	
	; hide cursor
	call hidecursor

	; ---------------- GAME TITLE -----------------

	pusha ; push all registers to stack

	mov bl, 0F1h	; bright white
	mov bh, 0		; current page
	mov al, ' '		; draw spaces

	.top1:

		mov cx, 3
		call delay
	
		mov dh, 5		; y position cursor
		
		mov dl, 19		; x position cursor
		call movecursor
		mov cx, 7
		call clearbg

		mov dl, 31
		call movecursor
		mov cx, 7
		call clearbg

		mov dl, 43
		call movecursor
		mov cx, 7
		call clearbg

		mov dl, 53
		call movecursor
		mov cx, 7
		call clearbg

	.top2:

		mov dh, 6

		.loopv:

			mov cx, 3
			call delay

			cmp dh, 7
			jg .middle

			mov dl, 19

			.looph:
	
				cmp dl, 19
				je .drawlineh

				cmp dl, 26
				je .drawlineh
	
				cmp dl, 30
				je .drawlineh
	
				cmp dl, 38
				je .drawlineh

				cmp dl, 42
				je .drawlineh

				cmp dl, 53
				je .drawlineh

				cmp dl, 53
				jg .nextline
				
				jmp .skiph
	
				.drawlineh:
		
					call movecursor
					mov cx, 1
					call clearbg
	
				.skiph:
		
					inc dl
					
					call movecursor
					
					jmp .looph

			.nextline:

				inc dh

				call movecursor

				jmp .loopv

	.middle:

		mov cx, 3
		call delay
	
		mov dh, 8
		
		mov dl, 19
		call movecursor
		mov cx, 7
		call clearbg

		mov dl, 30
		call movecursor
		mov cx, 9
		call clearbg

		mov dl, 42
		call movecursor
		mov cx, 1
		call clearbg

		mov dl, 53
		call movecursor
		mov cx, 7
		call clearbg

	.bottom1:

		mov dh, 9

		.loopv2:

			mov cx, 3
			call delay

			cmp dh, 10
			jg .bottom2

			mov dl, 19

			.looph2:
	
				cmp dl, 19
				je .drawlineh2

				cmp dl, 26
				je .drawlineh2
	
				cmp dl, 30
				je .drawlineh2
	
				cmp dl, 38
				je .drawlineh2

				cmp dl, 42
				je .drawlineh2

				cmp dl, 53
				je .drawlineh2

				cmp dl, 53
				jg .nextline2
				
				jmp .skiph2
	
				.drawlineh2:
		
					call movecursor
					mov cx, 1
					call clearbg
	
				.skiph2:
		
					inc dl
					
					call movecursor
					
					jmp .looph2

			.nextline2:

				inc dh

				call movecursor

				jmp .loopv2

	.bottom2:

		mov cx, 3
		call delay
	
		mov dh, 11

		mov dl, 19
		
		.looph3:

			cmp dl, 19
			je .drawlineh3

			cmp dl, 26
			je .drawlineh3
	
			cmp dl, 30
			je .drawlineh3
			
			cmp dl, 38
			je .drawlineh3

			cmp dl, 38
			jg .drawnormal

			jmp .skiph3

			.drawlineh3:

				call movecursor

				mov cx, 1
				call clearbg

			.skiph3:

				inc dl

				call movecursor

				jmp .looph3

		.drawnormal:

			mov dl, 43
			call movecursor
			mov cx, 7
			call clearbg

			mov dl, 53
			call movecursor
			mov cx, 7
			call clearbg

	popa

	mov cx, 1
	call delay
	
	; version text
	mov dh, 14
	mov dl, 33
	call movecursor
	mov si, version
	call printstr
		
	; key press text
	mov dh, 17
	mov dl, 25
	call movecursor
	mov si, presskey
	call printstr
	inc dh
	call movecursor
	mov si, presstoplay
	call printstr

;	.playmusic:
;
;		pusha
;		call checkkey
;		cmp al, 0
;		jne .waitkeypress
;		popa
;
;		; call music
;
;		jmp .playmusic
	
	.waitkeypress:

		call keypress

		cmp al, 'p'
		je gamestart

		cmp al, ' '
		je help

		jmp .waitkeypress

	; clear registers values
	mov ax, 0
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov di, 0
	mov si, 0

gamestart:

	; set neccessary game variables
	mov byte [firststart], 1
	mov byte [scorevalue], 0
	mov byte [obstacle_spawn], 0
	mov byte [obstacle_yposition], 0
	mov byte [obstacle_cooldown], 50
	mov byte [movefast], 0
	mov byte [updateland], 0
	mov byte [updatescore], 0
	mov byte [track_animate], 1				; enable road track animation

	.startpoint:

		mov dx, 0		; go top-left
		call movecursor
	
		; background
		mov al, ' '
		mov bl, 3Fh
		mov bh, 0
		mov cx, [screensize]	; 80 x 25 screen size total of 2000 scans
		call clearbg

	.scoring:

		mov cx, 1			; to prevent faster command execution (stable game refresh)
		call delay

		call randseed		; setup random seed for randomize obstacle spawn

		cmp byte [updatescore], 1
		je .updatescoring

		push dx

		mov dx, 0
		call movecursor

		mov bl, 6Fh
		mov cx, 80
		call clearbg

		mov si, scoretext
		call printstr

		mov ax, [scorevalue]
		call inttostr			; convert integer (word) into string
		mov si, ax
		call printstr

		pop dx

		jmp .clouds

		.updatescoring:

			xor byte [.delayinc], 1

			cmp byte [.delayinc], 1
			jne .doneupdate

			.incscore1:

				xor byte [.delayinc2], 1

				cmp byte [.delayinc2], 1
				jne .doneupdate

				.incscore2:

					inc word [scorevalue]

					cmp word [scorevalue], 100
					je levelup
					
					cmp word [scorevalue], 200
					jge youwin

			.doneupdate:

				mov byte [updatescore], 0

				jmp .scoring

		.delayinc	db 0
		.delayinc2	db 0

	.clouds:

		mov byte [.repeatcloudh], 3
		mov byte [.repeatcloudv], 3

		push dx

		mov dh, 1
		mov dl, 0
		call movecursor

		mov al, ' '
		mov bh, 0
		mov bl, 3Fh
		mov word cx, [screensize]
		call clearbg

		mov dh, 2
		mov dl, 5
		mov al, ' '			; draw spaces
		mov bh, 0

		jmp .cloudlooph		; first cloud layer

		.cloudloopv:

			dec byte [.repeatcloudv]

			cmp dl, 65
			jge .rcp1

			jmp .rcv

			.rcp1:

				cmp byte [.repeatcloudv], 1
				je .rcp2

				mov dl, 17		; reset position

				jmp .rcv

			.rcp2:

				cmp byte [.repeatcloudv], 0
				je .rcp3

				mov dl, 5

				jmp .rcv

			.rcp3:

				mov dl, 17

			.rcv:

				mov byte [.repeatcloudh], 3

			.cloudlooph:

				dec byte [.repeatcloudh]

				call movecursor
				mov bl, 0F0h
				mov cx, 10
				call clearbg

				mov cx, 25
				.cloudcount:
					inc dl
					loop .cloudcount

				cmp byte [.repeatcloudh], 0
				jg .cloudlooph

				inc dh
				inc dh

			cmp byte [.repeatcloudv], 0
			jg .cloudloopv

		pop dx

		.repeatcloudh	db 3
		.repeatcloudv	db 3

	.land:

		push dx

		mov dh, 15
		mov dl, 0
		call movecursor

		mov al, ' '
		mov bh, 0
		mov bl, 0AFh
		mov cx, 1200
		call clearbg

		.road:

			mov dh, 15
			mov dl, 28
			call movecursor

			mov al, ' '
			mov bl, 80h
			mov cx, 22
			call clearbg

			inc dh
			mov dl, 27
			call movecursor

			mov al, ' '
			mov bl, 80h
			mov cx, 24
			call clearbg

			inc dh
			mov dl, 26
			call movecursor

			mov al, ' '
			mov bl, 80h
			mov cx, 26
			call clearbg

			inc dh
			mov dl, 25
			call movecursor

			mov al, ' '
			mov bl, 80h
			mov cx, 28
			call clearbg

			inc dh
			mov dl, 24
			call movecursor

			mov al, ' '
			mov bl, 80h
			mov cx, 30
			call clearbg

			inc dh
			mov dl, 23
			call movecursor

			mov al, ' '
			mov bl, 80h
			mov cx, 32
			call clearbg

			inc dh
			mov dl, 22
			call movecursor

			mov al, ' '
			mov bl, 80h
			mov cx, 34
			call clearbg

			inc dh
			mov dl, 21
			call movecursor

			mov al, ' '
			mov bl, 80h
			mov cx, 36
			call clearbg

			inc dh
			mov dl, 20
			call movecursor

			mov al, ' '
			mov bl, 80h
			mov cx, 38
			call clearbg

			inc dh
			mov dl, 19
			call movecursor

			mov al, ' '
			mov bl, 80h
			mov cx, 40
			call clearbg

			.track:

				mov dh, 15
				mov dl, 39
				call movecursor

				cmp byte [track_animate], 1
				je .drawtrack1

				jmp .drawtrack2

				.drawtrack1:

					mov cx, 2
					.trackloop1:
						push cx
						inc dh
						call movecursor
						mov bl, 0E0h
						mov cx, 1
						call clearbg
						pop cx
						loop .trackloop1

					inc dh
					inc dh
					call movecursor

					mov cx, 2
					.trackloop2:
						push cx
						inc dh
						call movecursor
						mov bl, 0E0h
						mov cx, 1
						call clearbg
						pop cx
						loop .trackloop2

					inc dh
					inc dh
					call movecursor

					mov cx, 2
					.trackloop3:
						push cx
						inc dh
						call movecursor
						mov bl, 0E0h
						mov cx, 1
						call clearbg
						pop cx
						loop .trackloop3

					jmp .drawskip

				.drawtrack2:

					inc dh
					inc dh
					call movecursor

					mov cx, 2
					.trackloop4:
						push cx
						inc dh
						call movecursor
						mov bl, 0E0h
						mov cx, 1
						call clearbg
						pop cx
						loop .trackloop1

					inc dh
					inc dh
					call movecursor

					mov cx, 2
					.trackloop5:
						push cx
						inc dh
						call movecursor
						mov bl, 0E0h
						mov cx, 1
						call clearbg
						pop cx
						loop .trackloop2

					inc dh
					inc dh
					call movecursor

					mov cx, 2
					.trackloop6:
						push cx
						inc dh
						call movecursor
						mov bl, 0E0h
						mov cx, 1
						call clearbg
						pop cx
						loop .trackloop3

				.drawskip:

					pop dx

		cmp byte [updateland], 1
		je .drawplayer

	.player:

		cmp byte [firststart], 1
		je .setpos

		jmp .updateplayer

		.setpos:

			mov dh, 21
			mov dl, 37

		.updateplayer:

			cmp byte [direction], 1
			je .turnleft

			cmp byte [direction], 2
			je .turnright

			cmp byte [movefast], 1
			je .forward

			cmp byte [movefast], 2
			je .backward

			jmp .confirmdraw

			.turnleft:

				cmp dl, 27
				jle .confirmdraw

				dec dl

				mov byte [direction], 0
				mov byte [updateland], 1

				jmp .confirmdraw

			.turnright:

				cmp dl, 48
				jge .confirmdraw

				inc dl

				mov byte [direction], 0
				mov byte [updateland], 1

				jmp .confirmdraw

			.forward:

				cmp dh, 20
				jle .confirmdraw

				dec dh

				mov byte [movefast], 0
				mov byte [updateland], 1

				jmp .confirmdraw

			.backward:

				cmp dh, 21
				jge .confirmdraw

				inc dh

				mov byte [movefast], 0
				mov byte [updateland], 1

			.confirmdraw:

				cmp byte [updateland], 1
				je .land

				.drawplayer:

					mov byte [updateland], 0

					mov byte [player_positiony], dh		; save current position of the player
					mov byte [player_positionx], dl

					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					; 
					; 				OBJECT COLLIDER
					; 
					; This is where the magic happens.
					; This sub procedure checks if the player
					; collides with the obstacles.
					;
					;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

					.collider:

						cmp byte [obstacle_spawn], 0	; colliding with right obstacle?
						je .collideob1					; if so, jump to .collideob1 label

						jmp .collideob2					; or else jump to .collideob2 label

						.collideob1:

							; check y position of ob1 and compare it
							; with the x & y position of the player

							cmp byte [obstacle_yposition], 10
							jge .donothing

							cmp byte [obstacle_yposition], 5
							jge .checkxplayerpos1

							jmp .donothing		; otherwise skip

							.checkxplayerpos1:

								cmp byte [player_positionx], 51
								jge .donothing

								cmp byte [player_positionx], 38
								jge gameover

								jmp .donothing	; otherwise skip

						.collideob2:

							; check y position of ob2 and compare it
							; with the x & y position of the player

							cmp byte [obstacle_yposition], 10
							jge .donothing

							cmp byte [obstacle_yposition], 5
							jge .checkxplayerpos2

							jmp .donothing

							.checkxplayerpos2:

								cmp byte [player_positionx], 25
								jle .donothing

								cmp byte [player_positionx], 36
								jle gameover

						.donothing:

							nop		; do nothing :D

					call movecursor

					mov al, ' '
					mov bh, 0
					
					mov bl, [color_black]
					mov cx, 1					; TIRE 1
					call clearbg

					push dx
					inc dl
					call movecursor
					pop dx

					mov bl, [color_purple]
					mov cx, 2					; BODY 1
					call clearbg

					push dx
					inc dl
					inc dl
					inc dl
					call movecursor
					pop dx

					mov bl, [color_black]
					mov cx, 1					; TIRE 2
					call clearbg

					push dx
					inc dh
					dec dl
					call movecursor
					pop dx

					mov bl, [color_purple]
					mov cx, 6					; BODY 2
					call clearbg

					push dx
					dec dl
					dec dl
					inc dh
					inc dh
					call movecursor
					pop dx

					mov bl, [color_black]		; TIRE 3
					mov cx, 1
					call clearbg

					push dx
					dec dl
					inc dh
					inc dh
					call movecursor
					pop dx

					mov bl, [color_purple]		; BODY 4
					mov cx, 6
					call clearbg

					push dx
					inc dl
					inc dl
					inc dl
					inc dl
					inc dl
					inc dh
					inc dh
					call movecursor
					pop dx

					mov bl, [color_black]		; TIRE 4
					mov cx, 1
					call clearbg

	.obstacle: 

		pusha
		call checkkey
		cmp al, 0
		jne .waitforkey
		popa

		pusha

		mov al, ' '
		mov bl, 0CFh
		mov bh, 0
		mov dh, 13

		cmp byte [player_levelup], 0
		je .delayobsspeed

		jmp .normalspeed

		.delayobsspeed:
		
			xor byte [.delaymove], 1		; do flip-flop thingy

			jmp .contcompare

		.normalspeed:

			mov byte [.delaymove], 1

		.contcompare:
	
			cmp byte [obstacle_cooldown], 0
			jg .deccooldown
	
			cmp byte [obstacle_yposition], 20
			jl .incypos
	
			cmp byte [obstacle_yposition], 20
			jg .resetypos

		.incypos:

			cmp byte [.delaymove], 0
			jne .movenow

			jmp .checkspawn

			.movenow:

				inc byte [obstacle_yposition]

			jmp .checkspawn

		.resetypos:

			mov byte [obstacle_yposition], 0

			pusha
			mov ax, 0
			mov bx, 1
			call randrange
			mov byte [obstacle_spawn], cl
			popa

			jmp .checkspawn

		.deccooldown:

			dec byte [obstacle_cooldown]

			jmp .done

		.checkspawn:

			cmp byte [obstacle_spawn], 0
			je .ob1

			jmp .ob2

		.drawobstacle:

			cmp byte [obstacle_spawn], 0
			je .ob1

			jmp .ob2

			.ob1:

				mov dl, 43
				add byte dh, [obstacle_yposition]
				call movecursor

				.ob1layer1:

					; TIRE 1
					add dl, 1
					call movecursor
					mov bl, 00h
					mov cx, 1
					call clearbg
	
					; BODY 1
					add dl, 1
					call movecursor
					mov bl, 0CFh
					mov cx, 2
					call clearbg
	
					; TIRE 2
					add dl, 2
					call movecursor
					mov bl, 00h
					mov cx, 1
					call clearbg

				.ob1layer2:

					; BODY 2
					sub dl, 4
					add dh, 1
					call movecursor
					mov bl, 0CFh
					mov cx, 6
					call clearbg

				.ob1layer3:

					; TIRE 3
					sub dl, 1
					add dh, 1
					call movecursor
					mov bl, 00h
					mov cx, 1
					call clearbg

					; BODY 3
					add dl, 1
					call movecursor
					mov bl, 0CFh
					mov cx, 6
					call clearbg

					; TIRE 4
					add dl, 6
					call movecursor
					mov bl, 00h
					mov cx, 1
					call clearbg

				jmp .done

			.ob2:

				mov dl, 30
				add byte dh, [obstacle_yposition]
				call movecursor

				.ob2layer1:

					; TIRE 1
					add dl, 1
					call movecursor
					mov bl, 00h
					mov cx, 1
					call clearbg
	
					; BODY 1
					add dl, 1
					call movecursor
					mov bl, 0CFh
					mov cx, 2
					call clearbg
	
					; TIRE 2
					add dl, 2
					call movecursor
					mov bl, 00h
					mov cx, 1
					call clearbg

				.ob2layer2:

					; BODY 2
					sub dl, 4
					add dh, 1
					call movecursor
					mov bl, 0CFh
					mov cx, 6
					call clearbg

				.ob2layer3:

					; TIRE 3
					sub dl, 1
					add dh, 1
					call movecursor
					mov bl, 00h
					mov cx, 1
					call clearbg

					; BODY 3
					add dl, 1
					call movecursor
					mov bl, 0CFh
					mov cx, 6
					call clearbg

					; TIRE 4
					add dl, 6
					call movecursor
					mov bl, 00h
					mov cx, 1
					call clearbg

			.done:

				popa

			mov byte [updatescore], 1		; always update score
			mov byte [firststart], 0		; set to false because the game already starts
			xor byte [track_animate], 1		; animate road track (switch on & off)

			jmp .scoring

		.delaymove	db 0

	.waitforkey:

		mov byte [firststart], 0

		call keypress

		cmp al, 27				; ESCAPE KEY
		je exit

		cmp al, 'a'
		je .leftturn

		cmp al, 'd'
		je .rightturn

		cmp al, 'w'				; 
		je .movefaster

		cmp al, 's'				; 
		je .moveslower

		cmp al, ' '				; honk PEEP-PEEP!!!
		je .peep

		jmp .obstacle

		.leftturn:

			mov byte [direction], 1

			jmp .updateplayer

		.rightturn:

			mov byte [direction], 2

			jmp .updateplayer

		.movefaster:

			mov byte [movefast], 1

			jmp .updateplayer

		.moveslower:

			mov byte [movefast], 2

			jmp .updateplayer

		.peep:

			pusha
			mov ax, 550
			mov cx, 1
			call playsound
			popa

			jmp .obstacle

youwin:

	mov dx, 0
	call movecursor

	mov al, ' '
	mov bl, 1Fh
	mov bh, 0

	mov cx, 25
	.bgloop:
		push cx
		mov cx, 3
		call delay
		mov cx, 80
		call clearbg
		pop cx
		inc dh
		call movecursor
		loop .bgloop

	mov cx, 1
	call delay

	mov dh, 8
	mov dl, 35
	call movecursor
	mov si, goodmessage
	call printstr

	add dh, 2
	mov dl, 34
	call movecursor

	pusha
	
	mov si, scoretext
	call printstr
	mov word bx, [scorevalue]
	mov ax, bx
	call inttostr			; converts integer to string
	mov si, ax
	call printstr

	popa

	add dh, 5
	mov dl, 27
	call movecursor
	mov si, spacekey
	call printstr

	inc dh
	mov dl, 27
	call movecursor
	mov si, esckey
	call printstr

	.waitkey:

		call keypress

		cmp al, ' '
		je gamestart

		cmp al, 27
		je exit

		jmp .waitkey

gameover:

	mov dx, 0
	call movecursor

	mov al, ' '
	mov bl, 0Ch
	mov bh, 0
	mov cx, 2000
	call clearbg

	mov dh, 8
	mov dl, 34
	call movecursor
	mov si, badmessage
	call printstr

	add dh, 2
	mov dl, 35
	call movecursor

	pusha
	
	mov si, scoretext
	call printstr
	mov word bx, [scorevalue]
	mov ax, bx
	call inttostr
	mov si, ax
	call printstr
	
	popa

	add dh, 4
	mov dl, 27
	call movecursor
	mov si, spacekey
	call printstr

	inc dh
	mov dl, 27
	call movecursor
	mov si, esckey
	call printstr

	.waitkey:

		call keypress

		cmp al, ' '
		je gamestart

		cmp al, 27
		je exit

		jmp .waitkey

help:

	mov dx, 0
	call movecursor

	mov al, ' '
	mov bh, 0
	mov bl, 1Fh
	mov cx, 2000
	call clearbg

	mov dl, 35
	mov dh, 4
	call movecursor

	mov si, .helptitle
	call printstr

	mov dl, 10
	add dh, 3
	call movecursor

	mov si, .help1
	call printstr

	inc dh
	call movecursor

	mov si, .help2
	call printstr

	inc dh
	call movecursor

	mov si, .help3
	call printstr

	inc dh
	inc dh
	inc dh
	inc dh
	call movecursor

	mov si, .help4
	call printstr

	.waitkey:

		call keypress

		cmp al, ' '
		je main

		jmp .waitkey

	.helptitle	db "GAME HELP", 0
	.help1		db "* Press <A> key to move the car to the left.", 0
	.help2		db "* Press <D> key to move the car to the right.", 0
	.help3		db "* Avoid getting crashed by cars around you!", 0
	.help4		db "Press SPACE to exit this menu", 0

levelup:

	pusha

	mov dx, 0
	call movecursor

	mov al, ' '
	mov bh, 0
	mov bl, 1Fh

	mov cx, 25
	.loopcurtain:
		push cx
		mov cx, 1
		call delay
		mov cx, 80
		call clearbg
		pop cx
		inc dh
		call movecursor
		loop .loopcurtain

	mov dh, 12
	mov dl, 36
	call movecursor

	mov si, leveluptext
	call printstr

	mov cx, 2
	.loopsound:
		push cx
		mov ax, 1000
		mov cx, 3
		call playsound
		mov cx, 3
		call delay
		pop cx
		loop .loopsound

	call music

	mov cx, 5
	call delay

	mov byte [player_levelup], 1
	
	popa

	jmp gamestart.scoring

music:

	; This plays a music
	; (EXPERIMENTAL)

	pusha

	mov ax, 1050
	mov cx, 3
	call playsound		; first tone

	mov ax, 1000
	mov cx, 3
	call playsound		; second tone

	mov ax, 950
	mov cx, 3
	call playsound		; third tone

	mov ax, 750
	mov cx, 3
	call playsound		; fourth tone

	popa

	ret


; HELPER FUNCTIONS

exit:
	mov dx, 0
	call movecursor
	call showcursor
	mov al, ' '
	mov bh, 0
	mov bl, 07h
	mov cx, [screensize]
	call clearbg
	mov si, .thanks
	call printstr
	mov ah, 4Ch
	mov al, 0
	int 21h
	.thanks	db 'Thank you for playing!', 0xD, 0xA, 'Made on 16-bit assembly. (NASM)', 0xD, 0xA, 0xD, 0xA, 'My groupmates: ', 0xD, 0xA, '  Catucod, Renato Jr.    - Programmer', 0xD, 0xA, '  Piagola, Loraine Mae    - Car/Terrain Design', 0xD, 0xA, '  Pangan, Jeffrey    - Game Mechanics', 0xD, 0xA, '  Abaja, Kyle Adrian    - Game Menu/Prompts', 0xD, 0xA, 0xD, 0xA, 'As an intended project for CpE-Special Course.', 0xD, 0xA, '  Instructor: Jatico, Clandestine', 0xD, 0xA, 0

; input:	al 		= new page number
selectpage:
	mov ah, 05h
	int 10h
	ret

; input:	al 		= character to draw
;			bh		= page number
; 			bl 		= attribute/color used to write
;			cx 		= number of times to write character
clearbg:
	mov ah, 09h
	int 10h
	ret

; input:	si		= string to print
printstr:
	pusha
	mov ah, 0Eh
	.repeats:
		lodsb
		int 10h
		cmp al, 0
		jne .repeats
	popa
	ret

; output:	al 		= key being pressed
;			ah		= BIOS scan code
keypress:
	mov ah, 00h
	int 16h
	ret

; output:	al 		= key being pressed
;			zf		= 0 if no key press1 otherwise
checkkey:
	mov ah, 0Bh
	int 21h
	ret

hidecursor:
	pusha
	mov ch, 32
	mov ah, 1
	int 10h
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

; input:	dh		= row
;			dl		= column
;			bh		= page number
movecursor:
	pusha
	mov ah, 2
	int 10h
	popa
	ret

; input:	ax		= number to be converted to str
; output:	ax		= string location
inttostr:
	pusha
	mov cx, 0
	mov bx, 10			; Set BX 10, for division and mod
	mov di, .t			; Get our pointer ready
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
	mov ax, .t			; Return location of string
	ret
	.t times 7 db 0

; input:	cx:dx	= interval in microseconds
; return:	cf		= clear if successful otherwise not
delay:
	push ax
	mov ah, 86h
	int 15h
	pop ax
	ret


randseed:
	push bx
	push ax
	mov bx, 0
	mov al, 0x02					; Minute
	out 0x70, al
	in al, 0x71
	mov bl, al
	shl bx, 8
	mov al, 0						; Second
	out 0x70, al
	in al, 0x71
	mov bl, al
	mov word [rseed], bx	; Seed will be something like 0x4435 (if it were 44 minutes and 35 seconds after the hour)
	pop ax
	pop bx
	ret
	rseed	dw 0


; input:	ax		= low int
;			bx		= high int
; output:	cx		= random int number
randrange:
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

; input:	ax		= frequency
;			cx		= delay in microseconds
playsound:
	pusha
	mov bx, ax				; sets bx with a corresponding frequency
	mov al, 182				; enable write
	out 43h, al				; send to port
	mov ax, bx				; send frequency 
	out 42h, al				; send to speaker
	mov al, ah
	out 42h, al
	in al, 61h				; enable read 
	or al, 03h
	out 61h, al
	mov ah, 86h
	int 15h
	in al, 61h
	and al, 0FCh
	out 61h, al
	popa
	ret
