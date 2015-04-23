[BITS 16]
[global start]
[extern _mymain]
segment _TEXT PUBLIC CLASS=CODE
start:
call 	_mymain

segment _DATA PUBLIC CLASS=DATA
group dgroup _DATA _TEXT