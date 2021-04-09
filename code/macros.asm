; ****************************************************************************
; print a zero byte terminated string to a location at x,y
; a = first address of string buffer
; x
; y
; ****************************************************************************
!macro puts .addr, .row {
ldx #0
.puts_loop
    lda .addr,x
    beq .puts_loop_end
    sta $0400+(40*.row)+10,x
    lda #7
    sta $d800+(40*.row)+10,x
    inx
    jmp .puts_loop
.puts_loop_end
}
