*******************************************************************************
* www.8BitCoder.com
*
* Graphics and sprite test running at 256x192 16 color mode.
*
* Tabs set to 8 and using real tabs, not spaces.
* Compile: lwasm -9 -b -o gfx.bin gfx.asm && writecocofile --verbose gfx.dsk gfx.bin
*
* This is just a test to see how to set the video mode, and a hacky blit routine
* to display something.
*
*******************************************************************************

SPEAKER_LEFT	equ	$FF7A
SPEAKER_RIGHT	equ	$FF7B

		org	$3F00

start		orcc	#$50
		
		sta	$FFD9		; high speed poke...doesn't matter what you store

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
		jsr	cls
		jsr	setRGBPalette
		
		;jsr	cls1
		;jsr	cls2
		;jsr	cls3
;		jsr	rainbow
;		jmp	endlessloop

		; position the sprite
		lda	#$35
		sta	xpos
		lda	#$50
		sta	ypos

		; point to the correct sprite frame, and blit it
blittest
		ldu	#prince01
		jsr	blit
		ldu	#prince02
		jsr	blit
		ldu	#prince03
		jsr	blit
		ldu	#prince04
		jsr	blit
		ldu	#prince05
		jsr	blit
		ldu	#prince06
		jsr	blit
		ldu	#prince07
		jsr	blit
		ldu	#prince08
		jsr	blit
		ldu	#prince09
		jsr	blit
		ldu	#prince10
		jsr	blit
		ldu	#prince11
		jsr	blit
		ldu	#prince12
		jsr	blit
		ldu	#prince13
		jsr	blit
		ldu	#prince14
		jsr	blit
		ldu	#prince15
		jsr	blit
		ldu	#prince16
		jsr	blit
		ldu	#prince17
		jsr	blit
		ldu	#prince10
		jsr	blit
		ldu	#prince11
		jsr	blit
		ldu	#prince12
		jsr	blit
		ldu	#prince13
		jsr	blit
		ldu	#prince14
		jsr	blit
		ldu	#prince15
		jsr	blit
		ldu	#prince16
		jsr	blit
		ldu	#prince17
		jsr	blit
		ldu	#prince10
		jsr	blit
		ldu	#prince11
		jsr	blit
		ldu	#prince12
		jsr	blit
		ldu	#prince13
		jsr	blit
		ldu	#prince14
		jsr	blit
		ldu	#prince15
		jsr	blit
		ldu	#prince16
		jsr	blit
		ldu	#prince17
		jsr	blit
		ldu	#prince10
		jsr	blit
		ldu	#prince11
		jsr	blit
		ldu	#prince12
		jsr	blit
		ldu	#prince13
		jsr	blit
		ldu	#prince14
		jsr	blit
		ldu	#prince15
		jsr	blit
		ldu	#prince16
		jsr	blit
		ldu	#prince17
		jsr	blit
		ldu	#prince10
		jsr	blit
		ldu	#prince11
		jsr	blit
		ldu	#prince12
		jsr	blit
		ldu	#prince13
		jsr	blit
		ldu	#prince14
		jsr	blit
		ldu	#prince15
		jsr	blit
		ldu	#prince16
		jsr	blit
		ldu	#prince17
		jsr	blit
		ldu	#prince10
		jsr	blit
		ldu	#prince11
		jsr	blit
		ldu	#prince12
		jsr	blit
		ldu	#prince13
		jsr	blit
		ldu	#prince14
		jsr	blit
		ldu	#prince15
		jsr	blit
		ldu	#prince16
		jsr	blit
		ldu	#prince17
		jsr	blit
		ldu	#prince10
		jsr	blit
		ldu	#prince11
		jsr	blit
		ldu	#prince12
		jsr	blit
		ldu	#prince13
		jsr	blit
		ldu	#prince14
		jsr	blit
		ldu	#prince15
		jsr	blit
		ldu	#prince16
		jsr	blit
		ldu	#prince17
		jsr	blit
		ldu	#prince10
		jsr	blit
		ldu	#prince11
		jsr	blit
		ldu	#prince12
		jsr	blit
		ldu	#prince13
		jsr	blit
		ldu	#prince14
		jsr	blit
		ldu	#prince15
		jsr	blit
		ldu	#prince16
		jsr	blit
		ldu	#prince17
		jsr	blit
		ldu	#prince18
		jsr	blit
		ldu	#prince19
		jsr	blit
		ldu	#prince21
		jsr	blit
		jmp 	blittest

*******************************************************************************
* test 1
*******************************************************************************
		jsr	cls1
		jsr	cls2
		jsr	cls3

		ldx	#$8000
		ldy	#pattern

loop1		lda	,y+
		sta	,x+
		cmpy	#patternend
		bne	loop1

		jsr	line1

done1		jmp	done1

pattern
			; 32 bytes x 4 lines = 128 bytes or 256 pixels
		fcb	$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00
		fcb	$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00
		fcb	$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00
		fcb	$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00

		fcb	$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11
		fcb	$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11
		fcb	$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11
		fcb	$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11,$00,$11

patternend	fcb	$00

*******************************************************************************
* Clear the screen
* Also have 3 other clear screens for testing purposes.
*
* IN: 	D reg contains the pattern to clear with
*******************************************************************************
; clear to green
cls		ldx	#$8000
		ldd	#$0000
l@		std	,x++
		cmpx	#$E000
		bne	l@
		rts

; clear first 8K block a different color
cls1		ldx	#$8000
		ldd	#$1111
cls11		std	,x++
		cmpx	#$A000
		bne	cls11
		rts

; clear the second 8k block a different color
cls2		ldx	#$A000
		ldd	#$7777
cls22		std	,x++
		cmpx	#$C000
		bne	cls22
		rts

; clear the third 8k block a different color
cls3		ldx	#$C000
		ldd	#$3333
cls33		std	,x++
		cmpx	#$E000
		bne	cls33
		rts

*******************************************************************************
* Draw a line (purposely not drawing all the way across)
*******************************************************************************
;line1		ldx	#$DF80
line1		ldx	#$8000
		ldd	#$4444
		ldy	#63
line1_loop	std	,x++
		leay	-1,y
		bne	line1_loop

		ldx	#$DFFF
		lda	#$10
		sta	,x

		rts

*******************************************************************************
* blit
*
* Caller sets the xpos and ypos and passes the sprite in U reg.
*******************************************************************************
width		fcb	$FF		; counter for the width of the sprite
height		fcb	$FF		; counter for the height of the sprite
addoffset	fcb	$80		; amount to add to dest ptr to get to the next line
xpos		fcb	$00		; horz position of the sprite (set before calling blit)
ypos		fcb	$00		; vert position of the sprite (set before calling blit)
tempword	fdb	$0000		; temp word variable

blit
		;jsr	cls		; clear the screen, makes it slower, but you can see the animation a little better. In the real world you would not do this, but this is just a hack
		ldd	,u		; pull sprite width and height
		std	width		; store in width and height counters

		; figure out how much we will be adding to the display pointer after each sprite line is drawn to move pointer to next line
		lda	#$80		; width of screen
		ldb	width		; width of sprite
		pshs	b		; A = A - B ...
		suba	,s+		; ...
		sta	addoffset	; ... store offset amount

		; calculate the display offset given the desired x & y position
		; X reg = ypos*$80+xpos
		lda	ypos		; ypos
		ldb	#$80		; screenwidth (in bytes)
		mul			; D = ypos * screenwidth
		std	tempword	; store the offset ypos*sceenwidth
		; tempword + xpos
		ldb	xpos		; get xpos
		clra
		addd	tempword	; D = D+tempword
		std	tempword	; tempword = D
		ldd	#$8000		; top left of display
		addd	tempword	; D = D+tempword
		tfr	d,x		; X = D

		ldb	addoffset	; put the add offset into B for quicker access
		tfr	u,y		; Y points to prince graphic ...
		leay	2,y		; ... sprite data is just after header

		; Just some hacked in delays to slow the animation
		jsr 	loopvsync
		jsr 	loopvsync
		jsr 	loopvsync
		jsr 	loopvsync

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
* wait for a vsync
*******************************************************************************
loopvsync
	        lda $ff03
	        bpl loopvsync
	        lda $ff02
	        rts



*******************************************************************************
* in: Y points where to store data, D contains pixel values
*******************************************************************************
lineclr		ldx	#64
lineclr_loop	std	,y++
		leax	-1,x
		bne	lineclr_loop
		rts

*******************************************************************************
* Draws 16 colors on the screen to show all 16 colors in the palette
*******************************************************************************

rainbow_y	fcb	12		; 12 lines
rainbow_row	fcb	16		; 16 blocks of colors
rainbow_color	fcb	00		; color to show

rainbow		ldy	#$8000

rainbow_line	lda	rainbow_color
		ldb	rainbow_color
		jsr	lineclr
		lda	rainbow_y
		deca
		sta	rainbow_y
		bne	rainbow_line
		
		lda	#12		; reset counter
		sta	rainbow_y	; 
		
		lda	rainbow_color	; rainbow_color+=$11 to show the next color in both nibbles
		adda	#$11		;
		sta	rainbow_color	;
			
		lda	rainbow_row	; rainbow_row--
		deca			;
		sta	rainbow_row	;
		
		;cmpa	#17		; are we at end?
		bne	rainbow_line	; no, draw next 12 lines
		
		rts
		
*******************************************************************************
*******************************************************************************
endlessloop	jmp	endlessloop



		;org	$5000

*******************************************************************************
* Each sprite contains a header, and sprite data. Currently the
* header contains width and height info. Later versions will also
* contain
*******************************************************************************

		include	princeart.asm

*******************************************************************************

		end 	start
