.org $1000
.bss
.include "bss.asm"

.org $3000 ; TODO: Change to $C000 for ROM
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
.include "menus.asm"
.include "chooser.asm"
.include "options.asm"

TILE_MAP = $1A800

start:
   jsr flush_keyboard
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
   lda exit_req
   bne @exit
   wai
   lda cursor_state
   beq @check_hotkey
   lda chooser_visible
   beq @check_tileset_size
   jsr chooser_cursor_tick
   bra @loop
@check_tileset_size:
   lda tileset_size_visible
   beq @loop ; future? - check for other cursors
   jsr tileset_size_cursor_tick
   bra @loop
@check_hotkey:
   ; keyboard not captured, check for hotkey
   jsr GETIN
   cmp #0
   beq @loop
   cmp #$AE ; X-S key
   bne @loop ; TODO - check more keys via table
   jsr save_tile_file
   bra @loop
@exit:
   jsr load_default_palette
   lda #2 ; return to upper case
   jsr SCREEN_SET_CHARSET
   lda #0
   clc
   jsr SCREEN_MODE 
   lda VERA_L1_config
   and #$F7 ; clear T256
   sta VERA_L1_config
   lda #0
   jsr MOUSE_CONFIG
   stz VERA_ctrl
   VERA_SET_ADDR (PREVIEW_SPRITE_ATTR+6),0
   stz VERA_data0
   rts ; return to BASIC
   

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
   stz menu_visible
   stz exit_req
   stz filename_stage+28
   stz selected_file+28
   stz chooser_visible
   lda #$43
   sta dos_cd_start
   lda #$44
   sta dos_cd_start+1
   lda #$3A
   sta dos_cd_start+2
   stz cursor_state
   stz tileset_size_visible
   stz prg_header
   rts

left_click:
   lda menu_visible
   bne @do_menu
   lda chooser_visible
   bne @do_chooser
   lda tileset_size_visible
   bne @do_tileset_size
   cpy #1
   bne @check_main
@do_menu:
   jmp menu_click ; tail-optimization
@do_chooser:
   jmp chooser_click ; tail-optimization
@do_tileset_size:
   jmp tileset_size_click ; tail-optimization
@check_main:
   cpy #3
   bne @check_tile_viz
   jmp tile_navigate ; tail-optimization
@check_tile_viz:
   cpy #TILE_VIZ_Y
   bmi @return
   cpx #TILE_VIZ_X
   bmi @check_palette
   jmp tileviz_leftclick ; tail-optimization
@check_palette:
   cpy #21
   bpl @check_tools
   cpx #1
   bmi @return
   cpx #17
   bpl @return
   jmp palette_leftclick ; tail-optimization
@check_tools:
   jsr tools_click
@return:
   rts

right_click:
   lda menu_visible
   bne @return
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

flush_keyboard:
   jsr GETIN
   cmp #0
   bne flush_keyboard
   rts

