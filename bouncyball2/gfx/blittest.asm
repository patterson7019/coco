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
* lwasm -9 -b -o blittest.bin blittest.asm && writecocofile --verbose gfx.dsk blittest.bin && coco3 `pwd`/gfx.dsk blittest
* lwasm -l -9 -b -p cd -o blittest.bin blittest.asm > blittest.lst && writecocofile --verbose gfx.dsk blittest.bin && writecocofile --verbose ~/workspace/coco/edtasm6309/cc3/ed.dsk blittest.bin && coco3 `pwd`/gfx.dsk blittest
* ~/bin/mess64 -debug -window -waitvsync -resolution 1024x768 -natural -cfg_directory ~/coco -biospath ~/roms coco3 -flop1 `pwd`/gfx.dsk -autoboot_delay 1 -autoboot_command "LOADM\"blittest\":EXEC\n"
*
* This is just a test to see how to set the video mode, and a hacky blit routine
* to display something.
*
**************************************************r*****************************

		org	$e00
		include bouncymacros.asm
				
start		orcc	#$50
		;jmp	mainloop

		sta	HIGHSPEED	; high speed poke...doesn't matter what you store

*******************************************************************************
* Setup video mode and render a background
*******************************************************************************

		ldx	#blackPalette	; hide everything 
		jsr	setPalette
		
		jsr	setupGraphics
		setmmupage1
		jsr	rendertiles
		setmmupage2
		jsr	rendertiles
		setmmupage1
		
		ldx	#bouncyPalette		; show colors
		jsr	setPalette
		
*******************************************************************************
		
mainloop	jsr	longdelay			; a bit of a delay
		jsr	loadframe
		ldd	#$0010
		jsr	blit	
		
;		jmp 	shortloop
		
		jsr	loadframe
		ldd	#$0810
		jsr	blit	
		jsr	loadframe
		ldd	#$1010
		jsr	blit	
		jsr	loadframe
		ldd	#$1810
		jsr	blit	

		jsr	loadframe
		ldd	#$2035
		jsr	blit	
		jsr	loadframe
		ldd	#$2835
		jsr	blit	
		jsr	loadframe
		ldd	#$3035
		jsr	blit	
		jsr	loadframe
		ldd	#$3835
		jsr	blit	

shortloop	jsr	updateframe
		bra	mainloop
		
endlessloop	jmp	endlessloop


*******************************************************************************
* Point to next anim frame, point to 0 if we wrapped
*******************************************************************************
updateframe	ldd	animindex
		addd	#2
		ldx	#anim		; check if we are at the end of the animation
		leax	d,x		
		ldu	,x		; if anim address is 0 we are at the end
		bne	updateframe2
		ldd	#0
updateframe2	std	animindex
		rts
		
*******************************************************************************
* Load U reg with sprite based on animindex
* U = anim[animindex]
*******************************************************************************
loadframe	ldd	animindex
		ldx	#anim
		leax	d,x
		ldu	,x		; U now points to correct sprite address
		rts

		
*******************************************************************************

animindex	fdb	$0000
anim		fdb	slime161,slime162,slime163,slime164,slime165,$0000

bouncyPalette	fcb	$00,$00,$07,$38,$3F,$06,$30,$36,$01,$08,$09,$02,$10,$12,$04,$24
blackPalette 	fcb	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


*******************************************************************************
* Each sprite contains a header, and sprite data. Currently the
* header contains width and height info.
*******************************************************************************

		include palette.asm
		include bouncygfx.asm
		include tilecircuit.inc
		include slime161.asm
		include slime162.asm
		include slime163.asm
		include slime164.asm
		include slime165.asm

		include sdrip.asm
		
*******************************************************************************

		end 	start
