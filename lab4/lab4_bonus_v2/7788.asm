	jmp START
	db	0x00, 0x02	; file size is 512 byte
    START:
	   	  mov	ax, 0x0900
	   	  mov	ds, ax
	   	  mov	ax, 7788
	CAL:
	   	  inc	ax
	   	  mov	[0x2], ax
	   	  jmp   CAL
          
