

bits 16
org 100h

section .data

	color_whiteblack		dw 0F0h
	color_cyanwhite			dw 03Fh
	color_blacklgray		dw 007h
	color_greenwhite		dw 02Fh
	color_yellowblack		dw 0E0h
	key_escape				db 27
	key_space				db 32
	key_enter				db 13
	button_start			db "   Start   ", 0
	button_exit				db "    Exit    ", 0
	seed                    dw 0				; used for randomization
	option_selected			db 0
    menu_selected           db 0				; 
    menu_text               db "Select Mode", 0
    mode_single             db "   Single   ", 0
    mode_2player            db "  2 Player  ", 0
    game_title				db "TOOTACTICS!", 0
    game_timer				dw 5				; game timer,
    											; on single player: 5s -> 3x3, 3s -> 4x4, 2s -> 5x5
    											; on 2 players: no timer.
    board_array_3b3			db  9 dup(0)		; array for 3x3 grid
    board_array_4b4			db 16 dup(0)		; array for 4x4 grid
    board_array_5b5			db 25 dup(0)		; array for 5x5 grid
    symbols					db 79,88,3,2,42,6,0	; Circle, Cross, Heart, Smile, Star, Spade
    symbol_player1			db 79				; stores the symbol that player choses
    symbol_player2			db 88				; stores the symbol that player choses
    level_count				db 0				; 0 = level 1, 1 = level 2, 2 = level 3
    cursor_position			db 0,0				; [0] = x, [1] = y coordinate
    cursor_position2		dw 0				; cursor coordinate in 1-dimensional
    name_ai					db "Robot", 0		; name of the AI (for single player)
    name_player1			times 7 db 0
    name_player2			times 7 db 0
    askforname1				db "Player 1: What is your name?", 0
    askforname2				db "Player 2: What is your name?", 0
    label_player1			db "Player 1", 0
    label_player2			db "Player 2", 0
    label_yourturn			db "Player 1's turn", 0
    label_robotsturn		db "Player 2's turn", 0
    input_done				db 0				; boolean if the name input is done
    player_turn				db 1				; boolean for turn over
	sym_title				db "[ Select A Symbol ]", 0
	sym_name1				db "  Circle  ", 0
	sym_name2				db "  Cross  ", 0
	sym_name3				db "  Heart  ", 0
	sym_name4				db "  Smiley  ", 0
	sym_name5				db "  Star  ", 0
	sym_name6				db "  Spade  ", 0
	sym_selected			dw 0
	timer_text				db "Timer: ", 0
	timer_delay				db 0
	score_player1			dw 0
	score_player2			dw 0
	win_player1				db 0
	win_player2				db 0
	score_1					db 0		; score counter for player 1
	score_2					db 0		; score counter for player 2
	scan_rep				db 0		; scans for illegal moves
	is2pmode				db 0		; determines if we're in 2 player mode

section .text

start:

	mov ah, 00h
	mov al, 03h
	int 10h

	mov ax, 1003h
	mov bx, 0
	int 10h		; enable bright colors
	
	mov byte [option_selected], 0
	
	.mainbg:
	
		call cursorhide

		mov dx, 0
		call movecursor

		mov cx, 2000
		mov bl, [color_cyanwhite]
		call clearbackground
		
		mov ch, 1
		mov cl, 26
		mov bl, [color_whiteblack]
		call drawgametitle
	
	.button:

		mov ch, 16
		mov cl, 26
		mov dl, 11
		mov dh, 5
		mov bh, [color_greenwhite]
		mov bl, [color_yellowblack]
		call drawboxborder

		mov dh, 18
		mov dl, 26
		call movecursor

		mov si, button_start
		call println

		mov ch, 16
		mov cl, 43
		mov dl, 12
		mov dh, 5
		mov bh, [color_greenwhite]
		mov bl, [color_yellowblack]
		call drawboxborder

		mov dh, 18
		mov dl, 43
		call movecursor

		mov si, button_exit
		call println

		cmp byte [option_selected], 0
		je .selectfirst

		jmp .selectsecond

		.selectfirst:
	
			mov dl, 26
			mov cx, 11

			jmp .drawselector

		.selectsecond:

			mov dl, 43
			mov cx, 12

		.drawselector:
		
			mov dh, 22
			call movecursor
		
			mov bl, [color_yellowblack]
			call clearbackground

	.keywait:

		call keypress

		cmp byte al, [key_escape]
		je exit

		cmp byte al, [key_space]
		je .select

		cmp byte al, [key_enter]
		je .whatisit

		jmp .keywait

	.select:

		xor byte [option_selected], 1

		jmp .mainbg

	.whatisit:

		cmp byte [option_selected], 0
		je menu
		cmp byte [option_selected], 1
		je exit

		jmp .keywait

menu:

    .background:
    
        mov dx, 0
        call movecursor
    
        mov cx, 2000
        mov bl, [color_cyanwhite]
        call clearbackground
        
        mov dh, 7
        mov dl, 35
        call movecursor
        
        mov si, menu_text
        call println
    
    .button:
    
        mov cl, 25
        mov ch, 12
        mov dl, 13
        mov dh, 5
        mov bl, [color_yellowblack]
        mov bh, [color_greenwhite]
        call drawboxborder
        
        mov dh, 14
        mov dl, 25
        call movecursor
        
        mov si, mode_single
        call println
        
        mov cl, 43
        mov ch, 12
        mov dl, 13
        mov dh, 5
        mov bl, [color_yellowblack]
        mov bh, [color_greenwhite]
        call drawboxborder
        
        mov dh, 14
        mov dl, 43
        call movecursor
        
        mov si, mode_2player
        call println
        
        .selector:
        
            cmp byte [menu_selected], 0
            je .selectfirst
            
            jmp .selectsecond
            
            .selectfirst:
            
                mov dl, 25
                
                jmp .draw
                
            .selectsecond:
            
                mov dl, 43
            
            .draw:
            
                mov dh, 18
                call movecursor
                
                mov cx, 13
                call clearbackground
    
    .keywait:
    
        call keypress
        
        cmp byte al, [key_escape]
        je exit
        
        cmp byte al, [key_space]
        je .select
        
        cmp byte al, [key_enter]
        je .confirm
    
        jmp .keywait
        
    .select:
    
        xor byte [menu_selected], 1
    
        jmp .background
        
    .confirm:
    
        cmp byte [menu_selected], 0
        je playsingle
        
        jmp play2player

playsingle:

	call initrandomseed

	mov byte [symbol_player1], 79
	mov byte [symbol_player2], 88
	mov byte [input_done], 0
	mov byte [player_turn], 1		; start with player 1
	mov word [game_timer], 5		; start at easy mode
	mov byte [score_1], 0
	mov byte [score_2], 0
	mov byte [is2pmode], 0
	
	; clear all player names array (at start)
	
	mov cx, 7
	mov bx, 0
	.clearnames:
		mov byte [name_player2+bx], 0
		mov byte [name_player1+bx], 0
		inc bx
		loop .clearnames
	
	; clear all board arrays
	
	mov cx, 9
	mov bx, 0
	.cb1:
		mov byte [board_array_3b3+bx], 0
		inc bx
		loop .cb1
	
	mov cx, 16
	mov bx, 0
	.cb2:
		mov byte [board_array_4b4+bx], 0
		inc bx
		loop .cb2
	
	mov cx, 25
	mov bx, 0
	.cb3:
		mov byte [board_array_5b5+bx], 0
		inc bx
		loop .cb3

	.selectsymbol:
	
		mov dx, 0
		call movecursor
		
		mov cx, 2000
		mov bl, [color_cyanwhite]
		call clearbackground
		
		mov dl, 30
		mov dh, 5
		call movecursor
		
		mov si, sym_title
		call println
		
		.buttons:
		
			mov cl, 17
			mov ch, 9
			mov dl, 10
			mov dh, 3
			mov bl, [color_greenwhite]
			mov bh, [color_yellowblack]
			call drawboxborder
			
			mov dl, 17
			mov dh, 10
			call movecursor
			
			mov si, sym_name1
			call println					; Circle shape button
			
			mov cl, 29
			mov ch, 9
			mov dl, 10
			mov dh, 3
			mov bl, [color_greenwhite]
			mov bh, [color_yellowblack]
			call drawboxborder
			
			mov dl, 29
			mov dh, 10
			call movecursor
			
			mov si, sym_name2
			call println					; Cross shape button
			
			mov cl, 41
			mov ch, 9
			mov dl, 10
			mov dh, 3
			mov bl, [color_greenwhite]
			mov bh, [color_yellowblack]
			call drawboxborder
			
			mov dl, 41
			mov dh, 10
			call movecursor
			
			mov si, sym_name3
			call println					; Heart shape button
			
			mov cl, 53
			mov ch, 9
			mov dl, 10
			mov dh, 3
			mov bl, [color_greenwhite]
			mov bh, [color_yellowblack]
			call drawboxborder
			
			mov dl, 53
			mov dh, 10
			call movecursor
			
			mov si, sym_name4
			call println					; Smiley shape button
			
			mov cl, 29
			mov ch, 15
			mov dl, 10
			mov dh, 3
			mov bl, [color_greenwhite]
			mov bh, [color_yellowblack]
			call drawboxborder
			
			mov dl, 29
			mov dh, 16
			call movecursor
			
			mov si, sym_name5
			call println					; Star shape button
			
			mov cl, 41
			mov ch, 15
			mov dl, 10
			mov dh, 3
			mov bl, [color_greenwhite]
			mov bh, [color_yellowblack]
			call drawboxborder
			
			mov dl, 41
			mov dh, 16
			call movecursor
			
			mov si, sym_name6
			call println					; Spade shape button
		
		.selector:
		
			cmp word [sym_selected], 0
			je .selectcircle
			
			cmp word [sym_selected], 1
			je .selectcross
			
			cmp word [sym_selected], 2
			je .selectheart
			
			cmp word [sym_selected], 3
			je .selectsmiley
			
			cmp word [sym_selected], 4
			je .selectstar
			
			cmp word [sym_selected], 5
			je .selectspade
			
			.selectcircle:
			
				mov dl, 17
				mov dh, 13
				call movecursor
				
				jmp .drawselector
				
			.selectcross:
			
				mov dl, 29
				mov dh, 13
				call movecursor
				
				jmp .drawselector
			
			.selectheart:
			
				mov dl, 41
				mov dh, 13
				call movecursor
				
				jmp .drawselector
			
			.selectsmiley:
			
				mov dl, 53
				mov dh, 13
				call movecursor
				
				jmp .drawselector
			
			.selectstar:
			
				mov dl, 29
				mov dh, 19
				call movecursor
				
				jmp .drawselector
			
			.selectspade:
			
				mov dl, 41
				mov dh, 19
				call movecursor
				
				jmp .drawselector
			
			.drawselector:
			
				mov cx, 10
				mov bl, [color_yellowblack]
				call clearbackground
		
			.waitforkey:
			
				call keypress
				
				cmp al, ','
				je .selecttoleft
				
				cmp al, '.'
				je .selecttoright
				
				cmp byte al, [key_enter]
				je .confirmsymbol
			
				jmp .waitforkey
				
			.selecttoleft:
			
				cmp word [sym_selected], 0
				jg .decselector
				
				jmp .waitforkey
				
				.decselector:
				
					dec word [sym_selected]
					
					jmp .selectsymbol
			
			.selecttoright:
			
				cmp word [sym_selected], 5
				jl .incselector
				
				jmp .waitforkey
				
				.incselector:
				
					inc word [sym_selected]
					
					jmp .selectsymbol
					
			.confirmsymbol:
			
				mov word bx, [sym_selected]
				mov byte al, [symbols + bx]
				mov byte [symbol_player1], al
				
				jmp .title
			
	; -------------------------------------------------------------------------

    .title:
    
		mov dx, 0
		call movecursor
		
		mov cx, 80
		mov bl, [color_cyanwhite]
		call clearbackground
		
		mov dl, 2
		call movecursor
		
		mov si, game_title
		call println
	
	.background:
	
		mov dh, 1
		mov dl, 0
		call movecursor
		
		mov cx, 5
		
		.curtain:
		
			push cx
			
			mov cx, 2
			call sleep
			
			mov cx, 400
			mov bl, [color_yellowblack]
			call clearbackground
		
			pop cx
			
			add dh, 5
			call movecursor
		
			loop .curtain
		
		mov cx, 1
		call sleep
		
		cmp byte [input_done], 0
		jne .printnames
	
	.askforname:
	
		call cursorshow
	
		mov cl, 21
		mov ch, 10
		mov si, askforname1
		call drawinputbox
		
		mov si, ax
		mov bx, 0
		
		.copyname:
			lodsb
			mov byte [name_player1 + bx], al
			inc bx
			cmp al, 0
			jne .copyname
		
		mov byte [input_done], 1
		
		jmp .title
	
	.printnames:
	
		call cursorhide
		
		mov cl, 7
		mov ch, 7
		mov dl, 12
		mov dh, 8
		mov bl, [color_cyanwhite]
		call drawbox
		
		mov cl, 59
		mov ch, 7
		mov dl, 12
		mov dh, 8
		mov bl, [color_cyanwhite]
		call drawbox
		
		mov dl, 9
		mov dh, 8
		call movecursor
		
		mov si, label_player1
		call println
	
		mov dl, 9
		mov dh, 10
		call movecursor
		
		mov si, name_player1
		call println
		
		add dh, 3
		add dl, 1
		call movecursor
		
		mov cx, 3
		
		.print1sym:
		
			push cx
			
			mov ah, 0Ah
			mov byte al, [symbol_player1]
			mov bh, 0
			mov cx, 1
			int 10h
			
			pop cx
			
			add dl, 2
			call movecursor
			
			loop .print1sym
		
		mov dl, 61
		mov dh, 8
		call movecursor
		
		mov si, label_player2
		call println
		
		mov dl, 61
		mov dh, 10
		call movecursor
		
		mov si, name_ai
		call println
		
		add dh, 3
		add dl, 1
		call movecursor
		
		mov cx, 3
		
		.print2sym:
		
			push cx
			
			mov ah, 0Ah
			mov byte al, [symbol_player2]
			mov bh, 0
			mov cx, 1
			int 10h
			
			pop cx
			
			add dl, 2
			call movecursor
			
			loop .print2sym
	
	.startgame:
	
		mov word [cursor_position2], 0
	
		cmp byte [level_count], 0
		je .level1
		
		cmp byte [level_count], 1
		je .level2
		
		cmp byte [level_count], 2
		je .level3
		
		jmp finalizechecking			; if all levels are finished, we can now finalize whos the winner...
										; by comparing score of player 1 and 2 if the player 1 has greater score then,
										; player 1 is the winner otherwise its player 2...
	
		.level1:
		
			mov cl, 34
			mov ch, 8
			mov dl, 11
			mov dh, 9
			mov bl, [color_greenwhite]
			mov bh, [color_whiteblack]
			call drawboxborder
			
			mov byte [cursor_position], 37
			mov byte [cursor_position+1], 10
			
			jmp .drawcursor
			
		.level2:
		
			mov cl, 33
			mov ch, 7
			mov dl, 13
			mov dh, 11
			mov bl, [color_greenwhite]
			mov bh, [color_whiteblack]
			call drawboxborder
			
			mov byte [cursor_position], 36
			mov byte [cursor_position+1], 9
		
			jmp .drawcursor
			
		.level3:
		
			mov cl, 32
			mov ch, 6
			mov dl, 15
			mov dh, 13
			mov bl, [color_greenwhite]
			mov bh, [color_whiteblack]
			call drawboxborder
			
			mov byte [cursor_position], 35
			mov byte [cursor_position+1], 8
	
		.drawcursor:
		
			nop
	
	.drawturn:
	
		cmp byte [player_turn], 0
		jne .tellitsyourturn
		
		jmp .robotsturn
		
		.tellitsyourturn:
			
			; player 1's turn
			
			mov dl, 33
			mov dh, 22
			call movecursor
			
			mov si, label_yourturn
			call println
			
			mov byte dl, [cursor_position]
			mov byte dh, [cursor_position+1]
			call movecursor
				
			call cursorshow
			
			jmp .done
			
		.robotsturn:
		
			; ai's turn
		
			mov dl, 33
			mov dh, 22
			call movecursor
			
			mov si, label_robotsturn
			call println
			
			mov cx, 10
			call sleep
			
			.calculaterandomness:
			
				; AI calculations (its calculations performed randomly)
				; it only places the symbol where it is vacant (preventing to place it on top of the player or itself)
				
				cmp byte [level_count], 0
				je .goforlvl1
				cmp byte [level_count], 1
				je .goforlvl2
				cmp byte [level_count], 2
				je .goforlvl3
				
				jmp .contmovecursor
				
				.goforlvl1:
				
					mov ax, 1
					mov bx, 9
					call randomrange
				
					cmp cx, 1
					je .row1col1
					cmp cx, 2
					je .row1col2
					cmp cx, 3
					je .row1col3
					cmp cx, 4
					je .row2col1
					cmp cx, 5
					je .row2col2
					cmp cx, 6
					je .row2col3
					cmp cx, 7
					je .row3col1
					cmp cx, 8
					je .row3col2
					cmp cx, 9
					je .row3col3
					
					jmp .contmovecursor
					
					.row1col1:
					
						cmp byte [board_array_3b3], 0
						jne .row1col2
					
						mov dl, 37
						mov dh, 10
						
						mov byte al, [symbol_player2]
						mov byte [board_array_3b3], al
						
						jmp .moveai
						
					.row1col2:
					
						cmp byte [board_array_3b3+1], 0
						jne .row1col3
					
						mov dl, 37
						mov dh, 10
					
						add dl, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_3b3+1], al
						
						jmp .moveai
						
					.row1col3:
					
						cmp byte [board_array_3b3+2], 0
						jne .row2col1
					
						mov dl, 37
						mov dh, 10
					
						add dl, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_3b3+2], al
						
						jmp .moveai
						
					.row2col1:
					
						cmp byte [board_array_3b3+3], 0
						jne .row2col2
					
						mov dl, 37
						mov dh, 10
					
						add dh, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_3b3+3], al
						
						jmp .moveai
						
					.row2col2:
					
						cmp byte [board_array_3b3+4], 0
						jne .row2col3
						
						mov dl, 37
						mov dh, 10
					
						add dh, 2
						add dl, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_3b3+4], al
						
						jmp .moveai
						
					.row2col3:
						
						cmp byte [board_array_3b3+5], 0
						jne .row3col1
					
						mov dl, 37
						mov dh, 10
					
						add dl, 4
						add dh, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_3b3+5], al
						
						jmp .moveai
						
					.row3col1:
					
						cmp byte [board_array_3b3+6], 0
						jne .row3col2
					
						mov dl, 37
						mov dh, 10
					
						add dh, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_3b3+6], al
						
						jmp .moveai
						
					.row3col2:
					
						cmp byte [board_array_3b3+7], 0
						jne .row3col3
					
						mov dl, 37
						mov dh, 10
					
						add dl, 2
						add dh, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_3b3+7], al
						
						jmp .moveai
						
					.row3col3:
					
						cmp byte [board_array_3b3+8], 0
						je .controw3col3
						
						cmp byte [scan_rep], 1
						je .contmovecursor
					
						inc byte [scan_rep]
						
						jmp .row1col1
						
						.controw3col3:
							
							mov dl, 37
							mov dh, 10
						
							add dl, 4
							add dh, 4
							
							mov byte al, [symbol_player2]
							mov byte [board_array_3b3+8], al
							
							jmp .moveai
						
				.goforlvl2:
				
					mov ax, 1
					mov bx, 16
					call randomrange
					
					cmp cx, 1
					je .row1col1_2
					cmp cx, 2
					je .row1col2_2
					cmp cx, 3
					je .row1col3_2
					cmp cx, 4
					je .row1col4_2
					cmp cx, 5
					je .row2col1_2
					cmp cx, 6
					je .row2col2_2
					cmp cx, 7
					je .row2col3_2
					cmp cx, 8
					je .row2col4_2
					cmp cx, 9
					je .row3col1_2
					cmp cx, 10
					je .row3col2_2
					cmp cx, 11
					je .row3col3_2
					cmp cx, 12
					je .row3col4_2
					cmp cx, 13
					je .row4col1_2
					cmp cx, 14
					je .row4col2_2
					cmp cx, 15
					je .row4col3_2
					cmp cx, 16
					je .row4col4_2
					
					jmp .contmovecursor
					
					.row1col1_2:
					
						cmp byte [board_array_4b4], 0
						jne .row1col2_2
					
						mov dl, 36
						mov dh, 9
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4], al
						
						jmp .moveai
						
					.row1col2_2:
					
						cmp byte [board_array_4b4+1], 0
						jne .row1col3_2
					
						mov dl, 36
						mov dh, 9
					
						add dl, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+1], al
						
						jmp .moveai
						
					.row1col3_2:
					
						cmp byte [board_array_4b4+2], 0
						jne .row1col4_2
					
						mov dl, 36
						mov dh, 9
					
						add dl, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+2], al
						
						jmp .moveai
						
					.row1col4_2:
					
						cmp byte [board_array_4b4+3], 0
						jne .row2col1_2
					
						mov dl, 36
						mov dh, 9
					
						add dl, 6
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+3], al
						
						jmp .moveai
						
					.row2col1_2:
					
						cmp byte [board_array_4b4+4], 0
						jne .row2col2_2
					
						mov dl, 36
						mov dh, 9
					
						add dh, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+4], al
						
						jmp .moveai
						
					.row2col2_2:
					
						cmp byte [board_array_4b4+5], 0
						jne .row2col3_2
					
						mov dl, 36
						mov dh, 9
					
						add dh, 2
						add dl, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+5], al
						
						jmp .moveai
						
					.row2col3_2:
					
						cmp byte [board_array_4b4+6], 0
						jne .row2col4_2
					
						mov dl, 36
						mov dh, 9
					
						add dh, 2
						add dl, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+6], al
						
						jmp .moveai
						
					.row2col4_2:
					
						cmp byte [board_array_4b4+7], 0
						jne .row3col1_2
					
						mov dl, 36
						mov dh, 9
					
						add dh, 2
						add dl, 6
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+7], al
						
						jmp .moveai
						
					.row3col1_2:
					
						cmp byte [board_array_4b4+8], 0
						jne .row3col2_2
					
						mov dl, 36
						mov dh, 9
					
						add dh, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+8], al
						
						jmp .moveai
						
					.row3col2_2:
					
						cmp byte [board_array_4b4+9], 0
						jne .row3col3_2
					
						mov dl, 36
						mov dh, 9
					
						add dh, 4
						add dl, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+9], al
						
						jmp .moveai
						
					.row3col3_2:
					
						cmp byte [board_array_4b4+10], 0
						jne .row3col4_2
					
						mov dl, 36
						mov dh, 9
					
						add dh, 4
						add dl, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+10], al
						
						jmp .moveai
						
					.row3col4_2:
					
						cmp byte [board_array_4b4+11], 0
						jne .row4col1_2
					
						mov dl, 36
						mov dh, 9
					
						add dh, 4
						add dl, 6
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+11], al
						
						jmp .moveai
						
					.row4col1_2:
					
						cmp byte [board_array_4b4+12], 0
						jne .row4col2_2
					
						mov dl, 36
						mov dh, 9
					
						add dh, 6
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+12], al
						
						jmp .moveai
						
					.row4col2_2:
					
						cmp byte [board_array_4b4+13], 0
						jne .row4col3_2
					
						mov dl, 36
						mov dh, 9
					
						add dh, 6
						add dl, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+13], al
						
						jmp .moveai
						
					.row4col3_2:
					
						cmp byte [board_array_4b4+14], 0
						jne .row4col4_2
					
						mov dl, 36
						mov dh, 9
					
						add dh, 6
						add dl, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_4b4+14], al
						
						jmp .moveai
						
					.row4col4_2:
					
						cmp byte [board_array_4b4+15], 0
						je .controw4col4_2
						
						cmp byte [scan_rep], 0
						jne .contmovecursor
						
						inc byte [scan_rep]
						
						jmp .row1col1_2
						
						.controw4col4_2:
							
							mov dl, 36
							mov dh, 9
						
							add dh, 6
							add dl, 6
							
							mov byte al, [symbol_player2]
							mov byte [board_array_4b4+15], al
							
							jmp .moveai
							
				.goforlvl3:
				
					mov ax, 1
					mov bx, 25
					call randomrange
					
					cmp cx, 1
					je .row1col1_3
					cmp cx, 2
					je .row1col2_3
					cmp cx, 3
					je .row1col3_3
					cmp cx, 4
					je .row1col4_3
					cmp cx, 5
					je .row1col5_3
					cmp cx, 6
					je .row2col1_3
					cmp cx, 7
					je .row2col2_3
					cmp cx, 8
					je .row2col3_3
					cmp cx, 9
					je .row2col4_3
					cmp cx, 10
					je .row2col5_3
					cmp cx, 11
					je .row3col1_3
					cmp cx, 12
					je .row3col2_3
					cmp cx, 13
					je .row3col3_3
					cmp cx, 14
					je .row3col4_3
					cmp cx, 15
					je .row3col5_3
					cmp cx, 16
					je .row4col1_3
					cmp cx, 17
					je .row4col2_3
					cmp cx, 18
					je .row4col3_3
					cmp cx, 19
					je .row4col4_3
					cmp cx, 20
					je .row4col5_3
					cmp cx, 21
					je .row5col1_3
					cmp cx, 22
					je .row5col2_3
					cmp cx, 23
					je .row5col3_3
					cmp cx, 24
					je .row5col4_3
					cmp cx, 25
					je .row5col5_3
					
					jmp .contmovecursor
					
					.row1col1_3:
					
						cmp byte [board_array_5b5], 0
						jne .row1col2_3
					
						mov dl, 35
						mov dh, 8
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5], al
						
						jmp .moveai
						
					.row1col2_3:
					
						cmp byte [board_array_5b5+1], 0
						jne .row1col3_3
					
						mov dl, 35
						mov dh, 8
						add dl, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+1], al
						
						jmp .moveai
						
					.row1col3_3:
					
						cmp byte [board_array_5b5+2], 0
						jne .row1col4_3
					
						mov dl, 35
						mov dh, 8
						add dl, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+2], al
						
						jmp .moveai
						
					.row1col4_3:
					
						cmp byte [board_array_5b5+3], 0
						jne .row1col5_3
					
						mov dl, 35
						mov dh, 8
						add dl, 6
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+3], al
						
						jmp .moveai
						
					.row1col5_3:
					
						cmp byte [board_array_5b5+4], 0
						jne .row2col1_3
					
						mov dl, 35
						mov dh, 8
						add dl, 8
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+4], al
						
						jmp .moveai
						
					.row2col1_3:
					
						cmp byte [board_array_5b5+5], 0
						jne .row2col2_3
					
						mov dl, 35
						mov dh, 8
						add dh, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+5], al
						
						jmp .moveai
						
					.row2col2_3:
					
						cmp byte [board_array_5b5+6], 0
						jne .row2col3_3
					
						mov dl, 35
						mov dh, 8
						add dh, 2
						add dl, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+6], al
						
						jmp .moveai
						
					.row2col3_3:
					
						cmp byte [board_array_5b5+7], 0
						jne .row2col4_3
					
						mov dl, 35
						mov dh, 8
						add dh, 2
						add dl, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+7], al
						
						jmp .moveai
						
					.row2col4_3:
					
						cmp byte [board_array_5b5+8], 0
						jne .row2col5_3
					
						mov dl, 35
						mov dh, 8
						add dh, 2
						add dl, 6
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+8], al
						
						jmp .moveai
						
					.row2col5_3:
					
						cmp byte [board_array_5b5+9], 0
						jne .row3col1_3
					
						mov dl, 35
						mov dh, 8
						add dh, 2
						add dl, 8
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+9], al
						
						jmp .moveai
						
					.row3col1_3:
					
						cmp byte [board_array_5b5+10], 0
						jne .row3col2_3
					
						mov dl, 35
						mov dh, 8
						add dh, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+10], al
						
						jmp .moveai
						
					.row3col2_3:
					
						cmp byte [board_array_5b5+11], 0
						jne .row3col3_3
					
						mov dl, 35
						mov dh, 8
						add dh, 4
						add dl, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+11], al
						
						jmp .moveai
						
					.row3col3_3:
					
						cmp byte [board_array_5b5+12], 0
						jne .row3col4_3
					
						mov dl, 35
						mov dh, 8
						add dh, 4
						add dl, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+12], al
						
						jmp .moveai
						
					.row3col4_3:
					
						cmp byte [board_array_5b5+13], 0
						jne .row3col5_3
					
						mov dl, 35
						mov dh, 8
						add dh, 4
						add dl, 6
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+13], al
						
						jmp .moveai
						
					.row3col5_3:
					
						cmp byte [board_array_5b5+14], 0
						jne .row4col1_3
					
						mov dl, 35
						mov dh, 8
						add dh, 4
						add dl, 8
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+14], al
						
						jmp .moveai
						
					.row4col1_3:
					
						cmp byte [board_array_5b5+15], 0
						jne .row4col2_3
					
						mov dl, 35
						mov dh, 8
						add dh, 6
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+15], al
						
						jmp .moveai
						
					.row4col2_3:
					
						cmp byte [board_array_5b5+16], 0
						jne .row4col3_3
					
						mov dl, 35
						mov dh, 8
						add dh, 6
						add dl, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+16], al
						
						jmp .moveai
						
					.row4col3_3:
					
						cmp byte [board_array_5b5+17], 0
						jne .row4col4_3
					
						mov dl, 35
						mov dh, 8
						add dh, 6
						add dl, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+17], al
						
						jmp .moveai
						
					.row4col4_3:
					
						cmp byte [board_array_5b5+18], 0
						jne .row4col5_3
					
						mov dl, 35
						mov dh, 8
						add dh, 6
						add dl, 6
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+18], al
						
						jmp .moveai
						
					.row4col5_3:
					
						cmp byte [board_array_5b5+19], 0
						jne .row5col1_3
					
						mov dl, 35
						mov dh, 8
						add dh, 6
						add dl, 8
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+19], al
						
						jmp .moveai
						
					.row5col1_3:
					
						cmp byte [board_array_5b5+20], 0
						jne .row5col2_3
					
						mov dl, 35
						mov dh, 8
						add dh, 8
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+20], al
						
						jmp .moveai
						
					.row5col2_3:
					
						cmp byte [board_array_5b5+21], 0
						jne .row5col3_3
					
						mov dl, 35
						mov dh, 8
						add dh, 8
						add dl, 2
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+21], al
						
						jmp .moveai
						
					.row5col3_3:
					
						cmp byte [board_array_5b5+22], 0
						jne .row5col4_3
					
						mov dl, 35
						mov dh, 8
						add dh, 8
						add dl, 4
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+22], al
						
						jmp .moveai
						
					.row5col4_3:
					
						cmp byte [board_array_5b5+23], 0
						jne .row5col5_3
					
						mov dl, 35
						mov dh, 8
						add dh, 8
						add dl, 6
						
						mov byte al, [symbol_player2]
						mov byte [board_array_5b5+23], al
						
						jmp .moveai
						
					.row5col5_3:
					
						cmp byte [board_array_5b5+24], 0
						je .controw5col5_3
						
						cmp byte [scan_rep], 0
						jne .contmovecursor
						
						inc byte [scan_rep]
						
						jmp .row1col1_3
						
						.controw5col5_3:
							
							mov dl, 35
							mov dh, 8
							add dh, 8
							add dl, 8
							
							mov byte al, [symbol_player2]
							mov byte [board_array_5b5+24], al
							
							jmp .moveai
						
				.moveai:
				
					call movecursor
					
					mov byte al, [symbol_player2]
					mov ah, 0Ah
					mov bh, 0
					mov cx, 1
					int 10h
			
			.contmovecursor:
				
				mov byte [scan_rep], 0
				
				mov byte dl, [cursor_position]
				mov byte dh, [cursor_position+1]
				call movecursor
				
				call cursorshow
				
				mov byte [player_turn], 1
		
		.done:
		
			nop
	
	.timer:
		
		mov cx, 2
		call sleep
		
		call cursorhide
		
		mov dh, 2
		mov dl, 35
		call movecursor
		
		mov si, timer_text
		call println
		
		mov ax, [game_timer]
		call tostring
		mov si, ax
		call println
		
		inc byte [timer_delay]
		
		cmp byte [timer_delay], 20
		je .resettimer
		
		jmp short .contloop
		
		.resettimer:
		
			dec word [game_timer]
			
			mov byte [timer_delay], 0
			
			cmp word [game_timer], 0
			jle checkboard
			
			jmp .contloop
		
		.contloop:
			
			call checkkey
			
			cmp al, 0
			jne .keywait
			
			jmp .drawcursor
	
	.keywait:
	
		call keypress
		
		cmp byte al, [key_escape]
		je start.mainbg
		
		cmp al, 'i'
		je .moveup
		
		cmp al, 'k'
		je .movedown
		
		cmp al, 'j'
		je .moveleft
		
		cmp al, 'l'
		je .moveright
		
		cmp al, 13
		je .placesymbol
	
		jmp .drawcursor
		
	.moveup:
		
		cmp byte [level_count], 0
		je .complvl1
		
		cmp byte [level_count], 1
		je .complvl2
		
		cmp byte [level_count], 2
		je .complvl3
		
		jmp .drawcursor
		
		.complvl1:
		
			cmp byte [cursor_position+1], 10
			jle .drawcursor
			
			sub word [cursor_position2], 3
			
			jmp .ccmup
			
		.complvl2:
		
			cmp byte [cursor_position+1], 9
			jle .drawcursor
			
			sub word [cursor_position2], 4
			
			jmp .ccmup
			
		.complvl3:
		
			cmp byte [cursor_position+1], 8
			jle .drawcursor
			
			sub word [cursor_position2], 5
			
		.ccmup:
		
			dec byte [cursor_position+1]
			dec byte [cursor_position+1]
		
		jmp .drawcursor
	
	.movedown:
	
		cmp byte [level_count], 0
		je .complvl1_2
		
		cmp byte [level_count], 1
		je .complvl2_2
		
		cmp byte [level_count], 2
		je .complvl3_2
		
		jmp .drawcursor
		
		.complvl1_2:
			
			cmp byte [cursor_position+1], 14
			jge .drawcursor
			
			add word [cursor_position2], 3
			
			jmp .ccmup2
			
		.complvl2_2:
		
			cmp byte [cursor_position+1], 15
			jge .drawcursor
			
			add word [cursor_position2], 4
			
			jmp .ccmup2
			
		.complvl3_2:
		
			cmp byte [cursor_position+1], 16
			jge .drawcursor
			
			add word [cursor_position2], 5
		
		.ccmup2:
		
			inc byte [cursor_position+1]
			inc byte [cursor_position+1]
		
		jmp .drawcursor
	
	.moveleft:
		
		cmp byte [level_count], 0
		je .complvl1_3
		
		cmp byte [level_count], 1
		je .complvl2_3
		
		cmp byte [level_count], 2
		je .complvl3_3
		
		jmp .keywait
		
		.complvl1_3:
		
			cmp byte [cursor_position], 37
			jle .drawcursor
			
			jmp .ccmup3
			
		.complvl2_3:
		
			cmp byte [cursor_position], 36
			jle .drawcursor
			
			jmp .ccmup3
			
		.complvl3_3:
		
			cmp byte [cursor_position], 35
			jle .drawcursor
			
		.ccmup3:
		
			dec byte [cursor_position]
			dec byte [cursor_position]
			dec word [cursor_position2]
			
		jmp .drawcursor
	
	.moveright:
	
		cmp byte [level_count], 0
		je .complvl1_4
		
		cmp byte [level_count], 1
		je .complvl2_4
		
		cmp byte [level_count], 2
		je .complvl3_4
		
		jmp .keywait
		
		.complvl1_4:
		
			cmp byte [cursor_position], 41
			jge .drawcursor
			
			jmp .ccmup4
		
		.complvl2_4:
		
			cmp byte [cursor_position], 42
			jge .drawcursor
			
			jmp .ccmup4
			
		.complvl3_4:
		
			cmp byte [cursor_position], 43
			jge .drawcursor
			
		.ccmup4:
		
			inc byte [cursor_position]
			inc byte [cursor_position]
			inc word [cursor_position2]
			
		jmp .drawcursor
		
	.placesymbol:
	
		cmp byte [player_turn], 1
		jne .drawcursor
		
		mov byte dl, [cursor_position]
		mov byte dh, [cursor_position+1]
		call movecursor
		
		; locate where to save
		
		mov bx, [cursor_position2]
		
		cmp byte [level_count], 0
		je .putsymlvl1
		
		cmp byte [level_count], 1
		je .putsymlvl2
		
		cmp byte [level_count], 2
		je .putsymlvl3
		
		.putsymlvl1:
			
			mov byte al, [symbol_player1]
			mov byte [board_array_3b3 + bx], al		; put the symbol
			
			jmp .drawsym
			
		.putsymlvl2:
			
			mov byte al, [symbol_player1]
			mov byte [board_array_4b4 + bx], al		; put the symbol
			
			jmp .drawsym
			
		.putsymlvl3:
			
			mov byte al, [symbol_player1]
			mov byte [board_array_5b5 + bx], al		; put the symbol
			
		.drawsym:
			
			mov ah, 0Ah
			mov bh, 0
			mov cx, 1
			int 10h
			
			mov byte [player_turn], 0
			
			jmp .drawcursor

play2player:

	mov byte [symbol_player1], 79
	mov byte [symbol_player2], 88
	mov byte [input_done], 0
	mov byte [player_turn], 1		; start with player 1
	mov word [game_timer], 5		; start at easy mode
	mov byte [score_1], 0
	mov byte [score_2], 0
	mov byte [is2pmode], 1
	
	; clear all player names array (at start)
	
	mov cx, 7
	mov bx, 0
	.clearnames:
		mov byte [name_player2+bx], 0
		mov byte [name_player1+bx], 0
		inc bx
		loop .clearnames
	
	; clear all board arrays
	
	mov cx, 9
	mov bx, 0
	.cb1:
		mov byte [board_array_3b3+bx], 0
		inc bx
		loop .cb1
	
	mov cx, 16
	mov bx, 0
	.cb2:
		mov byte [board_array_4b4+bx], 0
		inc bx
		loop .cb2
	
	mov cx, 25
	mov bx, 0
	.cb3:
		mov byte [board_array_5b5+bx], 0
		inc bx
		loop .cb3

	choosesym1:
	
		.selectsymbol:
		
			mov dx, 0
			call movecursor
			
			mov cx, 2000
			mov bl, [color_cyanwhite]
			call clearbackground
			
			mov dl, 34
			mov dh, 2
			call movecursor
			
			mov si, .tup
			call println
			
			mov dl, 30
			mov dh, 5
			call movecursor
			
			mov si, sym_title
			call println
			
			.buttons:
			
				mov cl, 17
				mov ch, 9
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 17
				mov dh, 10
				call movecursor
				
				mov si, sym_name1
				call println					; Circle shape button
				
				mov cl, 29
				mov ch, 9
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 29
				mov dh, 10
				call movecursor
				
				mov si, sym_name2
				call println					; Cross shape button
				
				mov cl, 41
				mov ch, 9
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 41
				mov dh, 10
				call movecursor
				
				mov si, sym_name3
				call println					; Heart shape button
				
				mov cl, 53
				mov ch, 9
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 53
				mov dh, 10
				call movecursor
				
				mov si, sym_name4
				call println					; Smiley shape button
				
				mov cl, 29
				mov ch, 15
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 29
				mov dh, 16
				call movecursor
				
				mov si, sym_name5
				call println					; Star shape button
				
				mov cl, 41
				mov ch, 15
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 41
				mov dh, 16
				call movecursor
				
				mov si, sym_name6
				call println					; Spade shape button
			
			.selector:
			
				cmp word [sym_selected], 0
				je .selectcircle
				
				cmp word [sym_selected], 1
				je .selectcross
				
				cmp word [sym_selected], 2
				je .selectheart
				
				cmp word [sym_selected], 3
				je .selectsmiley
				
				cmp word [sym_selected], 4
				je .selectstar
				
				cmp word [sym_selected], 5
				je .selectspade
				
				.selectcircle:
				
					mov dl, 17
					mov dh, 13
					call movecursor
					
					jmp .drawselector
					
				.selectcross:
				
					mov dl, 29
					mov dh, 13
					call movecursor
					
					jmp .drawselector
				
				.selectheart:
				
					mov dl, 41
					mov dh, 13
					call movecursor
					
					jmp .drawselector
				
				.selectsmiley:
				
					mov dl, 53
					mov dh, 13
					call movecursor
					
					jmp .drawselector
				
				.selectstar:
				
					mov dl, 29
					mov dh, 19
					call movecursor
					
					jmp .drawselector
				
				.selectspade:
				
					mov dl, 41
					mov dh, 19
					call movecursor
					
					jmp .drawselector
				
				.drawselector:
				
					mov cx, 10
					mov bl, [color_yellowblack]
					call clearbackground
			
				.waitforkey:
				
					call keypress
					
					cmp al, ','
					je .selecttoleft
					
					cmp al, '.'
					je .selecttoright
					
					cmp byte al, [key_enter]
					je .confirmsymbol
				
					jmp .waitforkey
					
				.selecttoleft:
				
					cmp word [sym_selected], 0
					jg .decselector
					
					jmp .waitforkey
					
					.decselector:
					
						dec word [sym_selected]
						
						jmp .selectsymbol
				 
				.selecttoright:
				
					cmp word [sym_selected], 5
					jl .incselector
					
					jmp .waitforkey
					
					.incselector:
					
						inc word [sym_selected]
						
						jmp .selectsymbol
						
				.confirmsymbol:
				
					mov word bx, [sym_selected]
					mov byte al, [symbols + bx]
					mov byte [symbol_player1], al
					
					jmp choosesym2
				
				.tup	db "For Player 1", 0
	
	choosesym2:
		
		mov byte [sym_selected], 0
	
		.selectsymbol:
		
			mov dx, 0
			call movecursor
			
			mov cx, 2000
			mov bl, [color_cyanwhite]
			call clearbackground
			
			mov dl, 34
			mov dh, 2
			call movecursor
			
			mov si, .tup
			call println
			
			mov dl, 30
			mov dh, 5
			call movecursor
			
			mov si, sym_title
			call println
			
			.buttons:
			
				mov cl, 17
				mov ch, 9
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 17
				mov dh, 10
				call movecursor
				
				mov si, sym_name1
				call println					; Circle shape button
				
				mov cl, 29
				mov ch, 9
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 29
				mov dh, 10
				call movecursor
				
				mov si, sym_name2
				call println					; Cross shape button
				
				mov cl, 41
				mov ch, 9
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 41
				mov dh, 10
				call movecursor
				
				mov si, sym_name3
				call println					; Heart shape button
				
				mov cl, 53
				mov ch, 9
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 53
				mov dh, 10
				call movecursor
				
				mov si, sym_name4
				call println					; Smiley shape button
				
				mov cl, 29
				mov ch, 15
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 29
				mov dh, 16
				call movecursor
				
				mov si, sym_name5
				call println					; Star shape button
				
				mov cl, 41
				mov ch, 15
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 41
				mov dh, 16
				call movecursor
				
				mov si, sym_name6
				call println					; Spade shape button
			
			.selector:
			
				cmp word [sym_selected], 0
				je .selectcircle
				
				cmp word [sym_selected], 1
				je .selectcross
				
				cmp word [sym_selected], 2
				je .selectheart
				
				cmp word [sym_selected], 3
				je .selectsmiley
				
				cmp word [sym_selected], 4
				je .selectstar
				
				cmp word [sym_selected], 5
				je .selectspade
				
				.selectcircle:
				
					mov dl, 17
					mov dh, 13
					call movecursor
					
					jmp .drawselector
					
				.selectcross:
				
					mov dl, 29
					mov dh, 13
					call movecursor
					
					jmp .drawselector
				
				.selectheart:
				
					mov dl, 41
					mov dh, 13
					call movecursor
					
					jmp .drawselector
				
				.selectsmiley:
				
					mov dl, 53
					mov dh, 13
					call movecursor
					
					jmp .drawselector
				
				.selectstar:
				
					mov dl, 29
					mov dh, 19
					call movecursor
					
					jmp .drawselector
				
				.selectspade:
				
					mov dl, 41
					mov dh, 19
					call movecursor
					
					jmp .drawselector
				
				.drawselector:
				
					mov cx, 10
					mov bl, [color_yellowblack]
					call clearbackground
			
				.waitforkey:
				
					call keypress
					
					cmp al, ','
					je .selecttoleft
					
					cmp al, '.'
					je .selecttoright
					
					cmp byte al, [key_enter]
					je .confirmsymbol
				
					jmp .waitforkey
					
				.selecttoleft:
				
					cmp word [sym_selected], 0
					jg .decselector
					
					jmp .waitforkey
					
					.decselector:
					
						dec word [sym_selected]
						
						jmp .selectsymbol
				 
				.selecttoright:
				
					cmp word [sym_selected], 5
					jl .incselector
					
					jmp .waitforkey
					
					.incselector:
					
						inc word [sym_selected]
						
						jmp .selectsymbol
						
				.confirmsymbol:
				
					mov word bx, [sym_selected]
					mov byte al, [symbols + bx]
					mov byte [symbol_player2], al
					
					jmp choosegrid
					
			.tup	db "For Player 2", 0
			
	choosegrid:
	
		mov byte [sym_selected], 0
		
		.selectsize:
		
			mov dx, 0
			call movecursor
			
			mov cx, 2000
			mov bl, [color_cyanwhite]
			call clearbackground
			
			mov dl, 32
			mov dh, 5
			call movecursor
			
			mov si, .title
			call println
			
			.buttons:
			
				mov cl, 21
				mov ch, 11
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 21
				mov dh, 12
				call movecursor
				
				mov si, .s1
				call println					; Circle shape button
				
				mov cl, 35
				mov ch, 11
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 35
				mov dh, 12
				call movecursor
				
				mov si, .s2
				call println					; Cross shape button
				
				mov cl, 49
				mov ch, 11
				mov dl, 10
				mov dh, 3
				mov bl, [color_greenwhite]
				mov bh, [color_yellowblack]
				call drawboxborder
				
				mov dl, 49
				mov dh, 12
				call movecursor
				
				mov si, .s3
				call println					; Heart shape button
			
			.selector:
			
				cmp word [sym_selected], 0
				je .select1
				
				cmp word [sym_selected], 1
				je .select2
				
				cmp word [sym_selected], 2
				je .select3
				
				.select1:
				
					mov dl, 21
					mov dh, 15
					call movecursor
					
					jmp .drawselector
					
				.select2:
				
					mov dl, 35
					mov dh, 15
					call movecursor
					
					jmp .drawselector
				
				.select3:
				
					mov dl, 49
					mov dh, 15
					call movecursor
					
					jmp .drawselector
					
				.drawselector:
				
					mov cx, 10
					mov bl, [color_yellowblack]
					call clearbackground
				
				.waitforkey:
				
					call keypress
					
					cmp al, ','
					je .selecttoleft
					
					cmp al, '.'
					je .selecttoright
					
					cmp byte al, [key_enter]
					je .confirmsymbol
					
					jmp .waitforkey
					
				.selecttoleft:
				
					cmp word [sym_selected], 0
					jle .waitforkey
					
					dec word [sym_selected]
					
					jmp .selectsize
				 
				.selecttoright:
				
					cmp word [sym_selected], 2
					jge .waitforkey
					
					inc word [sym_selected]
					
					jmp .selectsize ; selectsymbol
						
				.confirmsymbol:
					
					mov bx, [sym_selected]
					mov byte [level_count], bl
					
					jmp playgame
			
			.title	db "Select Grid Size", 0
			.s1		db "   3x3   ", 0
			.s2		db "   4x4   ", 0
			.s3		db "   5x5   ", 0
	
	playgame:
	
		.title:
	    
			mov dx, 0
			call movecursor
			
			mov cx, 80
			mov bl, [color_cyanwhite]
			call clearbackground
			
			mov dl, 2
			call movecursor
			
			mov si, game_title
			call println
		
		.background:
		
			mov dh, 1
			mov dl, 0
			call movecursor
			
			mov cx, 5
			
			.curtain:
			
				push cx
				
				mov cx, 2
				call sleep
				
				mov cx, 400
				mov bl, [color_yellowblack]
				call clearbackground
			
				pop cx
				
				add dh, 5
				call movecursor
			
				loop .curtain
			
			mov cx, 1
			call sleep
			
			cmp byte [input_done], 0
			jne .printnames
		
		.asknames:
		
			; ask for player 1
			
			call cursorshow
			
			mov cl, 21
			mov ch, 10
			mov si, askforname1
			call drawinputbox
			
			mov si, ax
			mov bx, 0
			
			.copyname1:
				lodsb
				mov byte [name_player1 + bx], al
				inc bx
				cmp al, 0
				jne .copyname1
				
			; ask for player 2
			
			mov cl, 21
			mov ch, 10
			mov si, askforname2
			call drawinputbox
			
			mov si, ax
			mov bx, 0
			
			.copyname2:
				lodsb
				mov byte [name_player2 + bx], al
				inc bx
				cmp al, 0
				jne .copyname2
			
			mov byte [input_done], 1
			
			jmp .title
		
		.printnames:
		
			call cursorhide
			
			mov cl, 7
			mov ch, 7
			mov dl, 12
			mov dh, 8
			mov bl, [color_cyanwhite]
			call drawbox
			
			mov cl, 59
			mov ch, 7
			mov dl, 12
			mov dh, 8
			mov bl, [color_cyanwhite]
			call drawbox
			
			mov dl, 9
			mov dh, 8
			call movecursor
			
			mov si, label_player1
			call println
		
			mov dl, 9
			mov dh, 10
			call movecursor
			
			mov si, name_player1
			call println
			
			add dh, 3
			add dl, 1
			call movecursor
			
			mov cx, 3
			
			.print1sym:
			
				push cx
				
				mov ah, 0Ah
				mov byte al, [symbol_player1]
				mov bh, 0
				mov cx, 1
				int 10h
				
				pop cx
				
				add dl, 2
				call movecursor
				
				loop .print1sym
			
			mov dl, 61
			mov dh, 8
			call movecursor
			
			mov si, label_player2
			call println
			
			mov dl, 61
			mov dh, 10
			call movecursor
			
			mov si, name_player2
			call println
			
			add dh, 3
			add dl, 1
			call movecursor
			
			mov cx, 3
			
			.print2sym:
			
				push cx
				
				mov ah, 0Ah
				mov byte al, [symbol_player2]
				mov bh, 0
				mov cx, 1
				int 10h
				
				pop cx
				
				add dl, 2
				call movecursor
				
				loop .print2sym
			
			mov dl, 31
			mov dh, 2
			call movecursor
			
			mov si, .tft
			call println
			
			jmp .drawgrid
			
			.tft	db "< 2 Player Mode >", 0
		
		.drawgrid:
		
			mov word [cursor_position2], 0
		
			cmp byte [level_count], 0
			je .level1
			
			cmp byte [level_count], 1
			je .level2
			
			cmp byte [level_count], 2
			je .level3
			
			jmp finalizechecking			; if all levels are finished, we can now finalize whos the winner...
											; by comparing score of player 1 and 2 if the player 1 has greater score then,
											; player 1 is the winner otherwise its player 2...
			
			.level1:
			
				mov cl, 34
				mov ch, 8
				mov dl, 11
				mov dh, 9
				mov bl, [color_greenwhite]
				mov bh, [color_whiteblack]
				call drawboxborder
				
				mov byte [cursor_position], 37
				mov byte [cursor_position+1], 10
				
				jmp .drawturn
				
			.level2:
			
				mov cl, 33
				mov ch, 7
				mov dl, 13
				mov dh, 11
				mov bl, [color_greenwhite]
				mov bh, [color_whiteblack]
				call drawboxborder
				
				mov byte [cursor_position], 36
				mov byte [cursor_position+1], 9
			
				jmp .drawturn
				
			.level3:
			
				mov cl, 32
				mov ch, 6
				mov dl, 15
				mov dh, 13
				mov bl, [color_greenwhite]
				mov bh, [color_whiteblack]
				call drawboxborder
				
				mov byte [cursor_position], 35
				mov byte [cursor_position+1], 8
		
		.drawturn:
		
			cmp byte [player_turn], 0
			je .sp2
		
			mov dl, 32
			mov dh, 22
			call movecursor
			
			mov si, label_yourturn
			call println
			
			jmp .keywait
		
			.sp2:
			
				mov dl, 32
				mov dh, 22
				call movecursor
				
				mov si, label_robotsturn
				call println
		
		.keywait:
		
			mov byte dl, [cursor_position]
			mov byte dh, [cursor_position+1]
			call movecursor
			
			call cursorshow
		
			call keypress
			
			cmp al, 27
			je exit
			
			cmp al, 13
			je .confirm
			
			cmp al, 'i'
			je .mu
			
			cmp al, 'k'
			je .md
			
			cmp al, 'j'
			je .ml
			
			cmp al, 'l'
			je .mr
		
			jmp .keywait
		
		.cursormovement:
		
			.ml:
			
				cmp byte [level_count], 0
				je .limlvl1
				
				cmp byte [level_count], 1
				je .limlvl2
				
				cmp byte [level_count], 2
				je .limlvl3
				
				jmp .cntm1
				
				.limlvl1:
				
					cmp byte [cursor_position], 37
					jle .keywait
					
					jmp .cntm1
					
				.limlvl2:
				
					cmp byte [cursor_position], 36
					jle .keywait
					
					jmp .cntm1
					
				.limlvl3:
				
					cmp byte [cursor_position], 35
					jle .keywait
					
				.cntm1:
			
					sub byte [cursor_position], 2
					sub word [cursor_position2], 1
					
					jmp .drawturn
			
			.mr:
			
				cmp byte [level_count], 0
				je .limlvl12
				
				cmp byte [level_count], 1
				je .limlvl22
				
				cmp byte [level_count], 2
				je .limlvl32
				
				jmp .cntm2
				
				.limlvl12:
				
					cmp byte [cursor_position], 41
					jge .keywait
					
					jmp .cntm2
					
				.limlvl22:
				
					cmp byte [cursor_position], 42
					jge .keywait
					
					jmp .cntm2
					
				.limlvl32:
				
					cmp byte [cursor_position], 43
					jge .keywait
					
				.cntm2:
			
					add byte [cursor_position], 2
					add word [cursor_position2], 1
					
					jmp .drawturn
			
			.mu:
			
				cmp byte [level_count], 0
				je .limlvl13
				
				cmp byte [level_count], 1
				je .limlvl23
				
				cmp byte [level_count], 2
				je .limlvl33
				
				jmp .cntm3
				
				.limlvl13:
				
					cmp byte [cursor_position+1], 10
					jle .keywait
					
					sub word [cursor_position2], 3
					
					jmp .cntm3
					
				.limlvl23:
				
					cmp byte [cursor_position+1], 9
					jle .keywait
					
					sub word [cursor_position2], 4
					
					jmp .cntm3
					
				.limlvl33:
				
					cmp byte [cursor_position+1], 8
					jle .keywait
					
					sub word [cursor_position2], 5
					
				.cntm3:
			
					sub byte [cursor_position+1], 2
					
					jmp .drawturn
			
			.md:
			
				cmp byte [level_count], 0
				je .limlvl14
				
				cmp byte [level_count], 1
				je .limlvl24
				
				cmp byte [level_count], 2
				je .limlvl34
				
				jmp .cntm4
				
				.limlvl14:
				
					cmp byte [cursor_position+1], 14
					jge .keywait
					
					add word [cursor_position2], 3
					
					jmp .cntm4
					
				.limlvl24:
				
					cmp byte [cursor_position+1], 15
					jge .keywait
					
					add word [cursor_position2], 4
					
					jmp .cntm4
					
				.limlvl34:
				
					cmp byte [cursor_position+1], 16
					jge .keywait
					
					add word [cursor_position2], 5
					
				.cntm4:
			
					add byte [cursor_position+1], 2
					
					jmp .drawturn
			
		.confirm:
			
			mov byte dl, [cursor_position]
			mov byte dh, [cursor_position+1]
			call movecursor
		
			mov bx, [cursor_position2]
			
			cmp byte [player_turn], 1
			je .switchtop2
			
			cmp byte [level_count], 0
			je .ss1
			cmp byte [level_count], 1
			je .ss2
			cmp byte [level_count], 2
			je .ss3
			
			jmp .switchturn1
			
			.ss1:
			
				mov byte al, [symbol_player2]
				mov byte [board_array_3b3+bx], al
				
				jmp .switchturn1
				
			.ss2:
			
				mov byte al, [symbol_player2]
				mov byte [board_array_4b4+bx], al
				
				jmp .switchturn1
				
			.ss3:
			
				mov byte al, [symbol_player2]
				mov byte [board_array_5b5+bx], al
			
			.switchturn1:
			
				mov ah, 0Ah
				mov bh, 0
				mov cx, 1
				int 10h
				
				mov byte [player_turn], 1
				
				jmp .checkmoves
			
			.switchtop2:
			
				cmp byte [level_count], 0
				je .ss4
				cmp byte [level_count], 1
				je .ss5
				cmp byte [level_count], 2
				je .ss6
				
				jmp .switchturn2
				
				.ss4:
				
					mov byte al, [symbol_player1]
					mov byte [board_array_3b3+bx], al
					
					jmp .switchturn2
					
				.ss5:
				
					mov byte al, [symbol_player1]
					mov byte [board_array_4b4+bx], al
					
					jmp .switchturn2
					
				.ss6:
				
					mov byte al, [symbol_player1]
					mov byte [board_array_5b5+bx], al
					
				.switchturn2:
				
					mov ah, 0Ah
					mov bh, 0
					mov cx, 1
					int 10h
			
					mov byte [player_turn], 0
					
			.checkmoves:
			
				cmp byte [level_count], 0
				je .csh1
				cmp byte [level_count], 1
				je .csh2
				cmp byte [level_count], 2
				je .csh3
				
				.csh1:
				
					mov cx, 9
					mov bx, 0
					mov ax, 0
					
					.l1:
						cmp byte [board_array_3b3+bx], 0
						jne .cf
						jmp .skip1
						.cf:
							inc ax
						.skip1:
							inc bx
							loop .l1
							
					cmp ax, 9
					je checkboard
					
					jmp .drawturn
				
				.csh2:
				
					mov cx, 16
					mov bx, 0
					mov ax, 0
					
					.l2:
						cmp byte [board_array_4b4+bx], 0
						jne .cf2
						jmp .skip2
						.cf2:
							inc ax
						.skip2:
							inc bx
							loop .l2
					
					cmp ax, 16
					je checkboard
					
					jmp .drawturn
				
				.csh3:
				
				mov cx, 25
				mov bx, 0
				mov ax, 0
				
				.l3:
					cmp byte [board_array_5b5+bx], 0
					jne .cf3
					jmp .skip3
					.cf3:
						inc ax
					.skip3:
						inc bx
						loop .l3
						
				cmp ax, 25
				je checkboard
				
				jmp .drawturn

exit:

	mov dx, 0
	call movecursor

	mov cx, 2000
	mov bl, [color_blacklgray]
	call clearbackground

	call cursorshow

	int 20h
	
checkboard:

	; checks for horizontal, vertical, and diagonal lines
	; e.g. if all the player 1 symbols are lined up exactly,
	; it's score (for player1) will increase

	mov byte al, [symbol_player1]
	mov byte bl, [symbol_player2]

	cmp byte [level_count], 0
	je .checkforlevel1
	
	cmp byte [level_count], 1
	je .checkforlevel2
	
	cmp byte [level_count], 2
	je .checkforlevel3
	
	jmp playsingle.startgame
	
	.checkforlevel1:
		
		.player1:
		
			.choriz:		; check horizontally
			
				.row1:
			
					cmp byte [board_array_3b3], al
					jne .row2
					cmp byte [board_array_3b3+1], al
					jne .row2
					cmp byte [board_array_3b3+2], al
					jne .row2
					
					add byte [score_1], 5
					
				.row2:
					
					cmp byte [board_array_3b3+3], al
					jne .row3
					cmp byte [board_array_3b3+4], al
					jne .row3
					cmp byte [board_array_3b3+5], al
					jne .row3
					
					add byte [score_1], 5
					
				.row3:
					
					cmp byte [board_array_3b3+6], al
					jne .cvert
					cmp byte [board_array_3b3+7], al
					jne .cvert
					cmp byte [board_array_3b3+8], al
					jne .cvert
					
					add byte [score_1], 5
					
			.cvert:		; check vertically
			
				.col1:
				
					cmp byte [board_array_3b3], al
					jne .col2
					cmp byte [board_array_3b3+3], al
					jne .col2
					cmp byte [board_array_3b3+6], al
					jne .col2
					
					add byte [score_1], 5
					
				.col2:
				
					cmp byte [board_array_3b3+1], al
					jne .col3
					cmp byte [board_array_3b3+4], al
					jne .col3
					cmp byte [board_array_3b3+7], al
					jne .col3
					
					add byte [score_1], 5
					
				.col3:
				
					cmp byte [board_array_3b3+2], al
					jne .cdiag
					cmp byte [board_array_3b3+5], al
					jne .cdiag
					cmp byte [board_array_3b3+8], al
					jne .cdiag
					
					add byte [score_1], 5
					
			.cdiag:
			
				.d1:
				
					cmp byte [board_array_3b3], al
					jne .d2
					cmp byte [board_array_3b3+4], al
					jne .d2
					cmp byte [board_array_3b3+8], al
					jne .d2
					
					add byte [score_1], 5
					
				.d2:
				
					cmp byte [board_array_3b3+2], al
					jne .player2
					cmp byte [board_array_3b3+4], al
					jne .player2
					cmp byte [board_array_3b3+6], al
					jne .player2
					
					add byte [score_1], 5
					
		.player2:
		
			.choriz2:		; check horizontally
			
				.row12:
			
					cmp byte [board_array_3b3], bl
					jne .row22
					cmp byte [board_array_3b3+1], bl
					jne .row22
					cmp byte [board_array_3b3+2], bl
					jne .row22
					
					add byte [score_2], 5
					
				.row22:
					
					cmp byte [board_array_3b3+3], bl
					jne .row32
					cmp byte [board_array_3b3+4], bl
					jne .row32
					cmp byte [board_array_3b3+5], bl
					jne .row32
					
					add byte [score_2], 5
					
				.row32:
					
					cmp byte [board_array_3b3+6], bl
					jne .cvert2
					cmp byte [board_array_3b3+7], bl
					jne .cvert2
					cmp byte [board_array_3b3+8], bl
					jne .cvert2
					
					add byte [score_2], 5
					
			.cvert2:		; check vertically
			
				.col12:
				
					cmp byte [board_array_3b3], bl
					jne .col22
					cmp byte [board_array_3b3+3], bl
					jne .col22
					cmp byte [board_array_3b3+6], bl
					jne .col22
					
					add byte [score_2], 5
					
				.col22:
				
					cmp byte [board_array_3b3+1], bl
					jne .col32
					cmp byte [board_array_3b3+4], bl
					jne .col32
					cmp byte [board_array_3b3+7], bl
					jne .col32
					
					add byte [score_2], 5
					
				.col32:
				
					cmp byte [board_array_3b3+2], bl
					jne .cdiag2
					cmp byte [board_array_3b3+5], bl
					jne .cdiag2
					cmp byte [board_array_3b3+8], bl
					jne .cdiag2
					
					add byte [score_2], 5
					
			.cdiag2:
			
				.d12:
				
					cmp byte [board_array_3b3], bl
					jne .d22
					cmp byte [board_array_3b3+4], bl
					jne .d22
					cmp byte [board_array_3b3+8], bl
					jne .d22
					
					add byte [score_2], 5
					
				.d22:
				
					cmp byte [board_array_3b3+2], bl
					jne .done1
					cmp byte [board_array_3b3+4], bl
					jne .done1
					cmp byte [board_array_3b3+6], bl
					jne .done1
					
					add byte [score_2], 5
					
		.done1:
		
		cmp byte [is2pmode], 1
		je .done1p2m
		
		inc byte [level_count]
		
		mov word [game_timer], 3
		
		jmp playsingle.startgame
		
		.done1p2m:
		
			jmp finalizechecking
	
	.checkforlevel2:
	
		.player12:
		
			.choriz3:
			
				.row13:
				 
					cmp byte [board_array_4b4], al
					jne .row23
					cmp byte [board_array_4b4+1], al
					jne .row23
					cmp byte [board_array_4b4+2], al
					jne .row23
					cmp byte [board_array_4b4+3], al
					jne .row23
					
					add byte [score_1], 5
				 
				.row23:
				
					cmp byte [board_array_4b4+4], al
					jne .row33
					cmp byte [board_array_4b4+5], al
					jne .row33
					cmp byte [board_array_4b4+6], al
					jne .row33
					cmp byte [board_array_4b4+7], al
					jne .row33
					
					add byte [score_1], 5
				
				.row33:
				
					cmp byte [board_array_4b4+8], al
					jne .row43
					cmp byte [board_array_4b4+9], al
					jne .row43
					cmp byte [board_array_4b4+10], al
					jne .row43
					cmp byte [board_array_4b4+11], al
					jne .row43
					
					add byte [score_1], 5
					
				.row43:
				
					cmp byte [board_array_4b4+12], al
					jne .cvert3
					cmp byte [board_array_4b4+13], al
					jne .cvert3
					cmp byte [board_array_4b4+14], al
					jne .cvert3
					cmp byte [board_array_4b4+15], al
					jne .cvert3
					
					add byte [score_1], 5
				
			.cvert3:
			
				.col13:
				
					cmp byte [board_array_4b4], al
					jne .col23
					cmp byte [board_array_4b4+4], al
					jne .col23
					cmp byte [board_array_4b4+8], al
					jne .col23
					cmp byte [board_array_4b4+12], al
					jne .col23
					
					add byte [score_1], 5
				
				.col23:
				
					cmp byte [board_array_4b4+1], al
					jne .col33
					cmp byte [board_array_4b4+5], al
					jne .col33
					cmp byte [board_array_4b4+9], al
					jne .col33
					cmp byte [board_array_4b4+13], al
					jne .col33
					
					add byte [score_1], 5
				
				.col33:
				
					cmp byte [board_array_4b4+2], al
					jne .col43
					cmp byte [board_array_4b4+6], al
					jne .col43
					cmp byte [board_array_4b4+10], al
					jne .col43
					cmp byte [board_array_4b4+14], al
					jne .col43
					
					add byte [score_1], 5
				
				.col43:
				
					cmp byte [board_array_4b4+3], al
					jne .cdiag3
					cmp byte [board_array_4b4+7], al
					jne .cdiag3
					cmp byte [board_array_4b4+11], al
					jne .cdiag3
					cmp byte [board_array_4b4+15], al
					jne .cdiag3
					
					add byte [score_1], 5
			
			.cdiag3:
		
				.d13:
				
					cmp byte [board_array_4b4], al
					jne .d23
					cmp byte [board_array_4b4+5], al
					jne .d23
					cmp byte [board_array_4b4+10], al
					jne .d23
					cmp byte [board_array_4b4+15], al
					jne .d23
					
					add byte [score_1], 5
				
				.d23:
				
					cmp byte [board_array_4b4+3], al
					jne .player22
					cmp byte [board_array_4b4+6], al
					jne .player22
					cmp byte [board_array_4b4+9], al
					jne .player22
					cmp byte [board_array_4b4+12], al
					jne .player22
					
					add byte [score_1], 5
		
		.player22:
		
			.choriz4:
			
				.row14:
				
					cmp byte [board_array_4b4], bl
					jne .row24
					cmp byte [board_array_4b4+1], bl
					jne .row24
					cmp byte [board_array_4b4+2], bl
					jne .row24
					cmp byte [board_array_4b4+3], bl
					jne .row24
					
					add byte [score_2], 5
				 
				.row24:
				
					cmp byte [board_array_4b4+4], bl
					jne .row34
					cmp byte [board_array_4b4+5], bl
					jne .row34
					cmp byte [board_array_4b4+6], bl
					jne .row34
					cmp byte [board_array_4b4+7], bl
					jne .row34
					
					add byte [score_2], 5
				
				.row34:
				
					cmp byte [board_array_4b4+8], bl
					jne .row44
					cmp byte [board_array_4b4+9], bl
					jne .row44
					cmp byte [board_array_4b4+10], bl
					jne .row44
					cmp byte [board_array_4b4+11], bl
					jne .row44
					
					add byte [score_2], 5
					
				.row44:
				
					cmp byte [board_array_4b4+12], bl
					jne .cvert4
					cmp byte [board_array_4b4+13], bl
					jne .cvert4
					cmp byte [board_array_4b4+14], bl
					jne .cvert4
					cmp byte [board_array_4b4+15], bl
					jne .cvert4
					
					add byte [score_2], 5
			
			.cvert4:
			
				.col14:
				
					cmp byte [board_array_4b4], al
					jne .col24
					cmp byte [board_array_4b4+4], al
					jne .col24
					cmp byte [board_array_4b4+8], al
					jne .col24
					cmp byte [board_array_4b4+12], al
					jne .col24
					
					add byte [score_2], 5
				
				.col24:
				
					cmp byte [board_array_4b4+1], al
					jne .col34
					cmp byte [board_array_4b4+5], al
					jne .col34
					cmp byte [board_array_4b4+9], al
					jne .col34
					cmp byte [board_array_4b4+13], al
					jne .col34
					
					add byte [score_2], 5
				
				.col34:
				
					cmp byte [board_array_4b4+1], al
					jne .col44
					cmp byte [board_array_4b4+5], al
					jne .col44
					cmp byte [board_array_4b4+9], al
					jne .col44
					cmp byte [board_array_4b4+13], al
					jne .col44
					
					add byte [score_2], 5
				
				.col44:
				
					cmp byte [board_array_4b4+3], al
					jne .cdiag4
					cmp byte [board_array_4b4+7], al
					jne .cdiag4
					cmp byte [board_array_4b4+11], al
					jne .cdiag4
					cmp byte [board_array_4b4+15], al
					jne .cdiag4
					
					add byte [score_2], 5
				
			.cdiag4:
		
				.d14:
				
					cmp byte [board_array_4b4], al
					jne .d24
					cmp byte [board_array_4b4+5], al
					jne .d24
					cmp byte [board_array_4b4+10], al
					jne .d24
					cmp byte [board_array_4b4+15], al
					jne .d24
					
					add byte [score_2], 5
				
				.d24:
				
					cmp byte [board_array_4b4+3], al
					jne .done2
					cmp byte [board_array_4b4+6], al
					jne .done2
					cmp byte [board_array_4b4+9], al
					jne .done2
					cmp byte [board_array_4b4+12], al
					jne .done2
					
					add byte [score_2], 5
		
		.done2:
		
		cmp byte [is2pmode], 1
		je .done2p2m
		
		inc byte [level_count]
		
		mov word [game_timer], 2
		
		jmp playsingle.startgame
		
		.done2p2m:
		
			jmp finalizechecking
	
	.checkforlevel3:
	
		.player13:
		
			.choriz5:
			
				.row15:
				
					cmp byte [board_array_5b5], al
					jne .row25
					cmp byte [board_array_5b5+1], al
					jne .row25
					cmp byte [board_array_5b5+2], al
					jne .row25
					cmp byte [board_array_5b5+3], al
					jne .row25
					cmp byte [board_array_5b5+4], al
					jne .row25
				
					add byte [score_1], 5
				 
				.row25:
				
					cmp byte [board_array_5b5+5], al
					jne .row35
					cmp byte [board_array_5b5+6], al
					jne .row35
					cmp byte [board_array_5b5+7], al
					jne .row35
					cmp byte [board_array_5b5+8], al
					jne .row35
					cmp byte [board_array_5b5+9], al
					jne .row35
					
					add byte [score_1], 5
				
				.row35:
				
					cmp byte [board_array_5b5+10], al
					jne .row45
					cmp byte [board_array_5b5+11], al
					jne .row45
					cmp byte [board_array_5b5+12], al
					jne .row45
					cmp byte [board_array_5b5+13], al
					jne .row45
					cmp byte [board_array_5b5+14], al
					jne .row45
				
					add byte [score_1], 5
					
				.row45:
				
					cmp byte [board_array_5b5+15], al
					jne .row55
					cmp byte [board_array_5b5+16], al
					jne .row55
					cmp byte [board_array_5b5+17], al
					jne .row55
					cmp byte [board_array_5b5+18], al
					jne .row55
					cmp byte [board_array_5b5+19], al
					jne .row55
				
					add byte [score_1], 5
					
				.row55:
				
					cmp byte [board_array_5b5+20], al
					jne .cvert5
					cmp byte [board_array_5b5+21], al
					jne .cvert5
					cmp byte [board_array_5b5+22], al
					jne .cvert5
					cmp byte [board_array_5b5+23], al
					jne .cvert5
					cmp byte [board_array_5b5+24], al
					jne .cvert5
				
					add byte [score_1], 5
			
			.cvert5:
			
				.col15:
				
					cmp byte [board_array_5b5], al
					jne .col25
					cmp byte [board_array_5b5+5], al
					jne .col25
					cmp byte [board_array_5b5+10], al
					jne .col25
					cmp byte [board_array_5b5+15], al
					jne .col25
					cmp byte [board_array_5b5+20], al
					jne .col25
				
					add byte [score_1], 5
				
				.col25:
				
					cmp byte [board_array_5b5+1], al
					jne .col35
					cmp byte [board_array_5b5+6], al
					jne .col35
					cmp byte [board_array_5b5+11], al
					jne .col35
					cmp byte [board_array_5b5+16], al
					jne .col35
					cmp byte [board_array_5b5+21], al
					jne .col35
				
					add byte [score_1], 5
				
				.col35:
				
					cmp byte [board_array_5b5+2], al
					jne .col45
					cmp byte [board_array_5b5+7], al
					jne .col45
					cmp byte [board_array_5b5+12], al
					jne .col45
					cmp byte [board_array_5b5+17], al
					jne .col45
					cmp byte [board_array_5b5+22], al
					jne .col45
				
					add byte [score_1], 5
					
				.col45:
				
					cmp byte [board_array_5b5+3], al
					jne .col55
					cmp byte [board_array_5b5+8], al
					jne .col55
					cmp byte [board_array_5b5+13], al
					jne .col55
					cmp byte [board_array_5b5+18], al
					jne .col55
					cmp byte [board_array_5b5+23], al
					jne .col55
				
					add byte [score_1], 5
					
				.col55:
				
					cmp byte [board_array_5b5+4], al
					jne .cdiag5
					cmp byte [board_array_5b5+9], al
					jne .cdiag5
					cmp byte [board_array_5b5+14], al
					jne .cdiag5
					cmp byte [board_array_5b5+19], al
					jne .cdiag5
					cmp byte [board_array_5b5+24], al
					jne .cdiag5
					
					add byte [score_1], 5
			
			.cdiag5:
		
				.d15:
				
					cmp byte [board_array_5b5], al
					jne .d25
					cmp byte [board_array_5b5+6], al
					jne .d25
					cmp byte [board_array_5b5+12], al
					jne .d25
					cmp byte [board_array_5b5+18], al
					jne .d25
					cmp byte [board_array_5b5+24], al
					jne .d25
				
					add byte [score_1], 5
				
				.d25:
				
					cmp byte [board_array_5b5+4], al
					jne .player23
					cmp byte [board_array_5b5+8], al
					jne .player23
					cmp byte [board_array_5b5+12], al
					jne .player23
					cmp byte [board_array_5b5+16], al
					jne .player23
					cmp byte [board_array_5b5+20], al
					jne .player23
				
					add byte [score_1], 5
		
		.player23:
		
			.choriz6:
			
				.row16:
				
					cmp byte [board_array_5b5], bl
					jne .row26
					cmp byte [board_array_5b5+1], bl
					jne .row26
					cmp byte [board_array_5b5+2], bl
					jne .row26
					cmp byte [board_array_5b5+3], bl
					jne .row26
					cmp byte [board_array_5b5+4], bl
					jne .row26
				
					add byte [score_2], 5
				 
				.row26:
				
					cmp byte [board_array_5b5+5], bl
					jne .row36
					cmp byte [board_array_5b5+6], bl
					jne .row36
					cmp byte [board_array_5b5+7], bl
					jne .row36
					cmp byte [board_array_5b5+8], bl
					jne .row36
					cmp byte [board_array_5b5+9], bl
					jne .row36
				
					add byte [score_2], 5
				
				.row36:
				
					cmp byte [board_array_5b5+10], bl
					jne .row46
					cmp byte [board_array_5b5+11], bl
					jne .row46
					cmp byte [board_array_5b5+12], bl
					jne .row46
					cmp byte [board_array_5b5+13], bl
					jne .row46
					cmp byte [board_array_5b5+14], bl
					jne .row46
				
					add byte [score_2], 5
				
				.row46:
					
					cmp byte [board_array_5b5+15], bl
					jne .row56
					cmp byte [board_array_5b5+16], bl
					jne .row56
					cmp byte [board_array_5b5+17], bl
					jne .row56
					cmp byte [board_array_5b5+18], bl
					jne .row56
					cmp byte [board_array_5b5+19], bl
					jne .row56
				
					add byte [score_2], 5
				
				.row56:
				
					cmp byte [board_array_5b5+20], bl
					jne .cvert6
					cmp byte [board_array_5b5+21], bl
					jne .cvert6
					cmp byte [board_array_5b5+22], bl
					jne .cvert6
					cmp byte [board_array_5b5+23], bl
					jne .cvert6
					cmp byte [board_array_5b5+24], bl
					jne .cvert6
				
					add byte [score_2], 5
			
			.cvert6:
			
				.col16:
				
					cmp byte [board_array_5b5], bl
					jne .col26
					cmp byte [board_array_5b5+5], bl
					jne .col26
					cmp byte [board_array_5b5+10], bl
					jne .col26
					cmp byte [board_array_5b5+15], bl
					jne .col26
					cmp byte [board_array_5b5+20], bl
					jne .col26
				
					add byte [score_2], 5
				
				.col26:
				
					cmp byte [board_array_5b5+1], bl
					jne .col36
					cmp byte [board_array_5b5+6], bl
					jne .col36
					cmp byte [board_array_5b5+11], bl
					jne .col36
					cmp byte [board_array_5b5+16], bl
					jne .col36
					cmp byte [board_array_5b5+21], bl
					jne .col36
				
					add byte [score_2], 5
				
				.col36:
				
					cmp byte [board_array_5b5+2], bl
					jne .col46
					cmp byte [board_array_5b5+7], bl
					jne .col46
					cmp byte [board_array_5b5+12], bl
					jne .col46
					cmp byte [board_array_5b5+17], bl
					jne .col46
					cmp byte [board_array_5b5+22], bl
					jne .col46
				
					add byte [score_2], 5
				
				.col46:
				
					cmp byte [board_array_5b5+3], bl
					jne .col56
					cmp byte [board_array_5b5+8], bl
					jne .col56
					cmp byte [board_array_5b5+13], bl
					jne .col56
					cmp byte [board_array_5b5+18], bl
					jne .col56
					cmp byte [board_array_5b5+23], bl
					jne .col56
				
					add byte [score_2], 5
				
				.col56:
				
					cmp byte [board_array_5b5+4], bl
					jne .cdiag6
					cmp byte [board_array_5b5+9], bl
					jne .cdiag6
					cmp byte [board_array_5b5+14], bl
					jne .cdiag6
					cmp byte [board_array_5b5+19], bl
					jne .cdiag6
					cmp byte [board_array_5b5+24], bl
					jne .cdiag6
				
					add byte [score_2], 5
			
			.cdiag6:
		
				.d16:
				
					cmp byte [board_array_5b5], bl
					jne .d26
					cmp byte [board_array_5b5+6], bl
					jne .d26
					cmp byte [board_array_5b5+12], bl
					jne .d26
					cmp byte [board_array_5b5+18], bl
					jne .d26
					cmp byte [board_array_5b5+24], bl
					jne .d26
				
					add byte [score_2], 5
				
				.d26:
				
					cmp byte [board_array_5b5+4], bl
					jne .done3
					cmp byte [board_array_5b5+8], bl
					jne .done3
					cmp byte [board_array_5b5+12], bl
					jne .done3
					cmp byte [board_array_5b5+16], bl
					jne .done3
					cmp byte [board_array_5b5+20], bl
					jne .done3
				
					add byte [score_2], 5

		.done3:
	
		cmp byte [is2pmode], 1
		je .done3p2m
		
		inc byte [level_count]
		
		mov word [game_timer], 0
		
		jmp playsingle.startgame
		
		.done3p2m:
		
			jmp finalizechecking

finalizechecking:

	call cursorhide

	mov dx, 0
	call movecursor
	
	mov cx, 2000
	mov bl, [color_cyanwhite]
	call clearbackground
	
	mov dh, 5
	
	mov dl, 20
	call movecursor
	
	mov si, .sp1t
	call println
	
	mov ah, 0
	mov byte al, [score_1]
	call tostring
	mov si, ax
	call println
	
	mov dl, 45
	call movecursor
	
	mov si, .sp2t
	call println
	
	mov ah, 0
	mov byte al, [score_2]
	call tostring
	mov si, ax
	call println
	
	mov byte al, [score_2]
	cmp byte [score_1], al
	jg .showp1wins
	
	mov byte al, [score_2]
	cmp byte [score_1], al
	jl .showp2wins
	
	jmp .showtie
	
	.showp1wins:
	
		mov dl, 34
		mov dh, 12
		call movecursor
		
		mov si, .tp1
		call println
		
		jmp .key
		
	.showp2wins:
	
		mov dl, 34
		mov dh, 12
		call movecursor
		
		mov si, .tp2
		call println
		
		jmp .key
		
	.showtie:
	
		mov dl, 35
		mov dh, 12
		call movecursor
		
		mov si, .tp3
		call println

	.key:
	
		mov dl, 28
		mov dh, 20
		call movecursor
		
		mov si, .tpanyk
		call println
	
		call keypress
		
		cmp al, 0
		jne start.mainbg
		
		jmp .key
 
	jmp exit

	.tp1	db "Player 1 Wins", 0
	.tp2	db "Player 2 Wins", 0
	.tp3	db "Tie Score!", 0
	.tpanyk	db "Press any key to continue", 0
	.sp1t	db "P1 Score: ", 0
	.sp2t	db "P2 Score: ", 0








; COMMANDS











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

	.reps:

		lodsb
		int 10h

		cmp al, 0
		jne .reps

	popa

	ret

; input:		dh:dl = x & y position
; output:		none
movecursor:

	mov ah, 2
	mov bh, 0
	int 10h

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

	mov ah, 86h
	int 15h

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

	mov ah, 1
	mov ch, 36
	int 10h

	ret

; output:		none
; input:		none
cursorshow:

	mov ah, 1
	mov ch, 6
	mov cl, 7
	int 10h
	
	ret

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
	 	ret

; input:		none
; ouput:		none
keyinputpress:

	mov ah, 1
	int 21h
	
	ret

; input:		ax = number
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






; DRAWABLE OBJECTS








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


; input:		cl:ch = x & y position
;				dl:dh = w & h size
;				bl = color 1
;				bh = color 2
; output:		none
drawboxborder:

	pusha

	cmp dl, 1
	jl .done

	cmp dh, 1
	jl .done

	mov byte [.position], cl
	mov byte [.position+1], ch
	mov byte [.size], dl
	mov byte [.size+1], dh
	mov byte [.colors], bl
	mov byte [.colors+1], bh

	mov bx, 0
	mov cx, bx
	mov dx, bx

	mov byte cl, [.position]
	mov byte ch, [.position+1]
	mov byte bl, [.colors]
	mov byte dl, [.size]
	mov byte dh, [.size+1]
	call drawbox					; draw first rect

	add byte [.position], 1
	add byte [.position+1], 1

	sub byte [.size], 2
	sub byte [.size+1], 2

	mov byte cl, [.position]
	mov byte ch, [.position+1]
	mov byte bl, [.colors+1]
	mov byte dl, [.size]
	mov byte dh, [.size+1]
	call drawbox					; draw second rect

	.done:

		popa
	
		ret

	.position		db 0,0
	.size			db 0,0
	.colors			dw 0,0



; input:		cl:ch = x & y position
;				si = text to display
;				ax = string output
drawinputbox:

	pusha
	
	mov byte [.position], cl
	mov byte [.position+1], ch

	mov cx, 0
	
	mov byte cl, [.position]
	mov byte ch, [.position+1]
	mov dl, 40
	mov dh, 5
	mov bl, [color_greenwhite]
	call drawbox					; draw input box bg
	
	mov byte cl, [.position]
	add cl, 1
	mov byte ch, [.position+1]
	add ch, 3
	mov dl, 38
	mov dh, 1
	mov bl, [color_whiteblack]
	call drawbox					; draw input box
	
	mov byte dl, [.position]
	mov byte dh, [.position+1]
	add dl, 1
	add dh, 1
	call movecursor
	
	call println
	
	mov byte cl, [.length]
	mov bx, 0
	
	.clearstring:
	
		mov byte [.strings + bx], 0		; clear the array first
	
		inc bx
		dec cl
	
		cmp cl, 0
		jne .clearstring
	
	mov byte dl, [.position]
	mov byte dh, [.position+1]
	add dl, 2
	add dh, 3
	call movecursor
	
	mov byte cl, [.length]
	mov di, .strings
	
	.write:
	
		call keyinputpress
		
		cmp al, 8
		je .donewrite
		
		cmp al, 13
		je .donewrite
		
		mov [di], al
		inc di
		
		inc dl
		call movecursor
		
		dec cl
		
		cmp cl, 0
		jge .write
		
	.donewrite:
		
		mov byte [di], 0
		
		popa
		
		mov ax, .strings
		
		ret
	
	.position	db 0,0
	.strings	times 7 db 0
	.length		db 7


; input:		cl:ch = x & y position
;				bl = color
; output:		none
drawgametitle:

	push cx
	push dx

	mov byte [.position], cl
	mov byte [.position+1], ch

	mov cx, 0

	mov byte dl, [.position]
	mov byte dh, [.position+1]
	call movecursor

	mov cx, 8
	call clearbackground

	inc dh
	call movecursor

	mov cx, 8
	call clearbackground

	inc dh
	add dl, 3
	call movecursor

	mov cx, 2
	call clearbackground

	inc dh
	call movecursor

	mov cx, 2
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 3
	call clearbackground

	add dl, 4
	call movecursor

	mov cx, 3
	call clearbackground

	sub dl, 7
	inc dh
	call movecursor

	mov cx, 2
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 1
	call clearbackground

	sub dl, 9
	inc dh
	call movecursor

	mov cx, 2
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 3
	call clearbackground

	add dl, 4
	call movecursor

	mov cx, 3
	call clearbackground

	sub dl, 7
	inc dh
	call movecursor

	mov cx, 2
	call clearbackground

	inc dh
	call movecursor

	mov cx, 2
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 3
	call clearbackground

	add dl, 4
	call movecursor

	mov cx, 3
	call clearbackground

	add dl, 4
	call movecursor

	mov cx, 3
	call clearbackground

	add dl, 4
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 3
	call clearbackground

	add dl, 4
	call movecursor

	mov cx, 3
	call clearbackground

	sub dl, 21
	inc dh
	call movecursor

	mov cx, 2
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 5
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 4
	call movecursor

	mov cx, 1
	call clearbackground

	sub dl, 21
	inc dh
	call movecursor

	mov cx, 2
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 3
	call clearbackground

	add dl, 4
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 5
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 4
	call movecursor

	mov cx, 3
	call clearbackground

	inc dh
	sub dl, 21
	call movecursor

	mov cx, 2
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 5
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 6
	call movecursor

	mov cx, 1
	call clearbackground

	sub dl, 23
	inc dh
	call movecursor

	mov cx, 2
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 3
	call clearbackground

	add dl, 5
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 3
	call movecursor

	mov cx, 1
	call clearbackground

	add dl, 2
	call movecursor

	mov cx, 3
	call clearbackground

	add dl, 4
	call movecursor

	mov cx, 3
	call clearbackground
	
	pop dx
	pop cx
	
	ret

	.position	db 0,0
















