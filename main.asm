.org $1000
.bss
.include "bss.asm"

.org $2000 ; TODO: Change to $C000 for ROM
.code
   jmp start

.include "x16.inc"
.include "charmap.inc"
.include "initscreen.asm"
.include "tileviz.asm"
.include "mouse.asm"
.include "palette.asm"
.include "tools.asm"
.include "print.asm"
.include "files.asm"

TILE_MAP = $1A800

start:
   jsr init_globals
   jsr init_mouse
   jsr load_initscreen
   jsr init_tileviz
   jsr init_tools
   ; setup layer 0 as work layer, using default settings
   lda #$02 ; 32x32 4bpp
   sta VERA_L0_config
   lda #(TILE_MAP>>9)
   sta VERA_L0_mapbase
   lda #$03 ; tilebase $00000, 16x16 tiles
   sta VERA_L0_tilebase
   ; attempt to load default files
   jsr init_filenames
   jsr load_tile_file
   jsr init_palette
   ; load tile 0
   jsr load_tile
@loop:
   jsr print_file_error
   jsr get_mouse_xy
   bit #1 ; process left button click first
   pha ; store button state on stack
   beq @clear_latch
   jsr left_click
   bra @check_right_button
@clear_latch:
   stz button_latch
   jsr tileviz_reset
   jsr tools_reset
@check_right_button:
   pla ; restore button state
   bit #2
   beq @sleepytime
   jsr right_click
@sleepytime:
   wai
   ; check keyboard buffer
   jsr GETIN
   cmp #0
   beq @loop
   cmp #$53 ; S key
   bne @loop ; TODO - check more keys via table
   jsr save_tile_file
   jsr save_pal_file
   bra @loop
   rts

init_globals:
   stz sprite_mode
   lda #16
   sta tile_height
   sta tile_width
   lda #1
   sta fg_color
   stz tile_index
   stz tile_index+1
   stz bg_color
   lda #4
   sta bits_per_pixel
   stz palette_offset
   lda #57
   sta tile_viz_width
   lda #52
   sta tile_viz_height
   jsr reset_tile_count
   stz button_latch
   rts

left_click:
   ; TODO: check menu bar
   cpy #3
   bne @check_tile_viz
   jsr tile_navigate
   bra @return
@check_tile_viz:
   cpy #TILE_VIZ_Y
   bmi @return
   cpx #TILE_VIZ_X
   bmi @check_palette
   jsr tileviz_leftclick
   bra @return
@check_palette:
   cpy #21
   bpl @check_tools
   cpx #1
   bmi @return
   cpx #17
   bpl @return
   jsr palette_leftclick
   bra @return
@check_tools:
   jsr tools_click
@return:
   rts

right_click:
   cpy #TILE_VIZ_Y
   bmi @return
   cpx #TILE_VIZ_X
   bmi @check_palette
   jmp tileviz_rightclick ; tail-optimization
@check_palette:
   cpy #21
   bpl @return
   cpx #1
   bmi @return
   cpx #17
   bpl @return
   jmp palette_rightclick ; tail-optimization
@return:
   rts


