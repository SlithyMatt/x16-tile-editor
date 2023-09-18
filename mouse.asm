DOUBLE_CLICK_THRESHOLD = 29 ; 60Hz jiffies

init_mouse:
   ; reset mouse
   lda #0
   jsr MOUSE_CONFIG
   ; use current screen mode to define mouse resolution
   sec
   jsr SCREEN_MODE
   lda #1 ; use default cursor
   jsr MOUSE_CONFIG
   rts

get_mouse_xy:
   lda double_click_countdown
   beq @get_mouse_data
   dec double_click_countdown
@get_mouse_data:
   ldx #MOUSE_X
   jsr MOUSE_GET ; mouse scanned on last IRQ
   pha ; put mouse buttons on stack
   ; divide by 8
   lsr MOUSE_X+1
   ror MOUSE_X
   lsr MOUSE_X+1
   ror MOUSE_X
   lsr MOUSE_X+1
   ror MOUSE_X

   ldx MOUSE_X ; x = character X coordinate
   ; divide by 8
   lsr MOUSE_Y+1
   ror MOUSE_Y
   lsr MOUSE_Y+1
   ror MOUSE_Y
   lsr MOUSE_Y+1
   ror MOUSE_Y
   ldy MOUSE_Y ; y = character Y coordinate
   pla ; a = mouse button states
   rts

check_double_click: ; Input: X/Y = mouse cursor character coordinates
                    ; Output: Carry = 0 -> single click, set countdown, 1 -> double click, reset countdown
   lda double_click_countdown
   beq @set
   cpx double_click_x
   bne @set
   cpy double_click_y
   bne @set
   stz double_click_countdown
   sec
   rts
@set:
   stx double_click_x
   sty double_click_y
   lda #DOUBLE_CLICK_THRESHOLD
   sta double_click_countdown
   clc
   rts






