

BITS 16
org 100h

jmp main

frog_position	db 3
car1_position	db 0
car2_position	db 25
score			dw 0
timer			db 0
level			db 0
speed			db 1
move_delay		db 0

main:

	mov ah, 0
	mov al, 03h
	int 10h
	
	mov ax, 1003h
	int 10h
	
	.background:
	
		mov cx, 1
		
		mov ah, 86h
		int 15h
	
		mov dx, 0
		call movecursor
		
		mov cx, 2000
		mov bl, 0AFh
		call clearbackground
	
	.road:
		
		cmp byte [level], 0
		je .speednormal
		
		cmp byte [level], 1
		je .speedmedium
		
		cmp byte [level], 2
		je .speedhard
		
		.speednormal:
		
			mov byte [speed], 1
			
			jmp .cont4
			
		.speedmedium:
		
			mov byte [speed], 2
			
			jmp .cont4
			
		.speedhard:
		
			mov byte [speed], 2
			
		.cont4:
	
		mov dl, 15
		mov dh, 0
		call movecursor
		
		mov cx, 25
		
		.height:
		
			push cx
			
			mov cx, 50
			mov bl, 08Fh
			call clearbackground
			
			pop cx
			
			inc dh
			call movecursor
			
			loop .height
		
		mov dl, 40
		mov dh, 0
		call movecursor
		
		mov cx, 25
		
		.height2:
		
			push cx
			
			mov cx, 1
			mov bl, 0EFh
			call clearbackground
			
			pop cx
			
			inc dh
			call movecursor
			
			loop .height2
			
	.score:
	
		mov dl, 25
		mov dh, 23
		call movecursor
		
		inc byte [timer]
		
		cmp byte [timer], 25
		je .incscore
		
		jmp .drawcar
		
		.incscore:
		
			mov byte [timer], 0
		
			inc word [score]
	
	.drawcar:
	
		mov cl, 24
		mov byte ch, [car1_position]
		mov bl, 04Fh
		call drawcar
		
		mov cl, 24
		mov byte ch, [car1_position]
		mov bl, 04Fh
		call drawcar
		
		mov cl, 50
		mov byte ch, [car2_position]
		mov bl, 04Fh
		call drawcar
		
		mov byte al, [speed]
		
		inc byte [move_delay]
		
		cmp byte [move_delay], 5
		je .moveobs
		
		jmp .cont5
		
		.moveobs:
		
			mov byte [move_delay], 0
		
			add byte [car1_position], al
			sub byte [car2_position], al
		
		.cont5:
		
		cmp byte [car1_position], 21
		jge .reset1
		
		jmp .cont1
		
		.reset1:
		
			mov byte [car1_position], 0
		
		.cont1:
		
			cmp byte [car2_position], 0
			jle .reset2
			
			jmp .drawfrog
			
			.reset2:
			
				mov byte [car2_position], 25
	
	.drawfrog:
	
		call checkkey
		
		cmp al, 0
		jne .key
		
		mov byte cl, [frog_position]
		mov ch, 12
		mov bl, 06Fh
		call drawfrog
		
		.collision:		; COLLISION DETECTION FOR FROG AND THE CARS
		
			cmp byte [frog_position], 65
			jge .inclevel
			
			jmp .cont3
			
			.inclevel:
			
				inc byte [level]
				
				cmp byte [level], 2
				jg gameover
				
				mov byte [frog_position], 3
				mov byte [car1_position], 0
				mov byte [car2_position], 25
				
				jmp main.background
			
			.cont3:
			
			cmp byte [frog_position], 21
			jge .checkxl
			
			jmp .cont2
			
			.checkxl:
			
				cmp byte [frog_position], 27
				jle .checkcary
				
				jmp .cont2
				
				.checkcary:
				
					cmp byte [car1_position], 9
					je crashed
					
					cmp byte [car1_position], 10
					je crashed
					
					cmp byte [car1_position], 11
					je crashed
					
					jmp .done
					
			.cont2:
			
				cmp byte [frog_position], 48
				jge .checkxl2
				
				jmp .done
				
				.checkxl2:
			
					cmp byte [frog_position], 50
					jle .checkcary2
					
					jmp .done
					
					.checkcary2:
					
						cmp byte [car2_position], 12
						je crashed
						
						cmp byte [car2_position], 10
						je crashed
						
						cmp byte [car2_position], 9
						je crashed
		
		.done:
		
			jmp .background
		
	.key:
		
		call keypress
		
		cmp al, 27
		je .quit
		
		cmp al, 'd'
		je .movefrog
		
		jmp .drawfrog
	
	.movefrog:
		
		inc byte [frog_position]
		
		jmp .drawfrog
	
	.quit:
	
		mov dx, 0
		call movecursor
		
		mov cx, 2000
		mov bl, 007h
		call clearbackground
	
		ret
	
	.score_text db "Score: ", 0

crashed:

	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, 00Ch
	call clearbackground
	
	mov dl, 34
	mov dh, 10
	call movecursor
	
	mov si, .text
	call printstring
	
	inc dh
	inc dh
	mov dl, 35
	call movecursor
	
	mov si, .sss
	call printstring
	
	mov cx, 50
	mov ah, 86h
	int 15h
	
	.key:
	
		call keypress
		
		cmp al, 0
		jne main.quit
		
		jmp .key
	
	.text db "You crashed!", 0
	.sss db "Score: 0", 0

gameover:

	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, 03Fh
	call clearbackground
	
	mov dl, 29
	mov dh, 10
	call movecursor
	
	mov si, .text
	call printstring
	
	inc dh
	inc dh
	mov dl, 35
	call movecursor
	
	mov si, .sss
	call printstring
	
	mov cx, 50
	mov ah, 86h
	int 15h
	
	.key:
		
		call keypress
		
		cmp al, 0
		jne main.quit
		
		jmp .key
	
	.text db "You cross successfuly!", 0
	.sss db "Score: 100", 0


	
clearbackground:

	pusha
	
	mov ah, 09h
	mov bh, 0
	mov al, ' '
	int 10h
	
	popa
	
	ret

printstring:

	pusha

	mov ah, 0Eh
	
	.reps:
	
		lodsb
		
		int 10h
	
		cmp al, 0
		jne .reps

	popa

	ret

movecursor:

	mov ah, 2
	mov bh, 0
	int 10h

	ret
	
keypress:

	mov ah, 00h
	int 16h
	
	ret
	
drawfrog:

	pusha
	
	mov byte [.position], cl
	mov byte [.position+1], ch
	
	mov cx, 0
	
	mov byte dl, [.position]
	mov byte dh, [.position+1]
	call movecursor
	
	add dl, 3
	call movecursor
	
	mov cx, 3
	call clearbackground
	
	sub dl, 1
	inc dh
	call movecursor
	
	mov cx, 4
	call clearbackground
	
	sub dl, 1
	inc dh
	call movecursor
	
	mov cx, 4
	call clearbackground
	
	sub dl, 1
	inc dh
	call movecursor
	
	mov cx, 3
	call clearbackground
	
	add dl, 4
	call movecursor
	
	mov cx, 2
	call clearbackground
	
	popa
	
	ret
	
	.position db 0,0

checkkey:

	mov ah, 0Bh
	int 21h
	
	ret
	
wordtostring:

	pusha
	
	mov cx, 0
	mov bx, 10	
	mov di, .arr	

	.pusher:

		mov dx, 0		
		div bx			
		inc cx			
		
		push dx			
		
		test ax, ax		
		jnz .pusher		

	.popper:

		pop dx			;
		
		add dl, '0' 	
		mov [di], dl 	
		inc di
		dec cx		
		jnz .popper		

	mov byte [di], 0
	
	popa

	mov ax, .arr

	ret

	.arr	times 7 db 0

drawcar:

	mov byte [.position], cl
	mov byte [.position+1], ch
	
	mov cx, 0
	
	mov byte dl, [.position]
	mov byte dh, [.position+1]
	call movecursor
	
	; ------
	
	add dl, 1
	call movecursor
	
	mov cx, 4
	call clearbackground
	
	; -------
	
	sub dl, 1
	inc dh
	call movecursor
	
	push bx
	mov cx, 1
	mov bl, 00Fh
	call clearbackground
	pop bx
	
	add dl, 1
	call movecursor
	
	mov cx, 4
	call clearbackground
	
	add dl, 4
	call movecursor
	
	push bx
	mov cx, 1
	mov bl, 00Fh
	call clearbackground
	pop bx
	
	; --------
	
	inc dh
	sub dl, 4
	call movecursor
	
	mov cx, 4
	call clearbackground
	
	; -------
	
	sub dl, 1
	inc dh
	call movecursor
	
	push bx
	mov cx, 1
	mov bl, 00Fh
	call clearbackground
	pop bx
	
	add dl, 1
	call movecursor
	
	mov cx, 4
	call clearbackground
	
	add dl, 4
	call movecursor
	
	push bx
	mov cx, 1
	mov bl, 00Fh
	call clearbackground
	pop bx
	
	; ------
	
	inc dh
	sub dl, 4
	call movecursor
	
	mov cx, 4
	call clearbackground
	
	ret
	
	.position db 0,0



