path=c:\nasm-0.98.39\;c:\tc;c:\tasm\bin;c:\windows\system32;c:\masm16;
tcc -mt -c kbdrv.c
nasmw -f obj -o libkbdrv.obj libkbdrv.asm
nasmw -f obj -o s_kbdrv.obj s_kbdrv.asm
link s_kbdrv.obj kbdrv.obj libkbdrv.obj spush.obj scopy.obj,kbdrv.exe;
exe2bin kbdrv.exe

