[BITS 16]
[global start]
[extern _mymain]
[extern _saveSSSP]
segment _TEXT PUBLIC CLASS=CODE
start:
cli
push	ax
push	bx
push	cx
push	dx
push	bp
push	si
push	di
mov		ax, sp
mov		bx, ss
mov		cx, 0x0600
mov		ds, cx
mov		ss, cx
mov		sp, 0xfff0
push	ax
push	bx
call	_saveSSSP
pop		cx
pop		cx
call 	_mymain

segment _DATA PUBLIC CLASS=DATA
group dgroup _DATA _TEXT