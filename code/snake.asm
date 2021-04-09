; *=$0801
;     !byte $0C,$08,$0A,$00,$9E,$20,$34,$30,$39,$36,$00,$00,$00

*=$1000
!src "./code/macros.asm"
; Zero page
SCRPTRL = $10
SCRPTRH = $11
CLRPTRL = $12
CLRPTRH = $13
COLOR   = $14
COUNTER = $15
DELAY_T = $16
APPLE_X = $17
APPLE_Y = $18
APPLE   = $19
SNAKE_X = $20
SNAKE_Y = $21
DIR     = $22   ; 0=left, 3=down, 1=right, 2=up
RESET   = $23

RND     = $d41b ; sid noise voice address for random numbers

PRA     = $dc00 ; keyboard ports and data direction registers
DDRA    = $dc02
PRB     = $dc01
DDRB    = $dc03

main
    jsr init_random
    jsr clear_screen
    lda #0
    sta $D021   ; background color
    sta $D020   ; border color

    jsr border

    lda #20
    sta SNAKE_X
    lda #11
    sta SNAKE_Y

    lda #0     ; initial direction is down
    sta DIR

    lda #25    ; starting speed = 60
    sta DELAY_T

    lda #1      ; we don't have an apple
    sta APPLE

    lda #0      ; Ensure that we are not in a reset state.
    sta RESET

; game loop
main_loop

    jsr draw_apple

    jsr draw_snake

    jsr scan_key
    jsr delay    
    lda DIR
    beq move_left
    cmp #1
    beq move_down
    cmp #2
    beq move_right
    cmp #3
    beq move_up
    
    jmp main_loop

move_left
    dec SNAKE_X
    jmp check_collision
move_down
    inc SNAKE_Y
    jmp check_collision
move_right
    inc SNAKE_X
    jmp check_collision
move_up
    dec SNAKE_Y
    jmp check_collision

check_collision
    lda SNAKE_X
    beq crash
    clc
    lda SNAKE_X
    cmp #39
    bpl crash
    lda SNAKE_Y
    beq crash
    clc
    lda SNAKE_Y
    cmp #24
    bpl crash

check_apple
    ldx SNAKE_X
    cpx APPLE_X
    beq maybe_ate_apple
    jmp no_collide

maybe_ate_apple
    ldy SNAKE_Y
    cpy APPLE_Y
    beq eat_apple

no_collide
    jmp main_loop

eat_apple
    lda #1          ; reset apple so a noew one is created.
    sta APPLE
    dec DELAY_T
    beq crash
    jmp main_loop

crash
    +puts game_over,2
    +puts restart_instructions,3
    lda #1
    sta RESET
crash_loop
    jsr scan_key
    lda DIR
    cmp #5           ; spacebar is pressed
    beq restart
    jsr delay
    jmp crash_loop   ; wait for space bar to restart.
restart
    jmp main

draw_snake
    ldx SNAKE_X
    ldy SNAKE_Y
    lda #5      ; snake is green 
    sta COLOR
    lda #160    ; snake is a ball
    jsr plotxy
    jsr delay
    ldx SNAKE_X
    ldy SNAKE_Y
    lda #0      ; snake is black (this is how we animate.)
    sta COLOR
    lda #160
    jsr plotxy
    rts
; ****************************************************************************
; pic a random location and draw an orange block for the apple
; ****************************************************************************
draw_apple
    lda APPLE
    beq draw_apple_end  ; do not draw an apple if we already have one.
    jsr rnd_x
    sta APPLE_X
    inc APPLE_X         ; sometimes the apple shows up in the border.
    jsr rnd_y
    sta APPLE_Y

    ldx APPLE_X
    cpx SNAKE_X     ; we can not have an apple in the same place as the snake
    beq draw_apple

    ldy APPLE_Y
    lda #8
    sta COLOR
    lda #42 ; round ball
    jsr plotxy
draw_apple_end
    lda #0
    sta APPLE
    rts

; ****************************************************************************
; read keys and update direction
; ****************************************************************************
scan_key
    ; sei
    lda #$ff         ; write on port A
    sta DDRA
    lda #$00         ; read on port B
    sta DDRB

    lda #%11111101   ; s is in row 2 (the diagram on the wiki is transposed.)
    sta PRA         ; instruct keyboard
    lda PRB         ; read value from keyboard
    and #%00100000   ; s is in column 5 (mask it out)
    beq down_key
    lda PRB
    and #%00000100  ; a is in row 2 and column 3
    beq left_key
    lda PRB
    and #%00000010  ; w is in row 2 and column 2
    beq up_key
    lda #%11111011  ; d is in row 3
    sta PRA
    lda PRB
    and #%00000100  ; d is in colum 3
    beq right_key
    lda #%01111111   ; space is in row 7
    sta PRA
    lda PRB
    and #%00010000  ; space is in column 5
    beq space_bar
    jmp scan_key_noop
down_key
    lda #$01
    sta DIR
    jmp scan_key_noop
up_key
    lda #$03
    sta DIR
    jmp scan_key_noop
left_key
    lda #$00
    sta DIR
    jmp scan_key_noop
right_key
    lda #$02
    sta DIR
    jmp scan_key_noop
space_bar
    lda RESET           ; if we are not in reset mode, do nothing.   
    beq scan_key_noop
    lda #$05
    sta DIR             ; re-use dir for checking if space was pressed
                        ; in crash_loop
    lda #0
    sta RESET           ; turn off reset mode

scan_key_noop
    ; cli
    rts

game_over
    !scr "game over!"
    !byte 0
restart_instructions
    !scr "press [space] to restart."
    !byte 0

!src "./code/screen_routines.asm"
!src "./code/functions.asm"
