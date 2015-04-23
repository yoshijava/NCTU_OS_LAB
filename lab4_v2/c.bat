path=c:\nasm-0.98.39\;c:\tc;c:\tasm\bin;c:\windows\system32;c:\masm16;
tcc -mt -c sche.c
nasmw -f obj -o libsche.obj libsche.asm
nasmw -f obj -o s_sche.obj s_sche.asm
link s_sche.obj sche.obj libsche.obj spush.obj scopy.obj,sche.exe;
exe2bin sche.exe
del *.exe
