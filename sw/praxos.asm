.EQU sp 0               ; allocate a stack pointer at DM(0)
.EQU av_addr1 1         ; allocate an Avalon address at DM(1)	
.EQU av_addr2 2         ; allocate an Avalon address at DM(1)	
.EQU mask1 3            ; some more variables
.EQU	mask2 4
.EQU io 5
.EQU call_ret -1        ; handy constant
;
		ld# 0
		st av_addr1
		ld# 4
		st av_addr2
		ld#	$80000000      ; load a constant
		st	mask1          ; store it
		ror
		st	mask2
		ld#	0              ; load accumulator
		st	sp             ; initialise stack pointer
@main	ild	sp             ; load the index register with sp
		ld#	10             ; load subroutine parameter
		push               ; push the parameter
		ld#	dec            ; point the accumulator at @dec
		jal	call_ret       ; jump, link to sp-1
		iadd# 1            ; clear the parameter we pushed
		ist	sp             ; save the stack pointer
; do some unrelated stuff with the index register
		ild	av_addr1       ; load first Avalon address
		busrw	0          ; read from it
		iadd#	4          ; increment address
		ist	av_addr1       ; store address
		ldi	av_addr2       ; load second Avalon address
		busww	0          ; write to it
		iadd#	-4         ; decrement address
		ist	av_addr2       ; store address
		ild	sp             ; load the stack pointer
; call from here as well
		ld	mask2          ; load a bit mask
		push               ; push bit mask
		ld#	tog            ; point at tog
		jal	call_ret       ; call
		iadd# 1            ; clear the parameter we pushed
		br	main           ; jump
; subroutine1
@dec	ldi	0              ; load the parameter
@dec_lp	sub#	1          ; decrement the parameter
		brnz	dec_lp     ; loop until zero
		iadd#	call_ret   ; push parent return address
		ld	mask1          ; load parameter
		push               ; push parameter
		ld#	tog            ; point at @tog
		jal	call_ret       ; call
		iadd# 1            ; clear pushed parameter
		pop                ; pop return address
		jal	call_ret       ; return
; subroutine2
@tog	ldi	0              ; load parameter
		xor	io             ; xor mask with data
		out	0              ; write to IO port
		st	io             ; store data
		ldi	call_ret       ; pop return address
		jal	call_ret       ; return