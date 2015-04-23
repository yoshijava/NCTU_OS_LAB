	jmp START
	db	0x10, 0x04	; file size is 1040 byte
    START:
	   	  mov	ax, 0x0900
	   	  mov	ds, ax
	   	  mov	ax, 5566
	CAL:
	   	  inc	ax
	   	  mov	[0x0], ax
	   	  jmp   CAL
