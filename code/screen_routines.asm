
; ****************************************************************************
; plotxy, print char A to X, Y: borks, X and Y, COLOR is used for the color
; ****************************************************************************
plotxy
    pha
    lda #$00
    sta SCRPTRL
    lda #$04
    sta SCRPTRH

    cpy #0
    jmp plotxy_cmp_y

plotxy_sub_y
    lda SCRPTRL
    clc
    adc #40
    bcc plotxy_loop
    inc SCRPTRH
plotxy_loop
    sta SCRPTRL
    dey
plotxy_cmp_y
    bne plotxy_sub_y
    txa
    tay
    pla
    sta (SCRPTRL),y
    ; figure out the color pointer from the screen pointer.
    lda SCRPTRL
    sta CLRPTRL
    lda SCRPTRH
    clc
    adc #$D4            ; this is the difference between D8 and 04
                        ; the msb of color ram and screen ram respectively
    sta CLRPTRH
    lda COLOR
    sta (CLRPTRL),y
    
    rts


; ****************************************************************************
; find the color of a location (x,y) in screen ram, save in a
; ****************************************************************************
peekxy
    lda #$00
    sta CLRPTRL
    lda #$D8
    sta CLRPTRH

    cpy #0
    jmp peekxy_cmp_y

peekxy_sub_y
    lda CLRPTRL
    clc
    adc #40
    bcc peekxy_loop
    inc CLRPTRH
peekxy_loop
    sta CLRPTRL
    dey
peekxy_cmp_y
    bne peekxy_sub_y
    txa
    tay
    lda (CLRPTRL),y    

    rts

; ****************************************************************************
; clear the whole screen with spaces
; ****************************************************************************
clear_screen
    lda #32
    ldx #0
clear_screen_loop
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $0700,x
    lda #0
    sta $D800,x
    sta $D900,x
    sta $DA00,x
    sta $DB00,x
    dex
    bne clear_screen_loop
    rts

; ****************************************************************************
; draw a border around the screen
; ****************************************************************************
border
    lda #3
    sta COLOR

    ldx #39
border_loop_rows
    lda #160
    sta $0400,x
    sta $07C0,x
    lda COLOR
    sta $D800,x
    sta $DBC0,x
    dex
    bpl border_loop_rows
    ; we have to use plotxy for this (well we don't but I can't figure out an easier way)
    ; draw the columns on the sides.
    lda #24
    sta COUNTER

border_loop_cols
    ldy COUNTER
    ldx #0
    lda #160
    jsr plotxy
    ldy COUNTER
    ldx #39
    lda #160
    jsr plotxy
    dec COUNTER
    bne border_loop_cols

border_end
    rts