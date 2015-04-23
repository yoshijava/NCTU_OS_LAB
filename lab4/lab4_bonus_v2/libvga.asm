segment _TEXT PUBLIC CLASS=CODE

[global _show]
_show:
	push	bp
	mov		bp, sp
	mov		ax, [bp+4]
	mov		bx, [bp+6]
	mov		cx, ds
	mov		dx, 0xb800
	mov		ds, dx
	mov		[si],bx
	mov		ds, cx
	pop		bp
	ret

[global _iret]
_iret:
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
	sti
	iret


segment _DATA PUBLIC CLASS=DATA
group dgroup _DATA _TEXT