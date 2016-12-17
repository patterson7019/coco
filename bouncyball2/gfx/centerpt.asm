*******************************************************************************
* http://www.8BitCoder.com
*
* Graphics and blit test running at 256x192 16 color mode.
*
* Tabs set to 8 and using real tabs, not spaces.
* 
* Compile: 
* lwasm -9 -b -o centerpt.bin centerpt.asm && writecocofile --verbose gfx.dsk centerpt.bin && coco3 `pwd`/gfx.dsk centerpt
* lwasm -l -9 -b -o centerpt.bin centerpt.asm > centerpt.lst && writecocofile --verbose gfx.dsk centerpt.bin && coco3 `pwd`/gfx.dsk centerpt
* 
* This is just a test to see how to set the video mode, and a hacky blit routine
* to display something.
*
*******************************************************************************

		org	$E00
start		orcc	#$50

****************
;test code I use to load into edtasm and inspect results, commented out for actual program

;		jsr	setRGBPalette
;		ldd	#$0		; set position sprite
;		std	xpos		; store sprite position
;		ldu	#ball01		; point to sprite
;		jsr	blit		; show the sprite
;		swi
****************
		
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
		;ldd	#$0
		;jsr	cls
		ldx	#cpColorValues
		jsr	setPalette
		jsr	rendertiles
		
blittest
		ldd	#$4050		; sprite x,y position
		ldu	#ball01		; point to sprite
		jsr	blit		; show the sprite
		jsr	delay
		
;		jmp	endlessloop
		
		ldd	#$4050
		ldu	#ball02
		jsr	blit
		jsr	delay
		
		ldd	#$4050
		ldu	#ball03
		jsr	blit
		jsr	delay
		
		ldd	#$4050
		ldu	#ball04
		jsr	blit
		jsr	delay
		
		ldd	#$4050
		ldu	#ball05
		jsr	blit
		jsr	delay
		
		ldd	#$4050
		ldu	#ball05
		jsr	blit
		jsr	delay
		
		ldd	#$4050
		ldu	#ball04
		jsr	blit
		jsr	delay
		
		ldd	#$4050
		ldu	#ball03
		jsr	blit
		jsr	delay
		
		ldd	#$4050
		ldu	#ball02
		jsr	blit
		jsr	delay
		
		ldd	#$4050
		ldu	#ball01
		jsr	blit
		jsr	delay
		
;		jsr	delay

		jmp 	blittest


*******************************************************************************
* Renders all the tiles to the BG
*******************************************************************************
* 8x6
tileposindex	fcb	0
tilepos		fdb	$0000,$1000,$2000,$3000,$4000,$5000,$6000,$7000
		fdb	$0020,$1020,$2020,$3020,$4020,$5020,$6020,$7020
		fdb	$0040,$1040,$2040,$3040,$4040,$5040,$6040,$7040
		fdb	$0060,$1060,$2060,$3060,$4060,$5060,$6060,$7060
		fdb	$0080,$1080,$2080,$3080,$4080,$5080,$6080,$7080
		fdb	$00A0,$10A0,$20A0,$30A0,$40A0,$50A0,$60A0,$70A0
		fdb	$FFFF

rendertiles	clra			; point to first element of index
		sta	tileposindex
		
r@		lda	tileposindex	; load up index
		ldx	#tilepos	; point to the array
		leax	a,x		; point to the element in the array
		adda	#2		; point to next element in the array
		sta	tileposindex	; store it
		ldd	,x		; load the element from the array
		cmpd	#$FFFF		; did we get to the end of the list?
		beq	rendertilesdone	; yup
		ldu	#tilecircuit	; tile data
		jsr	blittile32	; 32x32 tile
		bra	r@		; do it all again
		
rendertilesdone	rts
		
*******************************************************************************
* blittile32 - Renders tiles that are only 32 x 32 pixels in size. No other size
*               is supported.
* IN:   D: x,y position
*       U: Points to the tile data
*******************************************************************************
blittile32      sta     bt32_xp+1       ; keep the xpos
               
                ; calculate X reg = $8000 + (ypos)*screenwidth+xpos
                ; xpos is a byte offset, not pixel offset
                ldx     #$8000          ; Point to start of display memory
                lda     #$80            ; width of screen, B is already loaded with ypos of tile
                mul                     ; D=ypos*screenwidth
bt32_xp         addb    #0              : add xpos ... #0 is loaded with xpos ... D = ypos * screenwidth + xpos
                leax    d,x             ; X += (ypos+centery)*screenwidth+xpos+centerx (not 2's complement)
 
                ldd     #$1020          ; width 16 bytes (32 pixels) and height of 32 pixels
                std     width
 
b1@             ldd     ,u++            ; load data from tile
                std     ,x++            ; store to display
                dec     width           ; dec twice as we stored 2 bytes
                dec     width
                bne     b1@             ; are we done line yet?
                dec     height          ; height counter
                beq     blittile32done
                leax	$70,x           ; point to next line on display
                lda     #$10            ; width of tile is always $20 (32 pixels)
                sta     width
                bra     b1@
blittile32done  rts  

*******************************************************************************
* blitblocks - Blit all the tiles to the display.
*******************************************************************************
level_sample	fcb	16,16
		fcb	0,1,0,0,0,1,1,1,0,0,0,0,1,1,0,1
		fcb	0,1,0,0,0,1,1,1,0,0,0,0,1,1,0,0
		fcb	0,1,0,0,0,1,1,1,0,0,0,0,1,1,0,0
		fcb	1,1,1,0,0,1,2,1,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		fcb	0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0
		fcb	0,0,0,0,1,1,1,0,0,0,1,0,0,0,1,1
		fcb	1,1,1,0,0,1,0,0,0,0,1,0,0,0,0,1
		fcb	0,1,0,0,0,1,0,0,0,0,1,0,0,0,0,1
		fcb	0,1,0,0,0,1,0,0,0,0,1,0,0,0,0,1
		fcb	0,1,0,0,0,1,0,0,0,0,1,0,0,0,0,1
		fcb	0,1,0,0,0,1,0,0,0,0,1,0,0,0,0,1
block_x		fcb	0					; block x position
block_y		fcb	0					; block y position
block_index	fcb	0					; what block are we pointing to in the level

blitblocks	clra				; starting at 0,0
		clrb
		std	block_x
		sta	block_index		; start at index 0
		ldx	#level_sample
		leax	2,x			; move past the header to the data
		
a@		lda	,x+
		beq	b@			; if block is 0, then we don't need to blit a block
		ldd	block_x			; load x & y position		
		ldu	block_red		; the sprite to blit
		pshs	x			; if we save more the one reg, this is okay, otherwise should save X to a pointer
		jsr	blit			; show the block
		puls	x
b@		lda	block_x
		adda	#8			; next x position in byte coords
		sta	block_x		
		bra	a@

		rts
		
		
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
* IN: 	D = x,y position to draw sprite
*	U = Points to sprite data
*******************************************************************************
width		fcb	$FF		; counter for the width of the sprite
height		fcb	$FF		; counter for the height of the sprite

blit		sta	xp+1		; keep what the caller just passed in for x & y
		stb	yp+1
		ldd	,u		; pull sprite width and height
		std	width		; store in width and height counters
		sta	offswidth+1	; store the width in our blit loop
		ldb	#$80		; screen width in bytes

		; B=screenwidth A=spritewidth 
		; offs+1 = screenwidth-spritewidth (B-A)

		sta	subofs+1	; [4] offs+1 = spritewidth
subofs		subb	#0		; [4] B=screenwidth-spritewidth
		stb	offswidth+2	; [4] store the actual offset

		; calculate x & y offset with X reg = $8000 + (ypos+centery)*screenwidth+xpos+centerx
		; xpos is a byte offset, not pixel offset
		ldx	#$8000		; Point to start of display memory
yp		lda	#0		; load xpos
		adda	3,u		; add centery using 2's complement
		ldb	#$80		; width of screen
		mul			; D=ypos*screenwidth
xp		addb	#0		: add xpos ... #0 is loaded with xpos ... D = ypos * screenwidth + xpos
		addb	2,u		; add centerx using 2's complement
		leax	d,x		; This better not be 2's complement X += (ypos+centery)*screenwidth+xpos+centerx
		leau	4,u		; point to sprite data

		; Main blit routine


blit1		lda	,x		; get background byte
		ldb	,u+		; get sprite byte
		beq	short		; if transparent use full background
seeN1		bitb  	#$f0		; test sprite left nibble
		beq	tstR1		; if zero use background left nibble

		anda	#$0f		; if not zero, clear background left nibble
		bitb	#$0f		; test sprite right nibble
		beq	doMix		; if zero use background right nibble
tstR1		anda	#$f0		; if not zero, clear background right nibble
doMix		ora	-1,u		; add background and sprite
short		sta	,x+		; update destination and its pointer


;blit1		lda	,u+		; grab sprite data
;		beq	skip		; whole byte is 0 so skip plot
;		sta	,x+		; put onto display
;		bra	nxt
;skip		leax	1,x

		dec	width		; width counter
		bne	blit1		; keep blitting if we are not at the end of the sprite line
		dec	height		; height counter
		beq	blitdone	; jump out if we are done drawing the lines of the sprite

offswidth	ldd	#0		; load up the offset we add to X to point to next line
		abx			; point to next line (screenwidth-spritewidth)
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

;cpColorValues	fcb	0,0,7,56,63,6,48,54,1,8,9,4,32,36,8,24
cpColorValues	fcb	1,8,9,9,63,6,48,54,1,8,9,4,32,36,8,24

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
		include tilecircuit.inc
		include block_red.inc

		include palette.asm

*******************************************************************************

		end 	start
