
bits 16
org 100h

section .data

    color_blackwhite    dw 00Fh
    color_blacklgray    dw 007h
    color_whiteblack    dw 0F0h
    color_lgrayblack    dw 070h
    color_redwhite		dw 04Fh

    game_name           db "PING PONG GAME", 0
    
    menu_play           db "  Play  ", 0
    menu_quit           db "  Quit  ", 0
    menu_larrow         db '>', 0
    menu_rarrow         db '<', 0
    
    key_escape          db 27
    key_enter           db 13
    key_space           db 32
    key_w				db 'w', 0
    key_s				db 's', 0
    key_i				db 'i', 0
    key_k				db 'k', 0
	
    option_selected     db 0

    mode_text           db "Select Mode", 0
    mode_single         db "    1 Player    ", 0
    mode_double         db "   2 Players    ", 0
    
    ; -- Game Variables
    
    score_p1_text		db "Score: ", 0
    score_p1			dw 0
    score_p2_text       db "Score:", 0
    score_p2			dw 0
    
    start_game			db 0
    start_text			db "Press SPACE to start", 0
    
    seed				dw 0
    
    ball_xdir			db 0		; -- direction only: 0 = left, 1 = right.
    ball_ydir			db 0		; -- direction for y axis: 0 = down, 1 = up.
    ball_xpos			db 40
    ball_ypos			db 12
    
    paddle1_xpos		db 0
    paddle1_ypos		db 10
    paddle1_wsize		db 1
    paddle1_hsize		db 4
    
    paddle2_xpos		db 79
    paddle2_ypos		db 10
    paddle2_wsize		db 1
    paddle2_hsize		db 4
    
    ai_delay			db 0		; -- AI delay for single player
    
    game_time			dw 0
    game_time_text		db "Time: ", 0
    game_time_delay		db 0
    
    win_player1			db "Player 1 Wins!", 0
    win_player2			db "Player 2 Wins!", 0
    win_tie				db "It's a tie!", 0
    
section .text

    global main
    
main:

    mov ax, 0
    mov es, ax
    
    mov ah, 00h
    mov al, 03h
    int 10h
    
    mov ax, 1003h
    int 10h
    
    call cursorhide
    call initrandomseed
    
    .background:
    
        mov dx, 0
        call movecursor
        
        mov cx, 2000
        mov bl, [color_blackwhite]
        call clearbackground
        
        mov dl, 33
        mov dh, 4
        call movecursor
        
        mov si, game_name
        call println
        
    .button:
    
        add dh, 6
        
        mov cl, 37
        inc dh
        mov ch, dh
        dec dh
        push dx
        mov dl, 8
        mov dh, 3
        mov bl, [color_lgrayblack]
        call drawbox
        
        mov cl, 36
        pop dx
        mov ch, dh
        push dx
        mov dl, 8
        mov dh, 3
        mov bl, [color_whiteblack]
        call drawbox
        pop dx
        
        add dh, 1
        mov dl, 36
        call movecursor
        
        mov si, menu_play
        call println
        
        add dh, 4
        
        mov cl, 37
        inc dh
        mov ch, dh
        dec dh
        push dx
        mov dl, 8
        mov dh, 3
        mov bl, [color_lgrayblack]
        call drawbox

        mov cl, 36
        pop dx
        mov ch, dh
        push dx
        mov dl, 8
        mov dh, 3
        mov bl, [color_whiteblack]
        call drawbox
        pop dx
        
        add dh, 1
        mov dl, 36
        call movecursor
        
        mov si, menu_quit
        call println
        
        .selector:
        
            cmp byte [option_selected], 0
            je .selectfirst
            
            jmp .selectsecond
        
            .selectfirst:
            
                mov dh, 11
                
                jmp .drawselection
            
            .selectsecond:
            
                mov dh, 16
            
            .drawselection:
            
                mov dl, 34
                call movecursor
            
                mov si, menu_larrow
                call println
                
                mov dl, 46
                call movecursor
                
                mov si, menu_rarrow
                call println
    
    .keywait:
    
        call keypress
        
        ;cmp byte al, [key_escape]		-- used for debugging only
        ;je exit
        
        cmp byte al, [key_space]
        je .select
        
        cmp byte al, [key_enter]
        je .confirm
        
        jmp .keywait
        
    .select:
    
        xor byte [option_selected], 1
        
        jmp .background
        
    .confirm:
    
        cmp byte [option_selected], 0
        je menu
        
        jmp exit

menu:

    mov byte [option_selected], 0
    
    .background:
    
    	mov dx, 0
    	call movecursor
    
        mov cx, 2000
        mov bl, [color_blackwhite]
        call clearbackground
        
        mov dh, 4
        mov dl, 35
        call movecursor
        
        mov si, mode_text
        call println
        
    .button:
    
        mov cl, 33
        mov ch, 9
        mov dl, 16
        mov dh, 3
        mov bl, [color_lgrayblack]
        call drawbox
    
        mov cl, 32
        mov ch, 8
        mov dl, 16
        mov dh, 3
        mov bl, [color_whiteblack]
        call drawbox
        
        mov dh, 9
        mov dl, 32
        call movecursor
        
        mov si, mode_single
        call println
        
		; ------------
        
        mov cl, 33
        mov ch, 14
        mov dl, 16
        mov dh, 3
        mov bl, [color_lgrayblack]
		call drawbox
    
        mov cl, 32
        mov ch, 13
        mov dl, 16
        mov dh, 3
        mov bl, [color_whiteblack]
        call drawbox
        
        mov dh, 14
        mov dl, 32
        call movecursor
        
        mov si, mode_double
        call println
        
        .selector:
        
        	cmp byte [option_selected], 0
        	je .selectfirst
        	
        	jmp .selectsecond
			
			.selectfirst:
			
				mov dh, 9
				
				jmp .draw
				
			.selectsecond:
			
				mov dh, 14
			
        	.draw:
        		
        		mov dl, 30
        		call movecursor
        		
        		mov si, menu_larrow
        		call println
        		
        		mov dl, 50
        		call movecursor
        		
        		mov si, menu_rarrow
        		call println
        
	.keywait:
	
		call keypress
		
		cmp byte al, [key_escape]
		je main.background
		
		cmp byte al, [key_space]
		je .select
		
		cmp byte al, [key_enter]
		je .confirm
	
		jmp .keywait
	
	.select:
	
		xor byte [option_selected], 1
		
		jmp .background
		
	.confirm:
	
		cmp byte [option_selected], 0
		je playsingle
		
		jmp playdouble
	
playsingle:

	mov byte [ball_xpos], 40
	mov byte [ball_ypos], 12
	mov byte [ball_xdir], 0
	mov byte [ball_ydir], 0
	mov byte [paddle1_ypos], 10
	mov byte [paddle2_ypos], 10
	mov byte [score_p1], 0
	mov byte [score_p2], 0
	mov byte [game_time], 0
	mov byte [game_time_delay], 0
	mov byte [start_game], 0

	.background:
	
		mov cx, 1
		call sleep
		
		mov dx, 0
		call movecursor
		
		mov cx, 2000
		mov bl, [color_blackwhite]
		call clearbackground
		
		cmp byte [start_game], 0
		je .start
		
		jmp .score
	
	.start:
	
		mov dh, 18
		mov dl, 31
		call movecursor
		
		mov si, start_text
		call println
	
	.score:
	
		inc byte [game_time_delay]
	
		mov dl, 10
		mov dh, 1
		call movecursor
		
		mov si, score_p1_text
		call println
		
		mov ax, [score_p1]
		call tostring
		mov si, ax
		call println            ; print score 1
		
		mov dh, 1
		mov dl, 35
		call movecursor
		
		mov si, game_time_text
		call println
		
		mov ax, [game_time]
		call tostring
		mov si, ax
		call println
		
		mov dl, 60
		mov dh, 1
		call movecursor
		
		mov si, score_p1_text
		call println
		
		mov ax, [score_p2]
		call tostring
		mov si, ax
		call println            ; print score 2
		
		cmp word [game_time], 100
		je win
		
		pusha					; -- move the AI
    
    	mov ax, 1
    	mov bx, 8
    	call randomrange
    	
    	cmp cx, 5
    	je .moveainow
    	
    	jmp .done3
    
    	.moveainow:
    	
    		mov ax, 1
	    	mov bx, 2
	    	call randomrange
	    	
	    	cmp cx, 1
	    	je .moveup
	    	
	    	jmp .movedown
    	
    	.moveup:
    	
    		cmp byte [paddle2_ypos], 0
    		jle .done5
    	
    		mov ax, 1
    		mov bx, 5
    		call randomrange
    		
    		.movingup:
    		
    			dec byte [paddle2_ypos]
    			
    			loop .movingup
    			
    			jmp .done
    			
    		.done5:
    		
    			add byte [paddle2_ypos], 2
    			
			.done:
			
    			jmp .done3
    			
    	.movedown:
    	
    		cmp byte [paddle2_ypos], 21
    		jge .done4
    	
    		mov ax, 1
    		mov bx, 5
    		call randomrange
    		
    		.movingdown:
    		
    			inc byte [paddle2_ypos]
    			
    			loop .movingdown
    			
    			jmp .done3
    			
    		.done4:
    		
    			sub byte [paddle2_ypos], 2
   			
    	.done3:
    	
    		popa
		
    .paddles:
    
    	mov byte cl, [paddle2_xpos]
    	mov byte ch, [paddle2_ypos]
    	mov dl, 1
    	mov dh, 4
    	mov bl, [color_whiteblack]
    	call drawbox			; draw paddle 2
    	
    	mov byte cl, [paddle1_xpos]
    	mov byte ch, [paddle1_ypos]
    	mov dl, 1
    	mov dh, 4
    	mov bl, [color_whiteblack]
    	call drawbox			; draw paddle 1
    	
    .ball:
    
    	cmp byte [start_game], 1
    	je .checkforkeys
    	
    	jmp .drawball
		
    	.checkforkeys:
    	
    		mov ax, 0
    		
    		call checkkey
    		
    		cmp al, 0
    		jne .keywait
    		
    	.moveball:
    	
    		cmp byte [ball_xpos], 0
    		jle .gotoright
    		
    		cmp byte [ball_xpos], 79
    		jge .gotoleft
    		
    		jmp .checky
    		
    		.gotoright:
    		
    			mov byte [ball_xdir], 1
    			
    			jmp .checky
    			
    		.gotoleft:
    		
    			mov byte [ball_xdir], 0
    			
    		.checky:
    		
    			cmp byte [ball_ypos], 0
    			jle .gotodown
    			
    			cmp byte [ball_ypos], 24
    			jge .gotoup
    			
    			jmp .checkcollision
    			
    			.gotodown:
    			
    				mov byte [ball_ydir], 0
    				
    				jmp .whatmove
    			
    			.gotoup:
    			
    				mov byte [ball_ydir], 1
    				
    				jmp .whatmove
    	
    		.checkcollision:		; -- collision detection
    		
    			pusha
    		
    			mov byte al, [paddle1_xpos]
    			add al, 1
    			cmp byte [ball_xpos], al
    			je .checkypospaddle1
    			
    			mov byte al, [paddle2_xpos]
    			sub al, 2
    			cmp byte [ball_xpos], al
    			je .checkypospaddle2
    			
    			popa
    			
    			jmp .whatmove
    			
    			.checkypospaddle1:
    			
    				mov byte al, [paddle1_ypos]
    				cmp byte [ball_ypos], al
    				jge .checkylesspaddle1
    				
    				jmp .whatmove
    				
    				.checkylesspaddle1:
    				
    					mov byte al, [paddle1_ypos]
    					add byte al, [paddle1_hsize]
    					cmp byte [ball_ypos], al
    					jle .collidetopaddle1
    					
    					jmp .whatmove
    					
    					.collidetopaddle1:
    					
    						mov byte [ball_xdir], 1
    						
    						inc word [score_p1]
    						
    						jmp .whatmove
    						
    			.checkypospaddle2:
    			
    				mov byte al, [paddle2_ypos]
    				cmp byte [ball_ypos], al
    				jge .checkylesspaddle2
    				
    				popa
    				
    				jmp .whatmove
    				
    				.checkylesspaddle2:
    				
    					mov byte al, [paddle2_ypos]
    					add byte al, [paddle2_hsize]
    					cmp byte [ball_ypos], al
    					jle .collidetopaddle2
    					
    					popa
    					
    					jmp .whatmove
    					
    					.collidetopaddle2:
    					
    						mov byte [ball_xdir], 0
    						
    						inc word [score_p2]
    						
    						popa
    						
    						jmp .whatmove
    	
    		.whatmove:
    		
    			cmp byte [ball_xdir], 0
	    		je .moveleft
	    		
	    		cmp byte [ball_xdir], 1
	    		je .moveright
    		
    		.moveleft:
    		
    			sub byte [ball_xpos], 1
    			
    			cmp byte [ball_ydir], 0
	    		je .movedown1
	    		
	    		cmp byte [ball_ydir], 1
	    		je .moveup1
	    		
	    		.movedown1:
	    		
	    			add byte [ball_ypos], 1
	    			
	    			jmp .drawball
	    			
	    		.moveup1:
	    		
	    			sub byte [ball_ypos], 1

    			jmp .drawball
    			
    		.moveright:
    		
    			add byte [ball_xpos], 1

    			cmp byte [ball_ydir], 0
	    		je .movedown2
	    		
	    		cmp byte [ball_ydir], 1
	    		je .moveup2
	    		
	    		.movedown2:
	    		
	    			add byte [ball_ypos], 1
	    			
	    			jmp .drawball
	    			
	    		.moveup2:
	    		
	    			sub byte [ball_ypos], 1

    	.drawball:
			
			mov byte cl, [ball_xpos]
	    	mov byte ch, [ball_ypos]
	    	mov dl, 1
	    	mov dh, 1
	    	mov bl, [color_redwhite]
	    	call drawbox
	    
	    cmp byte [game_time_delay], 50
	    jge .updategametime
	    
	    jmp .refresh
	    
	    .updategametime:
	    
	    	mov byte [game_time_delay], 0
	    
	    	inc word [game_time]		; -- update game time
	    	
	    .refresh:
	    
		    cmp byte [start_game], 1
		    je .background
	    
    .keywait:
    
    	call keypress
    	
    	cmp byte al, [key_escape]
    	je main.background
    	
    	cmp byte al, [key_space]
    	je .startgame
    	
    	cmp byte al, [key_w]
    	je .movepaddleup
    	
    	cmp byte al, [key_s]
    	je .movepaddledown
    
    	jmp .background
    	
    .startgame:
    
    	mov byte [start_game], 1
    	
    	jmp .background
    	
    .movepaddleup:
    
    	cmp byte [paddle1_ypos], 0
    	je .background
    
    	dec byte [paddle1_ypos]
    
    	jmp .background
    	
    .movepaddledown:
    
    	cmp byte [paddle1_ypos], 21
    	je .background
    
    	inc byte [paddle1_ypos]
    
    	jmp .background

playdouble:

	mov byte [ball_xpos], 40
	mov byte [ball_ypos], 12
	mov byte [ball_xdir], 0
	mov byte [ball_ydir], 0
	mov byte [paddle1_ypos], 10
	mov byte [paddle2_ypos], 10
	mov byte [score_p1], 0
	mov byte [score_p2], 0
	mov byte [game_time], 0
	mov byte [game_time_delay], 0
	mov byte [start_game], 0

	.background:
	
		mov cx, 1
		call sleep
		
		mov dx, 0
		call movecursor
		
		mov cx, 2000
		mov bl, [color_blackwhite]
		call clearbackground
		
		cmp byte [start_game], 0
		je .start
		
		jmp .score
	
	.start:
	
		mov dh, 18
		mov dl, 31
		call movecursor
		
		mov si, start_text
		call println
	
	.score:
	
		inc byte [game_time_delay]
	
		mov dl, 10
		mov dh, 1
		call movecursor
		
		mov si, score_p1_text
		call println
		
		mov ax, [score_p1]
		call tostring
		mov si, ax
		call println            ; print score 1
		
		mov dh, 1
		mov dl, 35
		call movecursor
		
		mov si, game_time_text
		call println
		
		mov ax, [game_time]
		call tostring
		mov si, ax
		call println
		
		mov dl, 60
		mov dh, 1
		call movecursor
		
		mov si, score_p1_text
		call println
		
		mov ax, [score_p2]
		call tostring
		mov si, ax
		call println            ; print score 2
		
		cmp word [game_time], 100
		je win
	
    .paddles:
    
    	mov byte cl, [paddle2_xpos]
    	mov byte ch, [paddle2_ypos]
    	mov dl, 1
    	mov dh, 4
    	mov bl, [color_whiteblack]
    	call drawbox			; draw paddle 2
    	
    	mov byte cl, [paddle1_xpos]
    	mov byte ch, [paddle1_ypos]
    	mov dl, 1
    	mov dh, 4
    	mov bl, [color_whiteblack]
    	call drawbox			; draw paddle 1
    	
    .ball:
    
    	cmp byte [start_game], 1
    	je .checkforkeys
    	
    	jmp .drawball
		
    	.checkforkeys:
    	
    		mov ax, 0
    		
    		call checkkey
    		
    		cmp al, 0
    		jne .keywait
    		
    	.moveball:
    	
    		cmp byte [ball_xpos], 0
    		jle .gotoright
    		
    		cmp byte [ball_xpos], 79
    		jge .gotoleft
    		
    		jmp .checky
    		
    		.gotoright:
    		
    			mov byte [ball_xdir], 1
    			
    			jmp .checky
    			
    		.gotoleft:
    		
    			mov byte [ball_xdir], 0
    			
    		.checky:
    		
    			cmp byte [ball_ypos], 0
    			jle .gotodown
    			
    			cmp byte [ball_ypos], 24
    			jge .gotoup
    			
    			jmp .checkcollision
    			
    			.gotodown:
    			
    				mov byte [ball_ydir], 0
    				
    				jmp .whatmove
    			
    			.gotoup:
    			
    				mov byte [ball_ydir], 1
    				
    				jmp .whatmove
    	
    		.checkcollision:		; -- collision detection
    		
    			pusha
    		
    			mov byte al, [paddle1_xpos]
    			add al, 1
    			cmp byte [ball_xpos], al
    			je .checkypospaddle1
    			
    			mov byte al, [paddle2_xpos]
    			sub al, 2
    			cmp byte [ball_xpos], al
    			je .checkypospaddle2
    			
    			popa
    			
    			jmp .whatmove
    			
    			.checkypospaddle1:
    			
    				mov byte al, [paddle1_ypos]
    				cmp byte [ball_ypos], al
    				jge .checkylesspaddle1
    				
    				jmp .whatmove
    				
    				.checkylesspaddle1:
    				
    					mov byte al, [paddle1_ypos]
    					add byte al, [paddle1_hsize]
    					cmp byte [ball_ypos], al
    					jle .collidetopaddle1
    					
    					jmp .whatmove
    					
    					.collidetopaddle1:
    					
    						mov byte [ball_xdir], 1
    						
    						inc word [score_p1]
    						
    						jmp .whatmove
    						
    			.checkypospaddle2:
    			
    				mov byte al, [paddle2_ypos]
    				cmp byte [ball_ypos], al
    				jge .checkylesspaddle2
    				
    				popa
    				
    				jmp .whatmove
    				
    				.checkylesspaddle2:
    				
    					mov byte al, [paddle2_ypos]
    					add byte al, [paddle2_hsize]
    					cmp byte [ball_ypos], al
    					jle .collidetopaddle2
    					
    					popa
    					
    					jmp .whatmove
    					
    					.collidetopaddle2:
    					
    						mov byte [ball_xdir], 0
    						
    						inc word [score_p2]
    						
    						popa
    						
    						jmp .whatmove
    	
    		.whatmove:
    		
    			cmp byte [ball_xdir], 0
	    		je .moveleft
	    		
	    		cmp byte [ball_xdir], 1
	    		je .moveright
    		
    		.moveleft:
    		
    			sub byte [ball_xpos], 1
    			
    			cmp byte [ball_ydir], 0
	    		je .movedown1
	    		
	    		cmp byte [ball_ydir], 1
	    		je .moveup1
	    		
	    		.movedown1:
	    		
	    			add byte [ball_ypos], 1
	    			
	    			jmp .drawball
	    			
	    		.moveup1:
	    		
	    			sub byte [ball_ypos], 1

    			jmp .drawball
    			
    		.moveright:
    		
    			add byte [ball_xpos], 1

    			cmp byte [ball_ydir], 0
	    		je .movedown2
	    		
	    		cmp byte [ball_ydir], 1
	    		je .moveup2
	    		
	    		.movedown2:
	    		
	    			add byte [ball_ypos], 1
	    			
	    			jmp .drawball
	    			
	    		.moveup2:
	    		
	    			sub byte [ball_ypos], 1

    	.drawball:
			
			mov byte cl, [ball_xpos]
	    	mov byte ch, [ball_ypos]
	    	mov dl, 1
	    	mov dh, 1
	    	mov bl, [color_redwhite]
	    	call drawbox
	    
	    cmp byte [game_time_delay], 50
	    jge .updategametime
	    
	    jmp .refresh
	    
	    .updategametime:
	    
	    	mov byte [game_time_delay], 0
	    
	    	inc word [game_time]		; -- update game time
	    	
	    .refresh:
	    
		    cmp byte [start_game], 1
		    je .background
	    
    .keywait:
    
    	call keypress
    	
    	cmp byte al, [key_escape]
    	je main.background
    	
    	cmp byte al, [key_space]
    	je .startgame
    	
    	cmp byte al, [key_w]
    	je .movepaddleup
    	
    	cmp byte al, [key_s]
    	je .movepaddledown
    	
    	cmp byte al, [key_i]
    	je .movepaddle2up
    	
    	cmp byte al, [key_k]
    	je .movepaddle2down
    	
    	jmp .background
    	
    .startgame:
    
    	mov byte [start_game], 1
    	
    	jmp .background
    	
    .movepaddleup:
    
    	cmp byte [paddle1_ypos], 0
    	je .background
    
    	dec byte [paddle1_ypos]
    
    	jmp .background
    	
    .movepaddledown:
    
    	cmp byte [paddle1_ypos], 21
    	je .background
    
    	inc byte [paddle1_ypos]
    
    	jmp .background
    	
    .movepaddle2up:
    
    	cmp byte [paddle2_ypos], 0
    	je .background
    
    	dec byte [paddle2_ypos]
    
    	jmp .background
    	
    .movepaddle2down:
    
    	cmp byte [paddle2_ypos], 21
    	je .background
    
    	inc byte [paddle2_ypos]
    
    	jmp .background

exit:

    mov dx, 0
    call movecursor
    
    mov cx, 2000
    mov bl, [color_blacklgray]
    call clearbackground
    
    int 20h


win:
	
	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, [color_blackwhite]
	call clearbackground
	
	; -- compare scores
	
	mov word ax, [score_p1]
	cmp word [score_p2], ax
	jg .player2win
	
	mov word ax, [score_p2]
	cmp word [score_p1], ax
	jg .player1win
	
	jmp .playertie
	
	.player2win:
	
		mov dh, 3
		mov dl, 33
		call movecursor
		
		mov si, win_player2
		call println
		
		add dh, 6
		
		mov dl, 37
		call movecursor
		
		mov si, score_p2_text
		call println
		
		mov ax, [score_p2]
		call tostring
		mov si, ax
		call println
		
		add dh, 9
		
		mov dl, 24
		call movecursor
		
		mov si, .anykey
		call println
		
		.keywait2:
		
			call keypress
			
			cmp al, 0
			jne main.background
			
			jmp .keywait2
	
	.player1win:
	
		mov dh, 3
		mov dl, 33
		call movecursor
		
		mov si, win_player1
		call println
		
		add dh, 6
		
		mov dl, 37
		call movecursor
		
		mov si, score_p1_text
		call println
		
		mov ax, [score_p1]
		call tostring
		mov si, ax
		call println
		
		add dh, 9
		
		mov dl, 24
		call movecursor
		
		mov si, .anykey
		call println
		
		.keywait1:
		
			call keypress
			
			cmp al, 0
			jne main.background
			
			jmp .keywait1
	
	.playertie:
	
		mov dh, 3
		mov dl, 35
		call movecursor
		
		mov si, win_tie
		call println
		
		add dh, 6
		
		mov dl, 37
		call movecursor
		
		mov si, score_p1_text
		call println
		
		mov ax, [score_p1]
		call tostring
		mov si, ax
		call println
		
		add dh, 9
		
		mov dl, 24
		call movecursor
		
		mov si, .anykey
		call println
		
		.keywait3:
		
			call keypress
			
			cmp al, 0
			jne main.background
			
			jmp .keywait3
	
	.anykey		db "Press any key to go to main menu.", 0




; input:		cx = number of scans
;				bl = color
; output:		none
clearbackground:

	pusha

	mov ah, 09h
	mov bh, 0
	mov al, ' '
	int 10h

	popa

	ret

; input:		si = string to print
; output:		none
println:

	pusha

	mov ah, 0Eh

	.loop:

		lodsb	; -- load SI to AL
		int 10h

		cmp al, 0
		jne .loop

	popa

	ret

; input:		dh:dl = x & y position
; output:		none
movecursor:

	push ax
	push bx

	mov ah, 2
	mov bh, 0
	int 10h

	pop bx
	pop ax

	ret

; output:		al = key pressed
; input:		none
keypress:

	mov ah, 00h
	int 16h

	ret

; input:		cx = delay in microseconds
; output:		none
sleep:

	pusha

	mov ah, 86h
	int 15h

	popa

	ret

; output:		al = returns 255 if key is pressed
; input:		none
checkkey:

	mov ah, 0Bh
	int 21h

	ret

; output:		none
; input:		none
cursorhide:

	pusha

	mov ah, 1
	mov ch, 36
	int 10h

	popa

	ret

; output:		none
; input:		none
cursorshow:

	pusha

	mov ah, 1
	mov ch, 6
	mov cl, 7
	int 10h

	popa

	ret

; input:		ax = number (word)
; output:		ax = string
tostring:

	pusha
	
	mov cx, 0
	mov bx, 10
	mov di, .string
	
	.pushh:
	
		mov dx, 0
		div bx
		inc cx
		push dx
		test ax, ax
		jnz .pushh
		
	.popp:
	
		pop dx
		add dl, '0'
		mov [di], dl
		inc di
		dec cx
		jnz .popp
	
	mov byte [di], 0
	
	popa
	
	mov ax, .string

	ret
	
	.string	times 8 db 0

; input:        none
; output:       none
initrandomseed:

    push ax
    push bx
    
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
	mov word [seed], bx	; Seed will be something like 0x4435 (if it were 44 minutes and 35 seconds after the hour)
    
    pop bx
    pop ax
    
    ret

; input:        ax = from
;               bx = to
; output:       cx = random number
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
		mov ax, [seed]
		mov dx, 23167
		mul dx				; DX:AX = AX * DX
		add ax, 12409
		adc dx, 0
		mov [seed], ax
	 	pop dx

; input:		cl:ch = x & y position
;				dl:dh = w & h size
;				bl = color
; output:		none
drawbox:

	pusha

	cmp dl, 1
	jl .done

	cmp dh, 1
	jl .done

	mov byte [.position], cl
	mov byte [.position+1], ch
	mov byte [.size], dl
	mov byte [.size+1], dh

	mov dx, 0
	mov cx, 0

	mov byte dl, [.position]
	mov byte dh, [.position+1]
	call movecursor
	
	mov byte cl, [.size+1]

	.height:

		push cx
		push dx

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

		pop dx
		pop cx

		dec cl

		mov byte dl, [.position]
		inc dh
		call movecursor

		cmp cl, 0
		jne .height

	.done:

		popa
	
		ret

	.position	db 0,0
	.size		db 0,0
	.color		dw 0
