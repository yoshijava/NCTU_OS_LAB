segment _TEXT PUBLIC CLASS=CODE

[global _enableKey]
_enableKey:
	mov     al, 0AEh
	call	setCmd
	ret

[global _disableKey]
_disableKey:
	mov     al, 0ADh
    call	setCmd
    ret

setCmd:
    push    cx
    push    ax              ;Save command value.
    xor     cx, cx          ;Allow 65,536 times thru loop.
Wait4Empty:     
	in      al, 64h         ;Read keyboard status register.
    test    al, 10b         ;Input buffer full?
    loopnz  Wait4Empty      ;If so, wait until empty.

    pop     ax              ;Retrieve command.
    out     64h, al         ;Okay, ints can happen again.
    pop     cx
    ret


[global _getScanCode]
_getScanCode:
	push	bp
	mov		bp,sp
	mov		ax, 0				; init register bx
	in		al, 60h				; get scan code
	pop		bp
	ret

[global _setActiveShell]
_setActiveShell
	push	bp
	mov		bp, sp
	mov		cx, ds
	mov		bx, 0x500
	mov		ds, bx
	mov		bx, [bp+4]
	mov		[0x0004], bx
	mov		ds, cx
	pop		bp
	ret

[global _initHeadTail]
_initHeadTail:
	push	bp
	mov		bp,sp
	mov		cx, ds
	mov		dx, 0x40
	mov		ds, dx
	mov		ax, 0x1E
	mov		[0x1A], ax
	mov		[0x1C], ax			; empty keyboard buffer
	mov		ds, cx

	pop		bp
	ret		

[global _getHead]
_getHead:
	push	bp
	mov		bp,sp
	mov		dx, 0x40
	mov		cx, ds
	mov		ds, dx
	mov		ax, [0x1A]
	mov		ds, cx

	pop		bp
	ret

[global _getTail]
_getTail:
	push	bp
	mov		bp,sp
	mov		dx, 0x40
	mov		cx, ds
	mov		ds, dx
	mov		ax, [0x1C]
	mov		ds, cx

	pop		bp
	ret

[global _setTail]
_setTail:
	push	bp
	mov		bp,sp
	mov		ax, [bp+4]
	mov		dx, 0x40
	mov		cx, ds
	mov		ds, dx
	mov		[0x1C], ax
	mov		ds, cx

	pop		bp
	ret
	
[global _setKeyCode]
_setKeyCode:
	push	bp
	mov		bp,sp
	mov		ax, [bp+4]			; ax for code
	mov		cx, ds
	mov		dx, 0x40
	mov		ds, dx			
	mov		di, [0x1C]
	mov		[di], ax
	mov		ds, cx
	pop		bp
	ret
	
[global _eoi]
_eoi:
	push	bp
	mov		bp, sp
	mov		ax,  [bp+6]
	mov		sp, ax
	mov		ax,  [bp+4]
	mov		ds, ax
	mov		ss, ax
	pop		di
	pop		si
	pop		bp
	pop		dx
	pop		cx
	pop		bx
	pop		ax
	mov		al, 20h
	out		20h, al
	sti
	iret



segment _DATA PUBLIC CLASS=DATA
group dgroup _DATA _TEXT