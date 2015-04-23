[BITS 16]
[global start]
[extern _mymain]
[extern _saveChar]
[extern _setScrIndex]
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
mov		si, bx
mov		dx, ax
mov		ax, sp
mov		bx, ss
mov		cx, 0x1000
mov		ds, cx
mov		ss, cx
mov		sp, 0xfff0
push	ax
push	bx
call	_saveSSSP
pop		cx
pop		cx
push	dx
call	_saveChar
pop		cx
push	si
call	_setScrIndex
pop		cx
call 	_mymain

segment _DATA PUBLIC CLASS=DATA
group dgroup _DATA _TEXT