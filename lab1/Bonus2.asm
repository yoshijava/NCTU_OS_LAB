		CLI                    ; disable interrupts
		XOR     AX,AX          ; set stack seg to 0000
		MOV     SS,AX
		MOV     SP,0x7C00      ; set stack ptr to 7c00
		MOV     SI,SP          ; SI now 7c00
		PUSH    AX
		POP     ES             ; ES now 0000:7c00
		PUSH    AX
		POP     DS             ; DS now 0000:7c00
		STI                    ; allow interrupts
		CLD                    ; clear direction
		MOV     DI,0x9000      ; DI now 0600
		MOV     CX,0x0100      ; move 256 words (512 bytes)
		REPNZ                  ; move MBR from 0000:7c00
		MOVSW                  ; to 0000:0600  (把自己搬到 0000:9000)
		JMP     0x0000:0x901D  ; jmp to NEW_LOCATION

;------- 0x0000:0x901D 從下面開始 --------------------------------------------

     ; read HD's MBR into memory (0000:0600)
		mov     ax, 0x0000
		mov     es, ax                                ; destination for image
		mov     bx, 0x0600                            ; destination for image
		  
	 ; read mbr
		call	ReadSectors
		mov	  	si, 0x07BE						  	  ; point to first table entry (0600 + 01BE)
		  
	 ; Read partition table information (假設partition table第一個即為bootable)
	 ; 判斷是否為active entry，即判斷 [si] 是否等於 0x80，0x00 則不為active
	 
	 
		mov	  	dx, [si]							  ; set DH/DL for int 0x13 call
		mov	  	cx, [si+02]						  	  ; set CH/CL for int 0x13 call
		mov	  	bp, si							  	  ; save table ptr
	
	 ; Load partition table entry info into memory (0000:7c00)	  
		mov	  	ax, 0x0000
		mov	  	es, ax
		mov	  	bx, 0x7c00
		call	ReadSectors
		jmp	  	0x0000:0x7c00						  ; 跳過去執行
		  
     
     ;****************************************************************************
     ; PROCEDURE ReadSectors
     ; reads "cx" sectors from disk starting at "ax" into memory location "es:bx"
     ;****************************************************************************     	  
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
          DW 0xAA55									  ; 在bootsector的尾端寫上55AA

