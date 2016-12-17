*******************************************************************************
* www.8BitCoder.com
*
* Graphics and blit test running at 256x192 16 color mode.
*
* Tabs set to 8 and using real tabs, not spaces.
* 
* Compile: 
* lwasm -9 -b -o ball.bin ball.asm && writecocofile --verbose gfx.dsk ball.bin && coco3 `pwd`/gfx.dsk ball
* lwasm -l -9 -b -o ball.bin ball.asm > ball.lst && writecocofile --verbose gfx.dsk ball.bin #&& coco3 `pwd`/gfx.dsk ball
* lwasm -l -9 -b -o ball.bin ball.asm > ball.lst && writecocofile --verbose gfx.dsk ball.bin && writecocofile ~/Downloads/EDTASM6309/CC3/ed.dsk ball.bin #&& coco3 `pwd`/gfx.dsk ball
* 
* This is just a test to see how to set the video mode, and a hacky blit routine
* to display something.
*
*******************************************************************************
PALETTE_ADDR 	equ	$FFB0

rgbColorValues	fcb	18,54,09,36,63,27,45,38,00,18,00,63,00,18,00,38
cmpColorValues	fcb	18,36,11,07,63,31,09,38,00,18,00,63,00,18,00,38

setRGBPalette   pshs	x
		ldx	#rgbColorValues
		jsr	setPalette
		puls	x
		rts
		
setCMPPalette	pshs	x
		ldx	#cmpColorValues
		jsr	setPalette
		puls	x
		rts

*******************************************************************************
* setPalette
*
* Set the palette to the specified color values. Color values should be 16 
* bytes long.
*
* IN:	X = color values
*******************************************************************************		
setPalette	pshs	x,y,d
		ldy	#PALETTE_ADDR
		ldb	#16
r@		lda	,x+
		sta	,y+
		decb
		bne	r@
		puls	d,y,x
		rts
