


bits 16
org 100h

jmp main

; -- game variables --

color_gray		db 08Fh ; stone
color_brown		db 06Fh ; acorn
color_yellow	db 0E0h	; squirrel
color_sky		db 03Fh ; bg
score			dw 0
score_delay		db 0
score_text		db "Score: ", 0
; life			dw 0
; life_text		db "Life: ", 0
xpos			db 37
isacorn			db 0  ; boolean for determining if its rock or an acorn
rocky			db 0  ; rock's y position
acorny			db 0  ; acorn's y position
randseed		dw 0  ; random seed (used for randomizing objects)
rockx			db 7
acornx			db 7

main:

	mov ah, 00h
	mov al, 03h
	int 10h
	
	mov ax, 1003h
	int 10h
	
	call initrandseed		; initialize randomization
	
	.background:
	
		mov cx, 1
		call delay
	
		mov dx, 0
		call movecursor
		
		mov cx, 2000
		mov bl, [color_sky]
		call clearbackground
		
		; ground
		
		mov dl, 0
		mov dh, 17
		call movecursor
		
		mov cx, 640
		mov bl, 02Fh
		call clearbackground
		
	.score:
	
		mov dl, 1
		mov dh, 1
		call movecursor
		
		mov si, score_text
		call println
		
		mov ax, [score]
		call inttostr
		mov si, ax
		call println
		
		cmp word [score], 100
		je wingame
	
	.obstacles:
	
		cmp byte [isacorn], 0
		je .drawrock
		
		jmp .drawacorn
		
		.drawrock:
			
			mov byte [acorny], 0
			
			cmp byte [rocky], 22
			je .gotorandom1
			
			jmp .contdraw1
			
			.gotorandom1:
			
				mov ax, 0
				mov bx, 4
				call randrange
				
				mov byte [rocky], 0
				
				mov ax, 15
				mov bx, cx
				mul bx			; multiply AX*BX
				add ax, 7
				
				mov byte [rockx], al
				
				mov ax, 0
				mov bx, 1
				call randrange
				
				mov cx, 1
				je .showacorn
				
				jmp .contdraw1
				
				.showacorn:
				
					mov byte [isacorn], 1
				
			.contdraw1:
				
				mov byte cl, [rockx]
				mov byte ch, [rocky]
				mov bl, [color_gray]
				call drawrock				; rock
				
				inc byte [rocky]
				
				jmp .player
		
		.drawacorn:
		
			mov byte [rocky], 0
		
			cmp byte [acorny], 22
			je .gotorandom2
			
			cmp byte [acorny], 18
			je .gotorandom2
			
			jmp .contdraw2
			
			.gotorandom2:
			
				mov ax, 0
				mov bx, 4
				call randrange
				
				mov byte [acorny], 0
				
				mov ax, 15
				mov bx, cx
				mul bx			; multiply AX*BX
				add ax, 7
				
				mov byte [acornx], al
				
				mov ax, 0
				mov bx, 1
				call randrange
				
				mov cx, 0
				je .showrock
				
				jmp .contdraw2
				
				.showrock:
				
					mov byte [isacorn], 0
			
			.contdraw2:
			
				mov byte cl, [acornx]
				mov byte ch, [acorny]
				mov bl, [color_brown]
				call drawacorn				; acorn
				
				inc byte [acorny]
	
	.player:
	
		call checkkey
		
		cmp al, 0
		jne .key
		
		mov byte cl, [xpos]
		mov ch, 20
		mov bl, [color_yellow]
		call drawsquirrel
		
		.collision:				; COLLISION DETECTIOOOOONN BOGS boGS
			
			mov byte al, [rockx]
			cmp byte [xpos], al
			je .checkrandcpos
			
			mov byte al, [acornx]
			cmp byte [xpos], al
			je .checkaandcpos
			
			jmp .background
			
			.checkrandcpos:
			
				cmp byte [rocky], 18
				jge fail
				
				jmp .background
			
			.checkaandcpos:
			
				cmp byte [acorny], 18
				jge .incscore
				
				jmp .background
				
				.incscore:
				
					add word [score], 5
		
					jmp .background
	
	.key:
	
		call keypress
		
		cmp al, 27
		je .quitgame
		
		cmp al, 'd'
		je .move1
		
		cmp al, 'a'
		je .move2
	
		jmp .key
	
	.move2:
	
		sub byte [xpos], 15
		
		cmp byte [xpos], 7
		jle .stop1
		
		jmp .player
		
		.stop1:
		
			mov byte [xpos], 7
		
			jmp .player
		
	
	.move1:
	
		add byte [xpos], 15
		
		cmp byte [xpos], 67
		jge .stop2
		
		jmp .player
		
		.stop2:
		
			mov byte [xpos], 67
		
			jmp .player
	
	.quitgame:
	
		mov dx, 0
		call movecursor
		
		mov cx, 2000
		mov bl, 007h
		call clearbackground
	
		ret

fail:

	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, 00Ch
	call clearbackground
	
	mov dl, 25
	mov dh, 10
	call movecursor
	
	mov si, .t1
	call println
	
	mov dl, 35
	mov dh, 13
	call movecursor
	
	mov si, score_text
	call println
	
	mov ax, [score]
	call inttostr
	mov si, ax
	call println
	
	mov dl, 29
	mov dh, 20
	call movecursor
	
	mov si, .t2
	call println
	
	.key:
	
		call keypress
		
		cmp al, 0
		jne main.quitgame
		
		jmp .key
	
	.t1		db "You have been bonked by a rock :(", 0
	.t2		db "Press any key to exit", 0

wingame:

	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, 03Fh
	call clearbackground
	
	mov dl, 28
	mov dh, 10
	call movecursor
	
	mov si, .t1
	call println
	
	mov dl, 35
	mov dh, 13
	call movecursor
	
	mov si, score_text
	call println
	
	mov ax, [score]
	call inttostr
	mov si, ax
	call println
	
	mov dl, 29
	mov dh, 20
	call movecursor
	
	mov si, .t2
	call println
	
	.key:
	
		call keypress
		
		cmp al, 0
		jne main.quitgame
		
		jmp .key
	
	.t1		db "Congratulations You Won ;)", 0
	.t2		db "Press any key to exit", 0

println:

	pusha
	
	mov ah, 0Eh
	
	.reps:
	
		lodsb
		
		int 10h
	
		cmp al, 0
		jne .reps
	
	popa
	
	ret

clearbackground:

	pusha
	
	mov ah, 09h
	mov bh, 0
	mov al, ' '
	int 10h
	
	popa
	
	ret

movecursor:

	mov ah, 2
	mov bh, 0
	int 10h
	
	ret

delay:

	mov ah, 86h
	int 15h
	
	ret

drawacorn:

	pusha
	
	mov byte [.position], cl
	mov byte [.position+1], ch
	
	mov cx, 0
	
	mov byte dl, [.position]
	mov byte dh, [.position+1]
	call movecursor
	
	add dl, 1
	call movecursor
	
	mov cx, 4
	call clearbackground
	
	inc dh
	sub dl, 1
	call movecursor
	
	mov cx, 6
	call clearbackground
	
	inc dh
	add dl, 1
	call movecursor
	
	mov cx, 4
	call clearbackground
	
	inc dh
	add dl, 1
	call movecursor
	
	mov cx, 2
	call clearbackground
	
	popa
	
	ret
	
	.position	db 0,0


inttostr:

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

drawsquirrel:

	pusha
	
	mov byte [.pos], cl
	mov byte [.pos+1], ch
	
	mov cx, 0
	
	mov byte dl, [.pos]
	mov byte dh, [.pos+1]
	add dl, 5
	call movecursor
	
	mov cx, 1
	call clearbackground
	
	inc dh
	
	sub dl, 4
	call movecursor
	
	mov cx, 2
	call clearbackground
	
	add dl, 3
	call movecursor
	
	mov cx, 3
	call clearbackground
	
	inc dh
	
	sub dl, 4
	call movecursor
	
	mov cx, 1
	call clearbackground
	
	add dl, 2
	call movecursor
	
	mov cx, 3
	call clearbackground
	
	inc dh
	
	add dl, 1
	call movecursor
	
	mov cx, 3
	call clearbackground
	
	popa
	
	ret
	
	.pos	db 0,0

keypress:

	mov ah, 00h
	int 16h

	ret

checkkey:

	mov ah, 0Bh
	int 21h
	
	ret

drawrock:

	pusha
	
	mov byte [.position], cl
	mov byte [.position+1], ch
	
	mov byte dl, [.position]
	mov byte dh, [.position+1]
	add dl, 1
	call movecursor
	
	mov cx, 3
	call clearbackground
	
	inc dh
	
	sub dl, 1
	call movecursor
	
	mov cx, 5
	call clearbackground
	
	inc dh
	call movecursor
	
	mov cx, 5
	call clearbackground
	
	inc dh
	
	add dl, 1
	call movecursor
	
	mov cx, 3
	call clearbackground
	
	popa
	
	ret
	
	.position db 0,0

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
	mov word [randseed], bx		; Seed will be something like 0x4435 (if it were 44 minutes and 35 seconds after the hour)
	
	pop ax
	pop bx
	
	ret

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
		mov ax, [randseed]
		mov dx, 23167
		mul dx				; DX:AX = AX * DX
		add ax, 12409
		adc dx, 0
		mov [randseed], ax
	 	pop dx
		ret


