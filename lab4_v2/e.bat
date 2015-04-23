tcc -mt -c vga.c
nasmw -f obj -o libvga.obj libvga.asm
nasmw -f obj -o s_vga.obj s_vga.asm
link s_vga.obj vga.obj libvga.obj spush.obj scopy.obj,vga.exe;
exe2bin vga.exe
del *.exe
