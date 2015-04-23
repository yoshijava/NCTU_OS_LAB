	jmp START
	db	0x00, 0x01	; file size is 256 byte
	L1   db "[HELLO1] HELLO WORLD 1 " , 0x0d, 0x0a, 0x00

    START:
		cli
		mov	  	si, L1    
    	call 	DisplayMessage
    	jmp		EXIT

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
	 ;  application done, jump back to scheduler
	   	  mov	ax, 0x0500
	   	  mov	ds, ax
	   	  mov	ax, 2
	   	  mov	[0x0], ax
	   	  mov	ax, cs
	   	  mov	[0x2], ax
	   	  sti
	   	  jmp	0x0600:0x0000