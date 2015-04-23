	 ORG 0
	 jmp START
	 
	 CRLF		  db 0x0D, 0x0A, 0x00
	 Hello		  db "Hello World", 0x00

     START:
     ; code located at 0000:7C00, adjust segment registers
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
     ; post message
          mov     si, Hello
          call    DisplayMessage
          mov	  si, CRLF
          call 	  DisplayMessage
          mov     ah, 0x00
          int     0x16                                ; await keypress
	      jmp	  START

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


          TIMES 510-($-$$) DB 0
          DW 0xAA55									  ; ¦bbootsectorªº§ÀºÝ¼g¤W55AA

