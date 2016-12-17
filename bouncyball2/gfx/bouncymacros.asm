*******************************************************************************
* Select MMU Page 1:
* Map GIME $60000-65FFF to 64K address space of $8000-$DFFF
*******************************************************************************
setmmupage1	macro
		ldx	#$3031		; GIME address ranges $$60000-$61FFF and $62000-$63FFF...
		stx	$FFA4		; ...mapped to $8000-$9FFF and $A000-$BFFF
		lda	#$32		; GIME address range $66000-67FFF...
		sta	$FFA6		; mapped to $C000-$DFFF
		endm
				
*******************************************************************************
* Select MMU Page 2:
* Map GIME $66000-6BFFF to 64K address space of $8000-DFFF		
*******************************************************************************
setmmupage2	macro
		ldx	#$3334		; GIME address ranges $66000-$67FFF and $68000-$69FFF...
		stx	$FFA4		; ...mapped to $8000-$9FFF and $A000-$BFFF
		lda	#$35		; GIME address range $6A000-$6BFFF...
		sta	$FFA6		; ...mapped to $C000-$DFFF
		endm

