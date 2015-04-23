	ORG 0
	jmp START
	
    START:
    ; code located at 07C0:0000, adjust segment registers
        cli
        mov     ax, 0x07C0
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax
    ; create stack
        mov     ax, 0x0000
        mov     ss, ax
        mov     sp, 0xFFFF
        sti
	LOAD_KEYBOARD_DRIVER:
    	mov		ax, 0x0900
    	mov		es, ax
    	mov		bx, 0x0000
		mov     ah, 0x02                            ; BIOS read sector
		mov     al, 0x02                            ; read two sector
		mov     ch, 0					            ; track
		mov     cl, 10 					          	; sector	(exit on 0,0,10~11)
		mov     dh, 0					            ; head
		mov     dl, 0					            ; drive
		int     0x13 
	HOOK_INT9:
    	mov		cx, 0x0000							; offset
    	mov		ax, 0x0900							; segment
    	mov		bx, ds
		mov		dx, 0x0000
		mov		ds, dx
    	mov		[0x0024], cx
    	mov		[0x0026], ax
    	mov		ds, bx	
	LOAD_VGA_DRIVER:
    	mov		ax, 0x1000
    	mov		es, ax
    	mov		bx, 0x0000
		mov     ah, 0x02                            ; BIOS read sector
		mov     al, 0x03                            ; read three sector
		mov     ch, 0					            ; track
		mov     cl, 12 					          	; sector	(vga on 0,0,12~14)
		mov     dh, 0					            ; head
		mov     dl, 0					            ; drive
		int     0x13 
	HOOK_INT10:
    	mov		cx, 0x0000							; offset
    	mov		ax, 0x1000							; segment
    	mov		bx, ds
		mov		dx, 0x0000
		mov		ds, dx
    	mov		[0x0040], cx
    	mov		[0x0042], ax
    	mov		ds, bx	
		
	LOAD_SCHEDULER:
		mov		cl, 2								; SCHEDULER is on (0,0,2~3)
        mov     ax, 0x0600							; load scheduler into memory (0600:0000)
        mov     es, ax                              ; destination for image
        mov     bx, 0x0000                          ; destination for image
        call    ReadSectors

		mov		cl, 3								; SCHEDULER is on (0,0,2~3)
        mov     ax, 0x0600							; load scheduler into memory (0600:0000)
        mov     es, ax                              ; destination for image
        mov     bx, 0x0200                          ; destination for image
        call    ReadSectors

    LOAD_SHELL:
    	mov		ax, 0x0800
    	mov		es, ax
    	mov		bx, 0x0000
		mov     ah, 0x02                            ; BIOS read sector
		mov     al, 0x06                            ; read SIX sector
		mov     ch, 0					            ; track
		mov     cl, 4 					          	; sector	(shell is on (0,0,4~9)
		mov     dh, 0					            ; head
		mov     dl, 0					            ; drive
		int     0x13 

    	mov		ax, 0x1800
    	mov		es, ax
    	mov		bx, 0x0000
		mov     ah, 0x02                            ; BIOS read sector
		mov     al, 0x06                            ; read SIX sector
		int		0x13

    	mov		ax, 0x2800
    	mov		es, ax
    	mov		bx, 0x0000
		mov     ah, 0x02                            ; BIOS read sector
		mov     al, 0x06                            ; read SIX sector
		int		0x13

    	mov		ax, 0x3800
    	mov		es, ax
    	mov		bx, 0x0000
		mov     ah, 0x02                            ; BIOS read sector
		mov     al, 0x06                            ; read SIX sector
		int		0x13
		


    HOOK_INT1C:
		mov		al, 0
    	out		0x21, al
    	cli
    	mov		cx, 0x0000							; offset
    	mov		ax, 0x0600							; segment
    	mov		bx, ds
		mov		dx, 0x0000
		mov		ds, dx
    	mov		[0x0070], cx
    	mov		[0x0072], ax
    	mov		ds, bx
	RUN_SCHEDULER:
		mov		ax, 0x0500
		mov		ds, ax
		mov		ax, 0
		mov		[0x0], ax
		mov		[0x2], ax
		mov		ax, 1
		mov		[0x4], ax
		mov     ax, 0x0600
		mov     ds, ax
		mov		es, ax
		mov		gs, ax
		mov     ss, ax
		mov     sp, 0xfff0
        jmp		word 0x0600:0x0000					; jump to the scheduler!

     
     ;*************************************************************************
     ; PROCEDURE ReadSectors
     ; reads "cx" sectors from disk starting at "ax" into memory location "es:bx"
     ;*************************************************************************     	  
     ReadSectors:
          mov     ah, 0x02                            ; BIOS read sector
          mov     al, 0x01                            ; read one sector
          mov     ch, 0					              ; track
     ;    mov     cl, 3 					          ; sector	(scheduler is on (0,0,2)
          mov     dh, 0					              ; head
          mov     dl, 0					              ; drive
          int     0x13                                ; invoke BIOS
          ret


          TIMES 510-($-$$) DB 0
          DW 0xAA55

