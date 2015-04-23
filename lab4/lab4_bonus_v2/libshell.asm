segment _TEXT PUBLIC CLASS=CODE

[global _notifyScheduler]
_notifyScheduler:
	cli
	push	bp
	mov		bp, sp
	mov		cx, ds
	mov		ax, 0x0500
	mov		ds, ax
	mov		ax, 1						; 1 for add application to scheduler
	mov		[0x0000], ax
	mov		ax, [bp+4]
	mov		[0x0002], ax				; the segment to add
	pop		bp
	mov		ds, cx
	sti
	int		1ch
	ret

[global _setUsedAsm]
_setUsedAsm:
	push	bp
	mov		bp, sp
	mov		cx, ds
	mov		bx, 0x500
	mov		ds, bx
	mov		ax, [bp+4]
	mov		[0x6], ax
	mov		ds, cx
	pop		bp
	ret

[global _getUsedAsm]
_getUsedAsm:
	push	bp
	mov		bp, sp
	mov		cx, ds
	mov		bx, 0x500
	mov		ds, bx
	mov		ax, [0x6]
	mov		ds, cx
	pop		bp
	ret
	
[global _disassemble]
_disassemble:
	; segment, offset
	push	bp
	mov		bp,sp
	mov		ax,[bp+4]
	mov		bx,[bp+6]
	mov		cx,ds						; current data segment
	mov		ds, ax
	mov		ax,[bx]
	mov		ds,cx
	pop		bp
	ret

[global _getShellID]
_getShellID:
	push	bp
	mov		bp, sp
	mov		cx, ds
	cmp		cx, 0x1800
	je		shell2
	cmp		cx, 0x2800
	je		shell3
	cmp		cx, 0x3800
	je		shell4
	mov		ax, 1
	jmp		goback
shell2:
	mov		ax, 2
	jmp		goback
shell3:
	mov		ax, 3
	jmp		goback
shell4:
	mov		ax, 4
goback:	
	pop		bp
	ret

[global _getActiveShell]
_getActiveShell:
	push	bp
	mov		bp, sp
	mov		cx, ds
	mov		bx, 0x0500
	mov		ds, bx
	mov		ax, [0x0004]
	mov		ds, cx
	pop		bp
	ret

[global _readHeader]
_readHeader:
	push	bp
	mov		bp,sp
	mov		cx, ds
	mov		ax, 0x400
	mov		ds, ax
	mov		bx, [bp+4]
	mov		ax, [bx]
	mov		ds, cx
	pop		bp
	ret

[global _putchar]
_putchar:
	push  	bp
	mov  	bp,sp
	call	_getShellID
	mov		bx, ax
	mov 	ah,0Eh
	mov  	al,[bp+4]
	int  	10h
	mov		sp,bp
	pop  	bp
	ret

[global _yield]
_yield:
	int		1ch
	ret

[global _checkKeystroke]
_checkKeystroke:
	mov		ah, 01h
	int		16h
	jnz		hasInput
	mov		ax,0
	ret
hasInput:
	mov		ax, 1
	ret

[global _getchar]
_getchar:
	push	bp
	mov		bp, sp
	mov     ah, 00h
    int     16h								; user input is in reg. al
	xor		ah, ah
	mov		sp,bp
	pop		bp
	ret

[global _readSector]
_readSector:
	;**************************
	; C.H.S = bp+4, bp+6, bp+8
	; length = bp+10
	; seg:off = bp+12 : bp+14
	;**************************

	push 	bp
	mov		bp, sp
	push	ax
	push	es
	push	bx
	push	cx
	push	dx

    mov     ax, [bp+12]							  ;load scheduler into memory (0600:0000)
    mov     es, ax          	                  ; destination for image
    mov     bx, [bp+14]		                      ; destination for image
	mov     ah, 0x02            	              ; BIOS read sector
	mov     al, [bp+10]     	                  ; read one sector
	mov     ch, [bp+4]				              ; track
	mov     cl, [bp+8] 					          ; sector
	mov     dh, [bp+6]				              ; head
	mov     dl, 0					              ; drive
	int     0x13                    	          ; invoke BIOS
	pop		dx
	pop		cx
	pop		bx
	pop		es
	pop		ax
	pop		bp
	ret


segment _DATA PUBLIC CLASS=DATA
group dgroup _DATA _TEXT