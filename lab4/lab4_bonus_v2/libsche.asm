segment _TEXT PUBLIC CLASS=CODE

[global _run]
_run:
	; ss, sp
	; not need to handle proper stack structure, because it is going to switch to another program
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
    mov		al,20h
	out		20h, al	
	sti
	iret

[global _runFirstTime]
_runFirstTime:
	; ss, sp
	; only care about ss 
	push	bp
	mov		bp, sp
	mov		ax,  [bp+6]
	mov		sp, ax
	mov		ax,  [bp+4]
	mov		ds, ax
	mov		ss, ax
    mov		al,20h
	out		20h, al	
	sti
	push	ds
	push	0
	retf

[global _getJobNumber]
_getJobNumber:
	mov		bx, 500h
	mov		ds, bx
	mov		ax, [0h]
	mov		bx, 600h
	mov		ds, bx
	ret

[global _getSegment]
_getSegment:
	mov		bx, 500h
	mov		ds, bx
	mov		ax,  [2h]
	mov		bx, 600h
	mov		ds, bx
	ret

[global _clearJob]
_clearJob:
	mov		bx, 500h
	mov		ds, bx
	mov		ax, 0
	mov		[0h], ax
	mov		[2h], ax
	mov		bx, 600h
	mov		ds, bx
	ret
	
[global _cli]
_cli:
	cli
	ret

[global _sti]
_sti:
	sti
	ret

[global _out20]
_out20:
    mov		al,20h
	out		20h, al							; let timer interrupt could happen
	ret
	


segment _DATA PUBLIC CLASS=DATA
group dgroup _DATA _TEXT