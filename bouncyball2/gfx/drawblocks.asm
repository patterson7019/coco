*******************************************************************************    
* http://www.8BitCoder.com                                                         
*                                                                                  
* Routines for drawing blocks. See trontiles.gif for what each tile looks like.    
* Specify the light color in A, dark in B.                                         
*                                                                                  
*******************************************************************************    
                                                                                   
drawbbNextLine	equ	$80		; Amount to add to X reg to get to next lin
drawbbHeight	fdb	0                                                          
                                                                                   
                      
                      
drawbb0		rts
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	+-----+                                                                    
* 	|     |                                                                    
* 	+-----+                                                                    
*       ^^^^^^^                                                                    
*                                                                                  
*******************************************************************************    
drawbb1		jsr	calcxy		; [7]   load X with correct address        
		lda	#6		; [2]   number of same rows                
		ldb	#drawbbNextLine ; [2]                                      
                                                                                   
****************                                                                   
* top line		                                                           
		ldu	#$7777		; [3]   yellow                             
		stu	,x		; [5+1] store an entire row                
		stu	2,x            	; [5+1]                                    
		stu	4,x            	; [5+1]                                    
		stu	6,x            	; [5+1]                                    
                                                                                   
****************                                                                   
* middle section                                                                   
dbbloop1	abx			; [3]                                      
		abx			; [3]   point to next line                 
		ldu	#$7555          ; [3]                                      
		stu	,x		; [5]                                      
		ldu	#$5555          ; [3]                                      
		stu	2,x            	; [5+1]                                    
		stu	4,x            	; [5+1]                                    
		ldu	#$5557          ; [3]                                      
		stu	6,x            	; [5+1]                                    
		deca                    ; [2]                                      
		bne	dbbloop1        ; [3]                                      
                                                                                   
****************                                                                   
* bottom line                                                                      
		abx			; [3]                                      
		abx			; [3]	point to next line                 
		ldu	#$7777		; [3]   yellow                             
		stu	,x		; [5] 	store an entire row                
		stu	2,x            	; [5+1]                                    
		stu	4,x            	; [5+1]                                    
		stu	6,x            	; [5+1]                                    
		                                                                   
drawbbDone1	rts	                ; [5]                                      
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	|     |                                                                    
* 	|     |                                                                    
* 	|     |                                                                    
*       ^^^^^^^                                                                    
*                                                                                  
*******************************************************************************    
drawbb2		jsr	calcxy		; load X with correct address              
                                                                                   
		lda	#8		; number of same rows                      
		ldb	#drawbbNextLine                                            
                                                                                   
dbbloop2	ldu	#$7555                                                     
		stu	,x		                                           
		ldu	#$5555                                                     
		stu	2,x                                                        
		stu	4,x                                                        
		ldu	#$5557                                                     
		stu	6,x                                                        
		deca                                                               
		beq	drawbbDone2                                                
		abx			; point to next line                       
		abx                                                                
		bra	dbbloop2                                                   
		                                                                   
drawbbDone2	rts	                                                           
                                                                                   
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	-------                                                                    
* 	                                                                           
* 	-------                                                                    
*       ^^^^^^^                                                                    
*                                                                                  
*******************************************************************************    
drawbb3		jsr	calcxy		; load X with correct address              
                                                                                   
		lda	#6		; number of same rows                      
		ldb	#drawbbNextLine                                            
                                                                                   
****************                                                                   
* top line		                                                           
		ldu	#$7777		; yellow                                   
		stu	,x		; store an entire row                      
		stu	2,x                                                        
		stu	4,x                                                        
		stu	6,x                                                        
                                                                                   
****************                                                                   
* middle section                                                                   
dbbloop3	abx			; point to next line                       
		abx                                                                
		ldu	#$5555                                                     
		stu	,x                                                         
		stu	2,x                                                        
		stu	4,x                                                        
		stu	6,x                                                        
		deca                                                               
		bne	dbbloop3                                                   
                                                                                   
****************                                                                   
* bottom line                                                                      
		abx			; point to next line                       
		abx                                                                
		ldu	#$7777		; yellow                                   
		stu	,x		; store an entire row                      
		stu	2,x                                                        
		stu	4,x                                                        
		stu	6,x                                                        
		                                                                   
drawbbDone3	rts	                                                           
                                                                                   
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	+------                                                                    
* 	|                                                                          
* 	|                                                                          
*       ^^^^^^^                                                                    
*                                                                                  
*******************************************************************************    
drawbb4		jsr	calcxy		; load X with correct address              
                                                                                   
		lda	#7		; number of same rows                      
		ldb	#drawbbNextLine                                            
		                                                                   
		ldu	#$7777		; yellow                                   
		stu	,x		; store an entire row                      
		stu	2,x                                                        
		stu	4,x                                                        
		stu	6,x                                                        
                                                                                   
drawbbLoop4	abx			; point to next line                       
		abx                                                                
		ldu	#$7555                                                     
		stu	,x		; store an entire row                      
		ldu	#$5555                                                     
		stu	2,x                                                        
		stu	4,x                                                        
		stu	6,x                                                        
		deca                                                               
		bne	drawbbLoop4	; if we are done, branch                   
		                                                                   
drawbbDone4	rts	                                                           
                                                                                   
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	-------                                                                    
* 	                                                                           
* 	                                                                           
*       ^^^^^^^                                                                    
*                                                                                  
*******************************************************************************    
drawbb5		jsr	calcxy		; load X with correct address              
                                                                                   
		lda	#7		; number of same rows                      
		ldb	#drawbbNextLine                                            
                                                                                   
****************                                                                   
* top line		                                                           
		ldu	#$7777		; yellow                                   
		stu	,x		; store an entire row                      
		stu	2,x                                                        
		stu	4,x                                                        
		stu	6,x                                                        
                                                                                   
****************                                                                   
* middle section                                                                   
dbbloop5	abx			; point to next line                       
		abx                                                                
		ldu	#$5555                                                     
		stu	,x		                                           
		stu	2,x                                                        
		stu	4,x                                                        
		stu	6,x                                                        
		deca                                                               
		bne	dbbloop5                                                   
		                                                                   
drawbbDone5	rts	                                                           
                                                                                   
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	------+                                                                    
* 	      |                                                                    
* 	      |                                                                    
*       ^^^^^^^                                                                    
*                                                                                  
*******************************************************************************    
drawbb6		jsr	calcxy		; load X with correct address              
                                                                                   
		lda	#7		; number of same rows                      
		ldb	#drawbbNextLine                                            
		                                                                   
		ldu	#$7777		; yellow                                   
		stu	,x		; store an entire row                      
		stu	2,x                                                        
		stu	4,x                                                        
		stu	6,x                                                        
		                                                                   
drawbbLoop6	abx                                                                
		abx                                                                
		ldu	#$5555                                                     
		stu	,x		                                           
		stu	2,x                                                        
		stu	4,x                                                        
		ldu	#$5557                                                     
		stu	6,x                                                        
		deca			; dec counter                              
		bne	drawbbLoop6	; if we are done, branch                   
		                                                                   
drawbbDone6	rts	                                                           
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	|                                                                          
* 	|                                                                          
* 	|                                                                          
*       ^^^^^^^                                                                    
*                                                                                  
*******************************************************************************    
drawbb7  	jsr     calcxy                                                     
		lda	#8                                                         
		ldb	#drawbbNextLine                                            
                                                                                   
dbbloop7	ldu	#$7555                                                     
                stu	,x                                                         
                ldu	#$5555                                                     
                stu	2,x                                                        
                stu	4,x                                                        
                stu	6,x                                                        
                abx			; point to next line                       
                abx                                                                
                deca                                                               
                bne	dbbloop7                                                   
                                                                                   
                rts                                                                
                                                                                   
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	                                                                           
* 	                                                                           
* 	                                                                           
*       ^^^^^^^                                                                    
*       Just a dark block, no outlines                                             
*******************************************************************************    
drawbb8  	jsr     calcxy                                                     
		lda	#8                                                         
		ldb	#drawbbNextLine                                            
                                                                                   
dbbloop8	ldu	#$5555                                                     
                stu	,x                                                         
                stu	2,x                                                        
                stu	4,x                                                        
                stu	6,x                                                        
                abx			; point to next line                       
                abx                                                                
                deca                                                               
                bne	dbbloop8                                                   
                                                                                   
                rts                                                                
                                                                                   
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	      |                                                                    
* 	      |                                                                    
* 	      |                                                                    
*       ^^^^^^^                                                                    
*                                                                                  
*******************************************************************************    
drawbb9  	jsr     calcxy                                                     
		lda	#8                                                         
		ldb	#drawbbNextLine                                            
                                                                                   
dbbloop9	ldu	#$5555                                                     
                stu	,x                                                         
                stu	2,x                                                        
                stu	4,x                                                        
                ldu	#$5557                                                     
                stu	6,x                                                        
                abx			; point to next line                       
                abx                                                                
                deca                                                               
                bne	dbbloop9                                                   
                                                                                   
                rts                                                                
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	|                                                                          
* 	|                                                                          
* 	+------                                                                    
*       ^^^^^^^                                                                    
*                                                                                  
*******************************************************************************    
drawbb10  	jsr     calcxy                                                     
		lda	#7                                                         
		ldb	#drawbbNextLine                                            
                                                                                   
dbbloop10	ldu	#$7555                                                     
                stu	,x                                                         
                ldu	#$5555                                                     
                stu	2,x                                                        
                stu	4,x                                                        
                stu	6,x                                                        
                abx			; point to next line                       
                abx                                                                
                deca                                                               
                bne	dbbloop10                                                  
                                                                                   
		ldu	#$7777                                                     
                stu	,x                                                         
                stu	2,x                                                        
                stu	4,x                                                        
                stu	6,x                                                        
		                                                                   
                rts                                                                
                                                                                   
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	|                                                                          
* 	|                                                                          
* 	+------                                                                    
*       ^^^^^^^                                                                    
*                                                                                  
*******************************************************************************    
drawbb11  	jsr     calcxy                                                     
		lda	#7                                                         
		ldb	#drawbbNextLine                                            
                                                                                   
dbbloop11	ldu	#$5555                                                     
                stu	,x                                                         
                stu	2,x                                                        
                stu	4,x                                                        
                stu	6,x                                                        
                abx			; point to next line                       
                abx			                                           
                deca                                                               
                bne	dbbloop11                                                  
                                                                                   
		ldu	#$7777                                                     
                stu	,x                                                         
                stu	2,x                                                        
                stu	4,x                                                        
                stu	6,x                                                        
		                                                                   
                rts                                                                
                                                                                   
                                                                                   
*******************************************************************************    
* Draw a plan block on the screen                                                  
*                                                                                  
* IN: D reg = x & y position (x is byte not screen coordinate)                     
*                                                                                  
* 	      |                                                                    
* 	      |                                                                    
* 	+------                                                                    
*       ^^^^^^^                                                                    
*                                                                                  
*******************************************************************************    
drawbb12  	jsr     calcxy                                                     
		lda	#7                                                         
		ldb	#drawbbNextLine                                            
                                                                                   
dbbloop12	ldu	#$5555                                                     
                stu	,x                                                         
                stu	2,x                                                        
                stu	4,x                                                        
                ldu	#$5557                                                     
                stu	6,x                                                        
                abx			; point to next line                       
		abx                                                                
                deca                                                               
                bne	dbbloop12                                                  
                                                                                   
		ldu	#$7777                                                     
                stu	,x                                                         
                stu	2,x                                                        
                stu	4,x                                                        
                stu	6,x                                                        
		                                                                   
                rts                                                                
                                                                                   
                                                                                   
