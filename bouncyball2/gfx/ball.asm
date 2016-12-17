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
* 
* This is just a test to see how to set the video mode, and a hacky blit routine
* to display something.
*
*******************************************************************************

		org	$3F00

start		orcc	#$50

****************
; test code I use to load into edtasm and inspect results, commented out for actual program
;
;		jsr	setRGBPalette
;		ldd	#$0		; set position sprite
;		std	xpos		; store sprite position
;		ldu	#ball01		; point to sprite
;		jsr	blit		; show the sprite
;		swi
****************
		
;		sta	$FFD9		; high speed poke...doesn't matter what you store

*******************************************************************************
* Setup video mode
*******************************************************************************

		ldd	#$801A		; 256x192 16 colors
		std	$ff98		; GIME VMODE and VRES registers

		lda	#$44
		sta	$ff90		; GIME INIT0

		ldd	#$C000		; $60000/8 = $C000
		std	$FF9D		; Vertical offset register MSB & LSB

*******************************************************************************
* Setup MMU
*******************************************************************************

		; map GIME $60000-65FFF to 64K address space of $8000-DFFF
		ldd	#$3031		; GIME address ranges $60000-65FFF
		std	$FFA4		; GIME Banks at $8000-$9FFF and $A000-$BFFF
		lda	#$32		; GIME address range $66000-67FFF
		sta	$FFA6		; GIME Banks at $C000-$DFFF

*******************************************************************************
* Show the animation.
*
* Since this is just a test, it was easier to just store the sprite x & y position
* into memory, and pass in sprite on U reg. Ideally I would pass in the position
* in A & B regs, or on the user stack. Still need to research the best way.
*******************************************************************************
		ldd	#$3333
		jsr	cls
		jsr	setCMPPalette
		
blittest
		ldd	#$1010		; sprite x,y position
		std	xpos		; store sprite position
		ldu	#ball01		; point to sprite
		jsr	blit		; show the sprite
		jsr	delay
		
;		jmp	endlessloop
		
		ldd	#$1010
		std	xpos
		ldu	#ball02
		jsr	blit
		jsr	delay
		
		ldd	#$1010
		std	xpos
		ldu	#ball03
		jsr	blit
		jsr	delay
		
		ldd	#$1010
		std	xpos
		ldu	#ball04
		jsr	blit
		jsr	delay
		
		ldd	#$1010
		std	xpos
		ldu	#ball05
		jsr	blit
		jsr	delay
		
		ldd	#$1010
		std	xpos
		ldu	#ball05
		jsr	blit
		jsr	delay
		
		ldd	#$1010
		std	xpos
		ldu	#ball04
		jsr	blit
		jsr	delay
		
		ldd	#$1010
		std	xpos
		ldu	#ball03
		jsr	blit
		jsr	delay
		
		ldd	#$1010
		std	xpos
		ldu	#ball02
		jsr	blit
		jsr	delay
		
		ldd	#$1010
		std	xpos
		ldu	#ball01
		jsr	blit
		jsr	delay
		
		jsr	delay
		
		jmp 	blittest


*******************************************************************************
* Clear the screen
* Also have 3 other clear screens for testing purposes.
*
* IN: 	D reg contains the pattern to clear with
*******************************************************************************
cls		ldx	#$8000
l@		std	,x++
		cmpx	#$E000
		bne	l@
		rts

*******************************************************************************
* blit
*
* Caller sets the xpos and ypos and passes the sprite in U reg.
*******************************************************************************
xpos		fcb	$00		; horz byte position of the sprite (set before calling blit)
ypos		fcb	$00		; vert pixel position (row) of the sprite (set before calling blit)
width		fcb	$FF		; counter for the width of the sprite
height		fcb	$FF		; counter for the height of the sprite
addoffset	fcb	$80		; amount to add to dest ptr to get to the next line
tempword	fdb	$0000		; temp word variable

blit
		;jsr	cls		; clear the screen, makes it slower, but you can see the animation a little better. In the real world you would not do this, but this is just a hack
		ldd	,u		; pull sprite width and height
		std	width		; store in width and height counters

		tfr	a,b		; B = width
		lda	#$80		; screen width in bytes
		pshs	b		; Perform A = A-B ...
		suba	,s+		; ... A = A-B done
		sta	addoffset	; store temporarily

		tfr	u,y		; Y points to prince graphic ...
		leay	4,y		; ... sprite data is just after header

		; calculate x & y offset with X reg = ypos*screenwidth+xpos
		; xpos is a byte offset, not pixel offset
		lda	ypos
		ldb	#$80		; width of screen
		mul			; D=ypos*screenwidth
		addb	xpos		: D = ypos * screenwidth + xpos
		addd	#$8000		; memory offset
		tfr	d,x		; put offset into x
		
		ldb	addoffset	; grab the offset amount again
		
blit1		lda	,y+		; grab sprite data
		sta	,x+		; put onto display
		dec	width		; width counter
		bne	blit1		; keep blitting if we are not at the end of the sprite line

		dec	height		; height counter
		beq	blitdone	; jump out if we are done drawing the lines of the sprite
		abx			; point to next line (screenwidth-spritewidth)
		lda	,u		; grab the sprite width again ...
		sta	width		; ... so we can reset the width counter
		bra	blit1		; blit the next line

blitdone	rts

*******************************************************************************
* Just a hack in delay to slow the animation
*******************************************************************************
delay		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		rts


*******************************************************************************
* wait for a vsync
*******************************************************************************
vsync
	        lda $ff03
	        bpl vsync
	        lda $ff02
	        rts



*******************************************************************************
endlessloop	jmp	endlessloop



		;org	$5000

*******************************************************************************
* Each sprite contains a header, and sprite data. Currently the
* header contains width and height info. Later versions will also
* contain
*******************************************************************************

		include	ball01.inc
		include	ball02.inc
		include	ball03.inc
		include	ball04.inc
		include	ball05.inc
		include palette.asm

*******************************************************************************

		end 	start
