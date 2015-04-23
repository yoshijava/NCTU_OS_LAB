     START:
	     CLI                    ; disable int's
	     XOR     AX,AX          ; set stack seg to 0000
	     MOV     SS,AX
	     MOV     SP,0x7C00        ; set stack ptr to 7c00
	     MOV     SI,SP          ; SI now 7c00
	     PUSH    AX
	     POP     ES             ; ES now 0000:7c00
	     PUSH    AX
	     POP     DS             ; DS now 0000:7c00
	     STI                    ; allow int's
	     CLD                    ; clear direction
	     MOV     DI,0x0600        ; DI now 0600
	     MOV     CX,0x0100        ; move 256 words (512 bytes)
	     REPNZ                  ; move MBR from 0000:7c00
	     MOVSW                  ;    to 0000:0600
	     JMP     word 0x0000:0X061D      ; jmp to NEW_LOCATION

;-----------------------------------------------------------------------------------
		  

	 	  
     proc:
     ; read image file into memory (07C0:0000)

          mov     ax, 0x0000
          mov     es, ax                              ; destination for image
          mov     bx, 0x7C00                          ; destination for image
		  
     LOAD_IMAGE:

	 ; read mbr
	 	  call	  ReadSectors
		  jmp	  WORD 0x0000:0x7C00
		  
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
     
     ;*************************************************************************
     ; PROCEDURE ReadSectors
     ; reads "cx" sectors from disk starting at "ax" into memory location "es:bx"
     ;*************************************************************************     	  
     ReadSectors:
          mov     ah, 0x02                            ; BIOS read sector
          mov     al, 0x01                            ; read one sector
          mov     ch, 0					              ; track
          mov     cl, 1 					          ; sector	(decided by menu input)
          mov     dh, 0					              ; head
          mov     dl, 0x80				              ; drive
          int     0x13                                ; invoke BIOS
          ret

          TIMES 510-($-$$) DB 0
          DW 0xAA55

