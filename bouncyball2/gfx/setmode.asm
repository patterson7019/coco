####################################################################################################
# Test the Orch-90 cart by outputting a sound on each channel
# http://8BitCoder.com
####################################################################################################

# lwasm -9 -b -o sndpan.bin sndpan.asm && writecocofile --verbose sound.dsk sndpan.bin

SPEAKER_LEFT	equ	$FF7A
SPEAKER_RIGHT	equ	$FF7B

           	org     $3F00
           	
           	
start		jsr	init

####################################################################################################
init		
		ldx	#$ffd9		; high speed on coco3
		sta	,x
		rts

####################################################################################################

	    	end	start
