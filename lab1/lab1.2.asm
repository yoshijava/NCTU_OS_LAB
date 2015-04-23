	 ORG 0
	 jmp START

	 CRLF db 0x0D, 0x0A, 0x00
	 L1   db "Select function", 0x0D, 0x0A, "1. Boot hello_1(0/0/3)",0x0D, 0x0A, "2. Boot hello_2(0/0/5)", 0x0D, 0x0A, "input ==> " , 0x00

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
     MENU:
          mov	  si, CRLF
          call 	  DisplayMessage
          CALL	  ShowPrompt
     INPUT:
          mov     ah, 0x00
          int     0x16                                ; await keypress
 		  cmp	  al, '1'							  ; user input = 1
 		  jz	  Hello1
 		  cmp	  al, '2'							  ; user input = 2
 		  jz	  Hello2

 		  jmp	  INPUT

;-----------------------------------------------------------------------------------
		  
     Hello1:
          mov	  cl, 3								  ; cl = sector = hello1 sector
          jmp proc
     Hello2:
     	  mov	  cl, 5								  ; cl = sector = hello2 sector
     	  jmp proc
	 	  
     proc:
     ; read image file into memory (0050:0000)
          mov     si, CRLF
          call    DisplayMessage
          mov     ax, 0x0050
          mov     es, ax                              ; destination for image
          mov     bx, 0x0000                          ; destination for image
     LOAD_IMAGE:
          call    ReadSectors
	 
	;*************************************************************************
	; Transfers control from a procedure back to the instruction address
	; saved on the stack.
	;*************************************************************************
     RUN:
     	  jmp 	  WORD 0x0050:0x0000 
     
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
     
     ShowPrompt:
     	  mov si, L1
     	  call DisplayMessage
     	  mov si, CRLF
     	  ret
     ;*************************************************************************
     ; PROCEDURE ReadSectors
     ; reads "cx" sectors from disk starting at "ax" into memory location "es:bx"
     ;*************************************************************************     	  
     ReadSectors:
          mov     ah, 0x02                            ; BIOS read sector
          mov     al, 0x01                            ; read one sector
          mov     ch, 0					              ; track
          mov     dh, 0					              ; head
          mov     dl, 0					              ; drive
          int     0x13                                ; invoke BIOS
          ret


          TIMES 510-($-$$) DB 0
          DW 0xAA55									  ; ¦bbootsectorªº§ÀºÝ¼g¤W55AA

