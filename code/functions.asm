; ****************************************************************************
; Init the random noise generator on the sound chip.
; ****************************************************************************
init_random
    lda #$ff ; maximum frequency value 
    sta $d40e ; voice 3 frequency low byte 
    sta $d40f ; voice 3 frequency high byte 
    lda #$80 ; noise waveform, gate bit off 
    sta $d412 ; voice 3 control register 
    rts 

; ****************************************************************************
; Find a random X position between 1 and 38 (inside the border)
; ****************************************************************************
rnd_x
    lda RND
    cmp #38
    bcs rnd_x
    rts
; ****************************************************************************
; Find a random Y position between 1 and 23 (inside the border)
; ****************************************************************************
rnd_y
    lda RND
    cmp #23
    bcs rnd_y
    adc #1
    rts

; ****************************************************************************
; Delay for DELAY_T * 255 cycles
; ****************************************************************************
delay
    ldx DELAY_T
dlp1
    ldy #$ff
dlp2
    dey
    bne dlp2
    dex
    bne dlp1

    rts

