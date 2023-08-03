init_mouse:
   sec
   jsr SCREEN_MODE
   lda #1
   jsr MOUSE_CONFIG
   rts

get_mouse_xy:
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








