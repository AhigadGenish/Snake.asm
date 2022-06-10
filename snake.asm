; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ex4.asm
; 29/05/2022
; Ahigad_Genish_316228022
; Omer_Sela_316539535
; Description: This code is mini-snake Game
; to play press - W: up , D: right, A: left , S: down , Q: exit
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.model small
.stack 500h
.data

	row db 12d										; player location
	col db 80d
	A db 9Eh										; BCD of the key on keyBoard
	S db 9Fh
	D db 0A0h
	W db 91h
	Q db 90h
	locX dw 0d										; object location
	score db 0										; score
	msg_score db 'Score: ',0,0,'$'
	oldOff dw 0										; modify interrupt
	oldSeg dw 0
	counter db 4									; slow speed rate
	lastPressed db -1d								; remember last pressed key -1: nothing pressed , 0-A, 1-S,2-D,3-W
	
.code
	


;input : current locatin - row,col
; output: new location, row,col print blank blue on the previous loc and print player new location
left proc uses ax bx cx dx bp es ds

	mov bx,0b800h
	mov es,bx
	mov ah , ds:[col]			; check if position is on edge of screen		
	cmp ah,0					; if yes: stay there
	jz finish_left
								
								; else:
	mov al,ds:[row]				; delete the last position of the player on screen
	mov ah,0
	mov cl , 160d
	mul cl
	mov dl,ds:[col]
	mov dh,0
	add ax,dx
	mov bp,ax
	xor bx,bx
	mov es:[bp],bx
	
	sub ax,2
		
	mov bl,4fh					; print new position
	mov bh,0ch
	mov bp,ax
	mov es:[bp],bx
	
	xor ax,ax					; update new position in memory
	mov al,ds:[col]
	sub al,2
	mov ds:[col],al
	
	
	
	
finish_left:
	ret


left endp

;input : current locatin - row,col
; output: new location, row,col print blank blue on the previous loc and print player new location
right proc uses ax bx cx dx bp es

	mov bx,0b800h
	mov es,bx
	mov ah , ds:[col]			; check if position is on edge of screen
	cmp ah, 0A0h-2h				; if yes: stay there
	jz finish_right
	
	mov al,ds:[row]				; delete the last position of the player on screen
	mov ah,0
	mov cl , 160d
	mul cl
	mov dl,ds:[col]
	mov dh,0
	add ax,dx
	mov bp,ax
	xor bx,bx
	mov es:[bp],bx
	
	add ax,2
		
	mov bl,4fh					; print new position
	mov bh,0ch
	mov bp,ax
	mov es:[bp],bx
	
	xor ax,ax					; update new position in memory
	mov al,ds:[col]
	add al,2
	mov ds:[col],al
	
	
	
finish_right:

	ret


right endp

;input : current locatin - row,col
; output: new location, row,col print blank blue on the previous loc and print player new location
up proc uses ax bx cx dx bp es

	mov bx,0b800h
	mov es,bx
	mov ah , ds:[row]			; check if position is on edge of screen
	cmp ah, 0					; if yes: stay there
	jz finish_up
	
	
	
	mov al,ds:[row]				; delete the last position of the player on screen
	mov ah,0
	mov cl , 160d
	mul cl
	mov dl,ds:[col]
	mov dh,0
	add ax,dx
	mov bp,ax
	xor bx,bx
	mov es:[bp],bx
	
	sub ax,0A0h
		
	mov bl,4fh					; print new position
	mov bh,0ch
	mov bp,ax
	mov es:[bp],bx
	
	xor ax,ax					; update new position in memory
	mov al,ds:[row]
	sub al,1
	mov ds:[row],al
	
	
	
finish_up:
	ret

up endp

;input : current locatin - row,col
; output: new location, row,col print blank blue on the previous loc and print player new location
down proc uses ax bx cx dx bp es

	mov bx,0b800h
	mov es,bx
	mov ah , ds:[row]			; check if position is on edge of screen
	cmp ah, 24d					; if yes: stay there
	jz finish_down
	
	
	mov al,ds:[row]				; delete the last position of the player on screen
	mov ah,0
	mov cl , 160d
	mul cl
	mov dl,ds:[col]
	mov dh,0
	add ax,dx
	mov bp,ax
	xor bx,bx
	mov es:[bp],bx
	
	add ax,0A0h
		
	mov bl,4fh					; print new position
	mov bh,0ch
	mov bp,ax
	mov es:[bp],bx
	
	xor ax,ax					; update new position in memory
	mov al,ds:[row]
	add al,1
	mov ds:[row],al
	
	
finish_down:

	ret

down endp


;output : generate random location of 'X' object and update at memory and print
randomX proc uses ax bx cx dx bp ds es 
	
	mov bx , 0b800h				 ; screen memory
	mov es , bx

	random:
	
		mov al,02d               ; command : get minutes
		out 70h,al
		in al, 71h
		mov cl,al
	
	
		mov al,00d               ; command : get seconds
		out 70h,al
		in al, 71h
		mov ch,al
		
		mov ax,cx				 ; ax = cx
		mov bx,2000d			 ; bx = 2000d
		div word ptr bx		 	 ; ax /= 2000d , dx = ax%2000d
		mov cx,ds:[locX]		 ; cx = prevevois locX
		shl dx,1
		cmp cx,dx				 ; if (cx == dx) goto random again - when the last location is the same to the new
		
	je random
	
		mov ds:[locX],dx		 ; update new position
		mov bl,58h			     ; bx = red 'X'
		mov bh,0ch
		mov bp,dx
		mov es:[bp],bx		     ; print es:[locX] , bx
		
	ret
	
	
randomX endp

;this function check if the position of 'O' and 'X' are the same, if yes , update score and call to generate new 'X'

samePos proc uses ax bx cx dx bp ds

	mov bx,ds:[locx]            ; bx hold X location
	
	
	mov al,ds:[row]				; ax hold O location
	mov ah,0
	mov cl , 160d
	mul cl
	mov dl,ds:[col]
	mov dh,0		
	add ax,dx					
	
	cmp ax,bx					; if(ax == bx) update score and call randomX
	jne exit
		xor dx,dx
		mov dl,ds:[score]
		inc dl                  ; dl += 1
		mov ds:[score],dl		; update score in memory
	    call randomX
		
		
	exit:						; else return
		ret 
	
	
samePos endp

; outPut: this function print score to the screen.
printScore proc uses ax bx cx dx si bp ds
	
	xor ax,ax
	mov al, ds:[score]			; al = score
	mov bl, 10d
	div bl						; al /= 10 , ah= al%10
	add ax,3030h				; convert to ascii
	mov ds:[msg_score+7],al		; update in memory
	mov ds:[msg_score+8],ah
	
	mov dx, offset msg_score	; interrupt print string
	mov ah, 9h
	int 21h
	
	
	ret
printScore endp

	
;this label is modify the 1Ch interrupt that called by 08h interrupt every 55 msec
;this label update counter in memory to slow the rate speed of 'O' move
game:
	
	push ds
	push cx
	
	mov cl ,ds:[counter]			; cl = counter
	cmp cl,0						; if cl == 0 jmp play
	je play
		
		dec cl						; else : c -= 1
		mov ds:[counter],cl			; counter = cl
		jmp done
	
	play:
		mov cl,4					; cl = 4
		mov ds:[counter],cl			; counter = cl
	
done:
	

	pop cx
	pop ds 
	

	jmp DWORD ptr ds:[oldOff]		; jmp to continue the original interrupt
	

MAIN:

	.startUp						; set data memory
	mov bx, 0B800h					; screen memory
	mov es,	bx
	mov bp, 0						; print black space counter
	xor ax,ax						; ax = 0 

	
	loop1:
	
		mov es:[bp],ax				; print black space
		add bp,2

	cmp bp,4000d					; end of screen
	jne loop1
	
			
		in al,21h					; mask keyboard interrupt 
		or al,2h
		out 21h,al
		
		mov bl,4fh					; initial print O player in the center of the screen
		mov bh,0ch
		mov es:[160d*12d+80d],bx
	
	
		checkLoop:						; check if 'X' first position is the same as 'O'
		
			call randomX
			mov bx,ds:[locx]            ; bx hold X location
	
	
			mov al,ds:[row]				; ax hold O location
			mov ah,0
			mov cl , 160d
			mul cl
			mov dl,ds:[col]
			mov dh,0		
			add ax,dx
			
			mov bl,4fh					; initial print 'O' player in the center of the screen
			mov bh,0ch
			mov es:[160d*12d+80d],bx			
	
			cmp ax,bx					; if(ax == bx) choose another position to 'X'
			
		je checkLoop
	
	
	
		
		push cx 						; save CS,IP of old interrupt 1Ch before modify IVT to point to game label
		push bp
		push bx
		push es
		
		mov bx ,1ch
		mov cl,2
		shl bx,cl
		xor cx,cx
		mov es,cx
		mov bp, es:[bx]
		mov ds:[oldOff],bp
		mov bp, es:[bx+2]
		mov ds:[oldSeg],bp
	
		
		
		cli								; mask interrupt 
		mov es:[bx],offset game			; point to game label
		mov es:[bx+2],seg game
		sti
		
		
		pop es
		pop bx
		pop bp
		pop cx
		
		
		
		
		loopQ:							; move loop 
		
			in al,64h					; check if key pressed			
			test al,01h
			jz loopQ
			pressed:
			in al,60h					; get key from keyBoard
			mov dl,ds:[Q]               ; check if the last pressed key is Q
			cmp al,dl
				je stop_game			; if yes , done
				
				mov cl,ds:[counter] 	; slow moving to move every 0.165 ms
				cmp cl,4
				jne pressed
				
				mov dl,ds:[A]			; check if the last pressed key is A
				cmp al,dl
					je leftProc			; if yes move left
				mov dl,ds:[S]			; check if the last pressed key is S	
				cmp al,dl
					je downProc			; if yes move down
				mov dl,ds:[D]			; check if the last pressed key is D
				cmp al,dl
					je rightProc		; if yes move right
				mov dl,ds:[W]			; check if the last pressed key is W
				cmp al,dl
					je upProc			; if yes move up
					
				
				mov ch, ds:[lastPressed]
				cmp ch,0d
					je leftProc
				cmp ch,1d
					je 	downProc
				cmp ch,2d
					je 	rightProc
				cmp ch,3d
					je 	upProc
				cmp ch,-1d
					jmp loopQ
			
				leftProc:
					mov ds:[lastPressed],0 ; update lastPressed
					call left		    ; move left
					call samePos		; check 'X' and 'O' position
					mov cl,3			; only one move every three iterations
					mov ds:[counter],cl
					jmp pressed
					
				downProc:
					mov ds:[lastPressed],1 ; update lastPressed
					call down		    ; move down
					call samePos		; check 'X' and 'O' position
					mov cl,3			; only one move every three iterations
					mov ds:[counter],cl
					jmp pressed
					
				rightProc:
					mov ds:[lastPressed],2 ; update lastPressed
					call right		    ; move right
					call samePos		; check 'X' and 'O' position
					mov cl,3			; only one move every three iterations
					mov ds:[counter],cl
					jmp pressed
					
				upProc:
					
					mov ds:[lastPressed],3 ; update lastPressed
					call up		   		; move up
					call samePos		; check 'X' and 'O' position
					mov cl,3			; only one move every three iterations
					mov ds:[counter],cl
					jmp pressed
					
						
			
		jmp loopQ
		
		
		
	stop_game:							; when Q is pressed
	
	    
		push es
		push dx
		push ax
		push bx
		push cx
		
		mov bx ,1ch						; return old IVT address that store in memory
		mov cl,2
		shl bx,cl
		mov ax,ds:[oldOff]
		mov dx,ds:[oldSeg]
		xor cx,cx
		mov es,cx
		cli								; mask interrupts
		mov es:[bx],ax
		mov es:[bx+2],dx
		sti
		pop cx
		pop bx 
		pop ax
		pop dx
		pop es
		
	
		call printScore					; print score to screen
		mov al,0						; return keyBoard interrupt
		out 21h,al
	
	
		
	.exit								; return to OS
	

end MAIN
