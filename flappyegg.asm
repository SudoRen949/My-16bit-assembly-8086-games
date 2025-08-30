

bits 16
org 100h

section .data

	color_yellow		dw 0E0h
	color_sky			dw 03Fh
	color_red			dw 04Fh
	
	score				dw 0
	score_t				db "Score: ", 0
	score_delay			db 0
	
	ypos				db 10
	
	fly					db 0
	speed				db 1

	fall_delay			db 0
	
	box1pos				db 40
	box2pos				db 65
	
	playing				db 0

section .text

main:

	mov ax, ax
	mov es, ax
	
	mov ah, 00h
	mov al, 03h
	int 10h

	mov ax, 1003h
	int 10h			; enable bright colors
	
	.background:
	
		mov cx, 1
		
		mov ah, 86h
		int 15h
	
		mov dx, 0
		call movecursor
		
		mov cx, 2000
		mov bl, [color_sky]
		call clearbackground
		
	.score:
	
		mov dl, 1
		mov dh, 1
		call movecursor
		
		mov si, score_t
		call printstring
		
		mov ax, [score]
		call inttostr
		
		mov si, ax
		call printstring
		
		inc word [score_delay]
		
		cmp byte [score_delay], 10
		je .incscore
		
		jmp .boxes
		
		.incscore:
		
			inc word [score]
			
			cmp byte [score], 20
			je .incspeed
			
			cmp byte [score], 30
			je .incspeed2
			
			cmp byte [score], 100
			je win
			
			jmp .cont
			
			.incspeed:
			
				inc byte [speed]
				
				jmp .cont
				
			.incspeed2:
			
				inc byte [speed]
				inc byte [speed]
				
			.cont:
			
				mov byte [score_delay], 0
		
	.boxes:
	
		mov byte cl, [box1pos]
		mov ch, 16
		mov dl, 5
		mov dh, 10
		mov bl, [color_red]
		call drawbox
		
		mov byte cl, [box2pos]
		mov ch, 0
		mov dl, 5
		mov dh, 10
		mov bl, [color_red]
		call drawbox
		
		mov byte al, [speed]
		sub byte [box1pos], al
		sub byte [box2pos], al
		
		cmp byte [box1pos], 0
		jle .resetbox1
		
		jmp .checkother1
		
		.resetbox1:
		
			mov byte [box1pos], 75
		
		.checkother1:
		
			cmp byte [box2pos], 0
			jle .resetbox2
			
			jmp .player
			
			.resetbox2:
			
				mov byte [box2pos], 75
	
	.player:
		
		mov byte [fly], 0
	
		call checkkey
		
		cmp al, 0
		jne .key
		
		mov cl, 5
		mov byte ch, [ypos]
		mov bl, [color_yellow]
		call drawegg
		
		.collision:
			
			cmp byte [ypos], 11
			jle .checkboxxpos
			
			cmp byte [ypos], 13
			jge .checkboxxpos2
			
			jmp .contfall
			
			.checkboxxpos:
			
				cmp byte [box2pos], 3
				jge .checkanotherboxxpos
				
				jmp .contfall
				
				.checkanotherboxxpos:
				
					cmp byte [box2pos], 8
					jle crashed
					
					jmp .contfall
					
			.checkboxxpos2:
			
				cmp byte [box1pos], 5
				jge .checkanotherboxxpos2
				
				jmp .contfall
				
				.checkanotherboxxpos2:
				
					cmp byte [box1pos], 10
					jle crashed
					
					jmp .contfall
		
		.contfall:
		
		cmp byte [fly], 0
		je .fall
			
		jmp .background
		
		.fall:
		
			inc byte [fall_delay]
			
			cmp byte [fall_delay], 3
			je .startfall
			
			jmp .background
			
			.startfall:
			
				mov byte [fall_delay], 0
			
				cmp byte [ypos], 21
				jne .falll
				
				jmp .background
				
				.falll:
	
					inc byte [ypos]
		
			jmp .background
		
	.key:
	
		call keypress
		
		cmp al, 27
		je .quit
		
		cmp al, 32
		je .fly
	
		jmp .key
		
	.fly:
	
		cmp byte [playing], 0
		je .startplay
		
		jmp .done1
		
		.startplay:
		
			mov byte [playing], 1
	
		.done1:
	
		mov byte [fly], 1
	
		cmp byte [ypos], 0
		jg .flyy
		
		jmp .player
		
		.flyy:
	
			dec byte [ypos]

			jmp .player
		
	.quit:
	
		mov dx, 0
		call movecursor
		
		mov cx, 2000
		mov bl, 007h
		call clearbackground
	
		int 20h


crashed:

	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, 004h
	call clearbackground
	
	mov dl, 33
	mov dh, 10
	call movecursor
	
	mov si, .text
	call printstring
	
	mov dh, 13
	mov dl, 36
	call movecursor
	
	mov si, score_t
	call printstring
	
	mov ax, [score]
	call inttostr
	
	mov si, ax
	call printstring
	
	.key:
	
		call keypress
		
		cmp al, 32
		je main.background
		
		cmp al, 27
		je main.quit
	
		jmp .key
	
	.text		db "You Crashed! :(", 0
	
win:

	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, [color_sky]
	call clearbackground
	
	mov dl, 35
	mov dh, 10
	call movecursor
	
	mov si, .text
	call printstring
	
	mov dh, 13
	mov dl, 36
	call movecursor
	
	mov si, score_t
	call printstring
	
	mov ax, [score]
	call inttostr
	
	mov si, ax
	call printstring
	
	.key:
	
		call keypress
		
		cmp al, 32
		je main.background
		
		cmp al, 27
		je main.quit
	
		jmp .key
	
	.text		db "You Win! :(", 0




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

movecursor:

	pusha
	
	mov bh, 0
	mov ah, 2
	int 10h
	
	popa
	
	ret
	
clearbackground:

	mov al, ' '
	mov bh, 0
	mov ah, 09h
	int 10h
	
	ret

drawegg:

	pusha
	
	mov byte [.position], cl
	mov byte [.position+1], ch
	
	mov cx, 0
	
	mov byte dl, [.position]
	mov byte dh, [.position+1]
	call movecursor
	
	add dl, 2
	call movecursor
	
	mov cx, 3
	call clearbackground
	
	inc dh
	sub dl, 1
	call movecursor
	
	mov cx, 5
	call clearbackground
	
	inc dh
	sub dl, 1
	call movecursor
	
	mov cx, 7
	call clearbackground
	
	inc dh
	add dl, 1
	call movecursor
	
	mov cx, 5
	call clearbackground
	
	popa
	
	ret
	
	.position db 0,0


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
	
keypress:

	mov ah, 00h
	int 16h
	
	ret

checkkey:

	mov ah, 0Bh
	int 21h
	
	ret

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



