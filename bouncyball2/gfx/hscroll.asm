*******************************************************************************
* http://www.8BitCoder.com
*
* Graphics and blit test running at 256x192 16 color mode.
*
* Tabs set to 8 and using real tabs, not spaces.
* 
* Compile: 
* lwasm -9 -b -o hscroll.bin hscroll.asm && writecocofile --verbose gfx.dsk hscroll.bin && coco3 `pwd`/gfx.dsk hscroll
* lwasm -l -9 -b -o hscroll.bin hscroll.asm > hscroll.lst && writecocofile --verbose gfx.dsk hscroll.bin && coco3 `pwd`/gfx.dsk hscroll
* 
* This is just a test to see how to set the video mode, and a hacky blit routine
* to display something.
*
*******************************************************************************

VOFFSET		equ	$FF9D
HVEN		equ	$FF9F
HIGHSPEED	equ	$FFD9

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
		
;		sta	HIGHSPEED	; high speed poke...doesn't matter what you store

		ldx	#blackPalette	; hide everything 
		jsr	setPalette

*******************************************************************************
* Setup video mode
*******************************************************************************

		lda	#$44
		sta	$ff90		; GIME INIT0

		ldd	#$801A		; 256x192 16 colors 
		std	$ff98		; GIME VMODE %1000 0000 & VRES 0 00 110 10
		
		ldd	#$C000		; $60000/8 = $C000
		std	$FF9D		; Vertical offset register MSB & LSB
		
*******************************************************************************
* Show the animation.
*
* Since this is just a test, it was easier to just store the sprite x & y position
* into memory, and pass in sprite on U reg. Ideally I would pass in the position
* in A & B regs, or on the user stack. Still need to research the best way.
*******************************************************************************
		;ldd	#$0
		;jsr	cls

; setup mmu to page 1
		jsr 	mmupage1
		jsr	rendertiles
		inc	$ff91		; mmu task 1
		jsr	rendertiles
		dec	$ff91		; mmu task 2
blittest
		ldd	#$4090		; sprite x,y position
		ldu	#ball01		; point to sprite
		jsr	blit		; show the sprite

		ldx	#bouncyPalette	; show colors
		jsr	setPalette

;		jmp	endlessloop
		
hscroll		
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
		
b@		lda	#$bf		; bit 7 enables HVEN 6-0 offset * 2
a@		sta	HVEN		; $FF9F
		;jmp	endlessloop
		jsr	delay
		inca
		bne	a@		; wrapped to 0? no keep going, yes fall through
		ora	#$80		; turn hven on again
		bra	a@		; keep going
		jmp	endlessloop	; never gets here	
		
vscroll		; scroll up
b@		ldd	#$C000
a@		std	VOFFSET
		jsr	vsync
		addd	#$10		; scrolls up 1 pixel
		cmpd	#$cc00		; 192 pixels ($C0 * 10)
		bls	a@
		; now scroll back down
c@		subd	#$10		; scrolls down 1 pixel
		cmpd	#$c000		; back at the top?
		beq	b@
		std	VOFFSET
		jsr	vsync
		bra	c@
		
		
		; vert1
b@		ldb	#$c0		
a@		stb	$ff9d		; vert msb
		jsr	longdelay
		incb
		cmpb	#$D0		; did we go far enough?
		bne	a@
		bra	b@
		jmp	endlessloop
*******************************************************************************
* Renders all the tiles to the BG
*******************************************************************************
* 8x6
tileposindex	fcb	0
tilepos		fdb	$0000,$1000,$2000,$3000,$4000,$5000,$6000,$7000
		fdb	$8000,$9000,$a000,$b000,$c000,$d000,$e000,$f000
		fdb	$0040,$1040,$2040,$3040,$4040,$5040,$6040,$7040
		fdb	$8040,$9040,$a040,$b040,$c040,$d040,$e040,$f040
		fdb	$0080,$1080,$2080,$3080,$4080,$5080,$6080,$7080
		fdb	$8080,$9080,$a080,$b080,$c080,$d080,$e080,$f080
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
blittile32      sta     bt32_xp+1       ; keep the xpos
   		
            
                ; calculate X reg = $8000 + (ypos)*screenwidth+xpos
                ; xpos is a byte offset, not pixel offset

                ldx     #$8000          ; Point to start of display memory
                lda     #$80            ; width of screen, B is already loaded with ypos of tile
                mul                     ; D=ypos*screenwidth
bt32_xp         addb    #0              : add xpos ... #0 is loaded with xpos ... D = ypos * screenwidth + xpos
                leax    d,x             ; X += (ypos*screenwidth+xpos (not 2's complement)

 
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

		ldb	$ff91
mmu_sel		orb	#0		; task 1/2 depends on initial Y coord
		stb	$ff91

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
		cmpx	#$df00		; got to last line of area1
		blo	bank0		; no, then just continue

		leax	-$6000,x	; subtract height from the address

		ldb	$ff91		; flip in mmu 2
		orb	#1
		stb	$ff91		

bank0		dec	width		; width counter
		bne	blit1		; keep blitting if we are not at the end of the sprite line

		dec	height		; height counter
		beq	blitdone	; jump out if we are done drawing the lines of the sprite

offswidth	ldd	#0		; load up the offset we add to X to point to next line
		abx			; point to next line (screenwidth-spritewidth)
		ldb	#$80		; get past virtual screen
		abx
		sta	width		; ... so we can reset the width counter
		bra	blit1		; blit the next line
blitdone	lda	#0		; need to reset mmu task to 0
		sta	$ff91		; on exit
		rts

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
* Setup MMU
*******************************************************************************

mmupage1
		; map GIME $60000-65FFF to 64K address space of $8000-$DFFF
		ldd	#$3031		; GIME address ranges $$60000-$61FFF and $62000-$63FFF...
		std	$FFA4		; ...mapped to $8000-$9FFF and $A000-$BFFF
		lda	#$32		; GIME address range $66000-67FFF...
		sta	$FFA6		; mapped to $C000-$DFFF
mmupage2		
		; map GIME $66000-6BFFF to 64K address space of $8000-DFFF
		ldd	#$3334		; GIME address ranges $66000-$67FFF and $68000-$69FFF...
		std	$FFAc		; ...mapped to $8000-$9FFF and $A000-$BFFF
		lda	#$35		; GIME address range $6A000-$6BFFF...
		sta	$FFAe		; ...mapped to $C000-$DFFF
		rts

*******************************************************************************
endlessloop	jmp	endlessloop



		;org	$5000

*******************************************************************************

;cpColorValues	fcb	0,0,7,56,63,6,48,54,1,8,9,4,32,36,8,24
bouncyPalette	fcb	1,8,9,9,63,6,48,54,1,8,9,4,32,36,8,24
blackPalette 	fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

*******************************************************************************
* Each sprite contains a header, and sprite data. Currently the
* header contains width and height info. Later versions will also
* contain
*******************************************************************************

		include	ball01.inc
		include tilecircuit.inc
		include block_red.inc

		include palette.asm

*******************************************************************************

		end 	start
