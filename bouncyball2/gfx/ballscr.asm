*******************************************************************************
* http://www.8BitCoder.com
*
* Graphics and blit test running at 256x192 16 color mode.
*
* Tabs set to 8 and using real tabs, not spaces.
* 
* Revision 797 has coolspot animating.
*
* Compile: 
* lwasm -9 -b -o ballscr.bin ballscr.asm && writecocofile --verbose gfx.dsk ballscr.bin && coco3 `pwd`/gfx.dsk ballscr
* lwasm -l -9 -b -p cd -o ballscr.bin ballscr.asm > ballscr.lst && writecocofile --verbose gfx.dsk ballscr.bin && writecocofile --verbose ~/workspace/coco/edtasm6309/cc3/ed.dsk ballscr.bin && coco3 `pwd`/gfx.dsk ballscr
* ~/bin/mess64 -debug -window -waitvsync -resolution 1024x768 -natural -cfg_directory ~/coco -biospath ~/roms coco3 -flop1 `pwd`/gfx.dsk -autoboot_delay 1 -autoboot_command "LOADM\"ballscr\":EXEC\n"
*
* This is just a test to see how to set the video mode, and a hacky blit routine
* to display something.
*
**************************************************r*****************************

		org	$e00
		include bouncymacros.asm
				
start		orcc	#$50

		jmp	bouncy
		
bouncy		
		sta	HIGHSPEED	; high speed poke...doesn't matter what you store

		ldx	#blackPalette	; hide everything 
		jsr	setPalette
		
		jsr	setupGraphics

*******************************************************************************
* Show the animation.
*
* Since this is just a test, it was easier to just store the sprite x & y position
* into memory, and pass in sprite on U reg. Ideally I would pass in the position
* in A & B regs, or on the user stack. Still need to research the best way.
*******************************************************************************
		;ldd	#$0
		;jsr	cls
						
		setmmupage1
		jsr	rendertiles
		setmmupage2
		jsr	rendertiles
		setmmupage1		


		; blit an image to the off screen area to see what happens
		ldd	#$7f10		; $80 would make the image completely off screen
		ldu	#slimewarp01
		jsr	blit
;		jmp 	endlessloop
		
blittest
		; save behind the sprite
		jsr	loadwarp	; load U with sprite
		ldd	ballx		; load position
		jsr	storeblit	; store what will be under the sprite
		
		; blit the sprite
		jsr	loadwarp	; load U with sprite
		ldd	ballx		; load position
		jsr	blit		; show the sprite
		
		; remove the sprite to test
		lda	#$80		; bit 7 enables HVEN 6-0 offset * 2
		sta	HVEN		; $FF9F
		jsr	loadwarp	; load U with sprite
		ldd	ballx		; load position
		jsr	restoreblit	; replace background
		ldx	#bouncyPalette	; show colors
		jsr	setPalette

		lda	#0
		sta	blockindex
		lda	#$40-9
		ldb	#$10
		jsr	drawbb1
		;jmp	endlessloop
		
		ldd	#$0000
		jsr	drawbb1
		ldd	#$0010
		jsr	drawbb1		
		ldd	#$0020
		jsr	drawbb1		
		ldd	#$0030
		jsr	drawbb1		
		ldd	#$0040
		jsr	drawbb1		
		ldd	#$0050
		jsr	drawbb1		
		ldd	#$0060
		jsr	drawbb1		
		ldd	#$0070
		jsr	drawbb1		

		ldd	#$0000
		jsr	drawbb1
		ldd	#$0010
		jsr	drawbb1		
		ldd	#$0020
		jsr	drawbb1		
		ldd	#$0030
		jsr	drawbb1		
		ldd	#$0040
		jsr	drawbb1		
		ldd	#$0050
		jsr	drawbb1		
		ldd	#$0060
		jsr	drawbb1		
		ldd	#$0070
		jsr	drawbb1		

		jmp	ballscr

blockssloop	ldd	#$4010
		jsr	drawbb1
		jsr	longdelay
		
		ldd	#$4010
		jsr	drawbb2
		jsr	longdelay
		
		ldd	#$4010
		jsr	drawbb3
		jsr	longdelay
		
		ldd	#$4010
		jsr	drawbb4
		jsr	longdelay
		
		ldd	#$4010
		jsr	drawbb5
		jsr	longdelay
		
		ldd	#$4010
		jsr	drawbb6
		jsr	longdelay
		
		ldd	#$4010
		jsr	drawbb7
		jsr	longdelay
		
		ldd	#$4010
		jsr	drawbb8
		jsr	longdelay
		
		ldd	#$4010
		jsr	drawbb9
		jsr	longdelay
		
		ldd	#$4010
		jsr	drawbb10
		jsr	longdelay
		
		ldd	#$4010
		jsr	drawbb11
		jsr	longdelay
		
		ldd	#$4010
		jsr	drawbb12
		jsr	longdelay
		
		jmp	blockssloop
		
blockssdone	jmp	endlessloop

blockss		fdb	drawbb1,drawbb2,drawbb3,drawbb4,drawbb5,drawbb6,0
blockindex	fcb	0
		
ballscr		ldx	#bouncyPalette	; show colors
		jsr	setPalette
		
		
		
		
scroll_loop	lda	#$80		; bit 7 enables HVEN 6-0 offset * 2
		sta	scrollx
scroll_loop2	lda	scrollx
		sta	HVEN		; $FF9F
		jsr	vsync
		jsr	vsync

		; restore area under sprite
		jsr	loadwarp
		ldd	ballx
		;jsr	restoreblit

		; update the position of background and sprite
		lda	scrollx
		adda	#1		; this moves the screen 2 pixels, not just 1
		sta	scrollx
		lda	ballx
		adda	#2		; we have to move the sprite 2 pixels
		sta	ballx
		jsr	updateBall	; Update coolspots location
		jsr	updatewarp	; point to next frame
		; copy behind sprite
		jsr	loadwarp	; load U with sprite
		ldd	ballx		; load position
		;jsr	storeblit	; store what will be under the sprite
		
		; show sprite at new location		
		jsr	loadwarp	; load U with correct warp sprite
		ldd	ballx		; load the position
		;jsr	blit		; show it
		
		;
		; Scroll logic
		;
		lda	scrollx		; scroll logic
		bne	scroll_loop2	; wrapped to 0? no keep going, yes fall through
		ora	#$80		; turn hven on again
		sta	scrollx
		lda	#$40
		sta	ballx
		
		bra	scroll_loop2		; keep going

		

		
*******************************************************************************
* Updates the ball position
*******************************************************************************
updateBall	lda	balldir
		beq	updateBallMoveUp	; dir 0=up 1=down
		
		; update ball, move down
		lda	bally
		cmpa	#$AA
		beq	updateBallDirUp
		inca
		sta	bally
		rts
		
updateBallMoveUp
		lda	bally
		beq	updateBallDirDown
		deca
		sta	bally
		rts
		
updateBallDirDown
		lda	#1
		sta	balldir
		bra	updateBall		; ball dir changed, try again

updateBallDirUp	
		clra
		sta	balldir
		bra	updateBall		; ball dir changed, try again

		
		
		

*******************************************************************************
* Point to next anim frame, point to 0 if we wrapped
*******************************************************************************
updatewarp
		lda	animindex
		cmpa	#22
		;ldx	#anim		; check if we are at the end of the animation
		;leax	a,x		; if anim address is 0 we are at the end
		bne	aa@
		clra	
		bra	bb@
aa@		inca
		inca
bb@		sta	animindex
		rts
		
*******************************************************************************
* Load U reg with sprite based on animindex
* U = anim[animindex]
*******************************************************************************
loadwarp	lda	animindex
		ldx	#anim
		leax	a,x
		ldu	,x		; U now points to correct sprite address
		rts

endlessloop	jmp	endlessloop



		;org	$5000

*******************************************************************************

;cpColorValues	fcb	0,0,7,56,63,6,48,54,1,8,9,4,32,36,8,24
;bouncyPalette	fcb	1,8,9,7,63,6,48,54,1,8,9,4,32,36,8,24
bouncyPalette	fcb	$00,$00,$07,$38,$3F,$06,$30,$36,$01,$08,$09,$02,$10,$12,$04,$24
blackPalette 	fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

balldir		fcb	1
ballx		fcb	$40
bally		fcb	$00
scrollx		fcb	0


*******************************************************************************
* Each sprite contains a header, and sprite data. Currently the
* header contains width and height info. Later versions will also
* contain
*******************************************************************************

		include palette.asm
		include bouncygfx.asm
		include drawblocks.asm
		include tilecircuit.inc

		include slimewarp01.asm
;		include slimewarp02.asm
;		include slimewarp03.asm
;		include slimewarp04.asm
;		include slimewarp05.asm

		include coolspotlk01.asm
		include coolspotlk02.asm
		include coolspotlk03.asm
		include coolspotlk04.asm
		include coolspotlk05.asm
		include coolspotlk06.asm

animindex	fcb	0
;anim		fdb	slimewarp01,slimewarp02,slimewarp03,slimewarp04,slimewarp05,0,0
anim		fdb	coolspotlk01,coolspotlk02,coolspotlk03,coolspotlk04,coolspotlk05,coolspotlk06
		fdb	coolspotlk06,coolspotlk05,coolspotlk04,coolspotlk03,coolspotlk02,coolspotlk01,$0000

*******************************************************************************

		end 	start
