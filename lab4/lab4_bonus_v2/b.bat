path=c:\nasm-0.98.39\;c:\tc;c:\tasm\bin;c:\windows\system32;c:\masm16;
nasmw bootloader.asm
tcc -mt -c shell.c
nasmw -f obj -o libshell.obj libshell.asm
nasmw -f obj -o s_shell.obj s_shell.asm
link s_shell.obj shell.obj libshell.obj,shell.exe;
exe2bin shell.exe
del *.exe
