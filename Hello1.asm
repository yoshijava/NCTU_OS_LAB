	ORG 0
	jmp START
	
	L1   db "[HELLO1] HELLO WORLD 1 (1000:0000)[" , 0x00
	L2	 db "]", 0x0d, 0x0a, 0x00

    START:
    
    	; push	'1'									; use as pid
    
    ; create stack
        mov     ax, 0x1000
        mov     ss, ax
        mov     sp, 0xFFFF
        sti
        
    ; code located at 1000:0000, adjust segment registers
        cli
        mov     ax, 0x1000
        mov     ds, ax
        mov     es, ax
        mov     fs, ax
        mov     gs, ax

		mov		al, '1'							; use ax as the the number


	SHOW:
		push	ax
		mov	  	si, L1    
    	call 	DisplayMessage
    	pop		ax
    	
    	mov		ah, 0x0e						; show the number
    	mov		bh, 0x00
    	mov		bl, 0x07
    	int		0x10
    	
    	push	ax
    	mov		si, L2
    	call	DisplayMessage
    	pop		ax
    	
    	add		al, 0x01						; if index >=9, then mod it with 9
		cmp		al, '9'
		jne		MOD_NINE
		mov		al, '1'
		
	MOD_NINE:		
		push	cs
		push	YIELD_BACK
    	jmp		0x0800:0xe8						; call yield
	YIELD_BACK:
		jmp		SHOW
    	

     ;*************************************************************************
     ; PROCEDURE DisplayMessage
     ; display ASCIIZ string at "ds:si" via BIOS
     ;*************************************************************************
     DisplayMessage:
          lodsb                                       ; load next character
          or      al, al                              ; test for NUL character
          jz      .DONE
          mov     ah, 0x0E                            ; BIOS teletype
          mov     bh, 0x00                            ; display page 0
          mov     bl, 0x07                            ; text attribute
          int     0x10                                ; invoke BIOS
          jmp     DisplayMessage
     .DONE:
          ret
          
     EXIT:
	 ; application done, jump back to scheduler
	 	  jmp		0x0800:0x0000