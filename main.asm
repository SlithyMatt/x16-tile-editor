.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

.include "x16.inc"
.include "charmap.inc"
.include "globals.asm"
.include "initscreen.asm"
.include "tileviz.asm"
.include "mouse.asm"
.include "palette.asm"
.include "tools.asm"
.include "print.asm"

TILE_MAP = $1A800

start:
   jsr init_globals
   jsr init_mouse
   jsr load_initscreen
   ; setup layer 0 as work layer, using default settings
   lda #$02 ; 32x32 4bpp
   sta VERA_L0_config
   lda #(TILE_MAP>>9)
   sta VERA_L0_mapbase
   lda #$03 ; tilebase $00000, 16x16 tiles
   sta VERA_L0_tilebase   
   ; load tile 0
   jsr load_tile
@loop:
   jsr get_mouse_xy
   bit #1 ; process left button click first
   pha ; store button state on stack
   beq @clear_latches
   jsr left_click
   bra @check_right_button
@clear_latches:
   jsr tileviz_clear_latches
@check_right_button:
   pla ; restore button state
   bit #2
   beq @sleepytime
   jsr right_click
@sleepytime:
   wai
   ; TODO check keyboard buffer
   bra @loop
   rts

left_click:
   ; TODO: check menu bar
   cpy #3
   bne @check_tile_viz
   jsr tile_navigate
   bra @return
@check_tile_viz:
   cpy #5
   bmi @return
   cpx #20
   bmi @check_palette
   jsr tileviz_leftclick
@check_palette:
   cpy #21
   bpl @check_tools
   jsr palette_leftclick
@check_tools:
   jsr tools_click
@return:
   rts

right_click:
   rts