; lwasm -9 -b -o gfx.bin simongfx.asm && writecocofile --verbose gfx.dsk gfx.bin

SPEAKER_LEFT	equ	$FF7A
SPEAKER_RIGHT	equ	$FF7B

		org	$3F00
        	
start		orcc	#$50

		sta	$FFD9		; high speed poke...doesn't matter what you store
		
****************************
* Setup video mode
****************************
		lda	#$44
		sta	$ff90		; GIME INIT0

		;ldd	#$8012		; 128x192x16
		ldd	$801A		; 256x192x16
		;ldd	#$807A		; 256x225x16
		std	$ff98		; GIME VMODE and VRES registers
		
		
		ldd	#$c000
		std	$ff9d		; Vertical offset register MSB & LSB
		
****************************
* Setup MMU
****************************

		ldd	#$3031
		std	$ffa4		; GIME Banks at $8000-$9FFF and $A000-$BFFF
		
;		ldd	#$3233
;		std	$FFA6		; GIME Banks at $C000-$DFFF and $E000-$FFFF
		lda	#$32
		sta	$FFA6		; GIME Banks at $C000-$DFFF
				
****************************
* clear display
****************************

cls2		ldy	#colorpattern
cls1		ldd	,y++
		ldx	#$8000
cls		
		std	,x++
;		cmpx	#$9800
;		cmpx	#$f080		; simons 320x225
		cmpx	#$B000
;		cmpx	#$E000		; 256x192
		bne	cls

* rotate color
		cmpy	#colorpatternend
		bne	cls1
		bra	cls2

colorpattern	.word	$0000,$1111,$2222,$3333,$4444,$5555,$6666,$7777,$8888,$9999,$AAAA,$BBBB,$CCCC,$DDDD,$EEEE
colorpatternend	.word	$FFFF

makesnd
		ldx	#chan2
		std	1,x
		ldx	#chan1
		std	1,x
		jsr	maket
		rts
		
####################################################################################################
maket		
maket_loop2	ldx	#tonemap
maket_loop1	

		* sound off
		lda	#0
chan2		sta     $FF7B
		bsr     maket_delay

		* sound on
		lda	,x+
chan1		sta     $FF7B
		bsr     maket_delay
		cmpx	#tonemapend
		bne	maket_loop1
		
maket_done	rts

maket_delay	ldy     #$1fF		# how long of a delay
maket_wait	leay    -1,y
		bne     maket_wait	
		rts

tonemap	
		fcb	10,20,30,40,50,60,70,80,90,100,130,160,190,220,255,255,220,190,160,130,100,90,80,70,60,50,40,30,20,10
tonemapend	fcb	255

		end 	start
		