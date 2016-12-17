*******************************************************************************
* http://www.8BitCoder.com
*
* Bounce Engine graphics routines
*
* Tabs set to 8 and using real tabs, not spaces.
**************************************************r*****************************

VOFFSET		equ	$FF9D
HVEN		equ	$FF9F
HIGHSPEED	equ	$FFD9


bgbuffer	rmb	2000	; holds stuff behind the ball
sbwidth		fcb	0
sbheight	fcb	0
width		fcb	$FF		; counter for the width of the sprite
height		fcb	$FF		; counter for the height of the sprite

*******************************************************************************
* Setup video mode
*******************************************************************************

setupGraphics	lda	#$44
		sta	$ff90		; GIME INIT0

		; VMODE
		; 76543210 
		; AxxxxBBB A sets graphics B sets # lines per row
		; A 1=Graphics 0=Text
		; xxxx just leave as 0000
		; BBB Lines per row
		;   00x=one line per row
		;   010=two lines per row
		;   011=eight lines per row
		;   100=nine lines per row
		;   101=ten lines per row
		;   110=eleven lines per row
		;   111=*infinite lines per row
		lda	#%10000000
		sta	$ff98		; VMODE
		
		; VRES
		; 76543210 
		; xAABBBCC
		; x Unused
		; AA scan lines 
		;   00=192 
		;   01=200 
		;   10=undefined 
		;   11=225
		; BBB HRES bytes per row
		;   000=16 bytes per row 
		;   001=20 bytes per row 
		;   010=32 bytes per row 
		;   011=40 bytes per row
		;   100=64 bytes per row
		;   101=80 bytes per row
		;   110=128 bytes per row
		;   111=160 bytes per row
		; CC CRES # colors in graphics mode
		;   00=2 colors (8 pixels per byte)
		;   01=4 colors (4 pixels per byte)
		;   10=16 colors (2 pixels per byte)
		;   11=Undefined (would have been 256 colors)		 
		lda	#%00011010	
		sta	$ff99		; VRES

		ldd	#$C000		; $60000/8 = $C000
		std	$FF9D		; Vertical offset register MSB & LSB
		
		; setup for hardware scrolling
		lda	#$80
		sta	HVEN
		
		rts
		
*******************************************************************************
* storeblit
*
* ** NOTE **
* This code is identical to restore blit except the source and dest is different.
* This should really use subroutines.
* 
* stores what is will be under a sprite. Uses the sprites w & h
* and the location in D to figure out what to store.
*
* IN: 	D = x,y position to grab data from
*	U = Points to sprite data so we can get width and height info
*******************************************************************************

storeblit	sta	sbxp+1		; preload the xpos
		stb	sbyp+1		; preload the ypos
		ldd	,u		; get sprite width and height
		sta	sbw1+1		; preload width	
		sta	sbw2+1		; preload width
		std	sbwidth		; store width and height
		
		; calculate the offset
		lda	#$80
		suba	,u
		sta	sboff+1		; preload
		
		; X reg = $8000+(ypos*$80+xpos)
		ldx	#$8000
sbyp		ldb	#0		; preloaded with ypos
		addb	3,u		; add centery using 2's complement
		lda	#$80
		mul			; D=A*B (B is already loaded with ypos
sbxp		addb	#0		; prealoded with xpos
		addb	2,u		; add centerx using 2's complement
		leax	d,x		; add the offset to X; X reg now equals $8000+(ypos*$80+xpos)

		; point to dest and setup counters
		ldu	#bgbuffer	; point to dest buffer
sbw1		ldb	#0		; B = sprite width preloaded
a@		lda	,x+		; copy source
		sta	,u+		; to destination
		decb			; dec width counter
		bne	a@		; will we have copied a full row?
		dec	sbheight	; dec height counter
		beq	b@		; have we got all rows? != 0 means nope
		; more rows, point X to next line
sboff		ldb	#0		; amount to point to next line preloaded
		abx			; X += offset amount
		ldb	#$80		; get past virtual screen
		abx
sbw2		ldb	#0		; B = sprite width again preloaded
		bra	a@		; do next row
b@		rts

*******************************************************************************
* restoreblit
* 
* ** NOTE **
* This code is identical to storeblit except the source and dest is different.
* This should really use subroutines.
* 
* stores what is will be under a sprite. Uses the sprites w & h
* and the location in D to figure out what to store.
*
* IN: 	D = x,y position to grab data from
*	U = Points to sprite data so we can get width and height info
*******************************************************************************
restoreblit	sta	rbxp+1		; preload the xpos
		stb	rbyp+1		; preload the ypos		
		ldd	,u		; get sprite width and height
		sta	rbw1+1		; preload width	
		sta	rbw2+1		; preload width
		std	sbwidth		; store width and height
		
		; calculate the offset
		lda	#$80
		suba	,u
		sta	rboff+1		; preload
		
		; X reg = $8000+(ypos*$80+xpos)
		ldx	#$8000
rbyp		ldb	#0		; preloaded with ypos
		adda	3,u		; add centery using 2's complement
		lda	#$80
		mul			; D=A*B (B is already loaded with ypos
rbxp		addb	#0		; prealoded with xpos
		addb	2,u		; add centerx using 2's complement
		leax	d,x		; add the offset to X; X reg now equals $8000+(ypos*$80+xpos)
		
		; point to dest and setup counters
		ldu	#bgbuffer	; point to dest buffer
rbw1		ldb	#0		; B = sprite width preloaded
a@		lda	,u+		; copy source
		sta	,x+		; to destination
		decb			; dec width counter
		bne	a@		; will we have copied a full row?
		dec	sbheight	; dec height counter
		beq	b@		; have we got all rows? != 0 means nope
		; more rows, point X to next line
rboff		ldb	#0		; amount to point to next line preloaded
		abx			; X += offset abount
		ldb	#$80		; get past virtual screen
		abx
rbw2		ldb	#0		; B = sprite width again
		bra	a@		; do next row
b@		rts



*******************************************************************************
* blit
*
* IN: 	D = x,y position to draw sprite
*	U = Points to sprite data
*******************************************************************************

blit
		std	scrpoint+1	; keep what the caller just passed in for x & y
		ldd	,u		; pull sprite width and height
		std	width		; store in width and height counters
		sta	offswidth+1	; store the width in our blit loop
		sta	subofs+1	; [4] offs+1 = spritewidth

scrpoint	ldd	#$0000
		jsr	calcxy
		ldb	#$80		; screen width in bytes

		; B=screenwidth A=spritewidth 
		; offs+1 = screenwidth-spritewidth (B-A)

subofs		subb	#0		; [4] B=screenwidth-spritewidth
		stb	offswidth+2	; [4] store the actual offset

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

		dec	width		; width counter
		bne	blit1		; keep blitting if we are not at the end of the sprite line
		dec	height		; height counter
		beq	blitdone	; jump out if we are done drawing the lines of the sprite

offswidth	ldd	#0		; load up the offset we add to X to point to next line
		abx			; point to next line (screenwidth-spritewidth)
		ldb	#$80		; get past virtual screen
		abx
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
longdelay	jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		jsr 	vsync
		rts


*******************************************************************************
* wait for a vsync
*******************************************************************************
vsync		pshs	a
a@	        lda 	$ff03
	        bpl 	a@
	        lda 	$ff02
	        puls	a
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
* Renders all the tiles to the BG
*******************************************************************************
* 8x6
tileposindex	fcb	0
tilepos		fdb	$0000,$1000,$2000,$3000,$4000,$5000,$6000,$7000,$8000,$9000,$a000,$b000,$c000,$d000,$e000,$f000
		fdb	$0020,$1020,$2020,$3020,$4020,$5020,$6020,$7020,$8020,$9020,$a020,$b020,$c020,$d020,$e020,$f020
		fdb	$0040,$1040,$2040,$3040,$4040,$5040,$6040,$7040,$8040,$9040,$a040,$b040,$c040,$d040,$e040,$f040
		fdb	$ffff

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
blittile32      jsr	calcxy		; X = calcxy()
                ldd     #$1020          ; width 16 bytes (32 pixels) and height of 32 pixels
                std     width
 
b1@             ldd     ,u++            ; load data from tile
                std     ,x++            ; store to display
                dec     width           ; dec twice as we stored 2 bytes
                dec     width
                bne     b1@             ; are we done line yet?
                dec     height          ; height counter
                beq     blittile32done
                leax	$f0,x           ; point to next line on display
                lda     #$10            ; width of tile is always $20 (32 pixels)
                sta     width
                bra     b1@
blittile32done  rts  


******************************************************************************
* Calc X offset based on $8000 + screenwidth * ypos + xpos
* 
* **Note**
* This is specific to 256 byte wide HVEN mode.
*
* IN : D reg = X & Y position
* OUT: X reg is set to correct address
******************************************************************************
calcxy		cmpb	#$60
		blo	calcxymap1
		subb	#$60		; and adjust our offset to top of mmu page 2
		sta	calcxymap2+2
		setmmupage2		; we crossed the mmu boundry, point to the next one
		bra	calcxyroute2	; jump to the logic

calcxymap1	sta	calcxymap2+2
calcxyroute2	stb	calcxyypos+1
calcxymap2	ldd	#$8000
calcxyypos	adda	#0
		tfr	d,x
		rts