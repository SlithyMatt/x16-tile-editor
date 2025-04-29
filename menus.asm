FILE_X = 1
VIEW_X = 11
OPTIONS_X = 21
ABOUT_X = 72
ABOUT_PANEL_X = 24
ABOUT_PANEL_Y = 12

FILE_MENU_VISIBLE = 1
VIEW_MENU_VISIBLE = 2
OPTIONS_MENU_VISIBLE = 3
ABOUT_PANEL_VISIBLE = 4

menu_click:
   lda button_latch
   bne @return
   inc button_latch
   lda menu_visible
   beq @check_file
   jmp menu_visible_click ; tail-optimization
@check_file:
   cpx #FILE_X
   bmi @return
   cpx #(FILE_X+9)
   bpl @check_view
   jmp show_file_menu ; tail-optimization
@check_view:
   cpx #VIEW_X
   bmi @return
   cpx #(VIEW_X+9)
   bpl @check_options
   jmp show_view_menu ; tail-optimization
@check_options:
   cpx #OPTIONS_X
   bmi @return
   cpx #(OPTIONS_X+9)
   bpl @check_about
   jmp show_options_menu
@check_about:
   cpx #ABOUT_X
   bmi @return
   cpx #(ABOUT_X+7)
   bpl @return
   jmp show_about_panel
@return:
   rts

menu_visible_click:
   cpy #3
   bmi @reset
   lda menu_visible
   cmp #ABOUT_PANEL_VISIBLE
   beq @reset ; always reset on any click when "about" panel is visible
   cmp #FILE_MENU_VISIBLE
   bne @check_view
   jmp file_menu_click ; tail-optimization
@check_view:
   cmp #VIEW_MENU_VISIBLE
   bne @check_options
   jmp view_menu_click ; tail-optimization
@check_options:
   cmp #OPTIONS_MENU_VISIBLE
   bne @reset ; shouldn't happen, but reset just in case
   jmp options_menu_click ; tail-optimization
@reset:
   jmp reset_menu ; tail-optimization


file_menu_block:
   .byte $6b
   .repeat 9
      .byte $40
   .endrepeat
   .byte $71
   .repeat 4
      .byte $40
   .endrepeat
   .byte $72

   .byte "| Open Tiles   |"
   .byte "| Open Palette |"
   .byte "| Save         |"
   .byte "| Save As...   |"
   .byte "| Exit         |"

   .byte $6D
   .repeat 14
      .byte $40
   .endrepeat
   .byte $7D

show_file_menu:
   lda #FILE_MENU_VISIBLE
   sta menu_visible
   ldx #(FILE_X-1)
   ldy #2
   jsr print_set_vera_addr
   lda #$11
   sta VERA_addr_bank ; set stride to 1
   ldx #0
   ldy #7
@loop:
   lda file_menu_block,x
   sta VERA_data0 ; print character
   lda #$01
   sta VERA_data0 ; make UI color
   inx
   txa
   and #$0F
   bne @loop
   inc VERA_addr_high
   lda #((FILE_X-1)*2)
   sta VERA_addr_low
   dey
   bne @loop
   rts

file_menu_click:
   cpy #8
   bpl @reset
   cpx #FILE_X
   bmi @reset
   cpx #(FILE_X+14)
   bpl @reset
   cpy #3
   bne @check_open_palette
   jsr reset_menu
   jmp chooser_open_tiles ; tail-optimization
@check_open_palette:
   cpy #4
   bne @check_save
   jsr reset_menu
   jmp chooser_open_pal ; tail-optimization
@check_save:
   cpy #5
   bne @check_save_as
   jsr save_tile_file
   bra @reset
@check_save_as:
   cpy #6
   bne @check_exit
   jsr reset_menu
   jmp chooser_save_as ; tail-optimization
@check_exit:
   cpy #7
   bne @reset ; should never happen, but reset just in case
   inc exit_req
   rts
@reset:
   jmp reset_menu ; tail-optimization

view_menu_block:
   .byte $6b
   .repeat 9
      .byte $40
   .endrepeat
   .byte $71
   .repeat 9
      .byte $40
   .endrepeat
   .byte $73

   .byte "| Tile Sheet        |"
   .byte "| Zoom Preview x2   |"

   .byte $6D
   .repeat 19
      .byte $40
   .endrepeat
   .byte $7D 

show_view_menu:
   lda #VIEW_MENU_VISIBLE
   sta menu_visible
   ldx #(VIEW_X-1)
   ldy #2
   jsr print_set_vera_addr
   lda #$11
   sta VERA_addr_bank ; set stride to 1
   lda #21
   sta SB1
   ldx #0
   ldy #4
@loop:
   lda view_menu_block,x
   sta VERA_data0 ; print character
   lda #$01
   sta VERA_data0 ; make UI color
   inx
   cpx SB1
   bne @loop
   txa
   clc
   adc #21
   sta SB1
   inc VERA_addr_high
   lda #((VIEW_X-1)*2)
   sta VERA_addr_low
   dey
   bne @loop
   lda preview_2x
   beq @return
   ldx #(VIEW_X+17)
   ldy #4
   lda #$7A
   jsr print_char
@return:
   rts

view_menu_click:
   cpy #5
   bpl @reset
   cpx #VIEW_X
   bmi @reset
   cpx #(VIEW_X+19)
   bpl @reset
   cpy #3
   bne @check_preview
   jsr reset_menu
   ; TODO show tile map view
   rts
@check_preview:
   cpy #4
   bne @reset
   jsr reset_menu
   jmp toggle_preview_2x ; tail-optimization   
@reset:
   jmp reset_menu ; tail-optimization


options_menu_block:
   .byte $6b
   .repeat 9
      .byte $40
   .endrepeat
   .byte $71
   .repeat 14
      .byte $40
   .endrepeat
   .byte $6e

   .byte "| Use PRG File Headers   |"
   .byte "| CRT Mode               |"
   .byte "| Max Set Size:          |"

   .byte $6D
   .repeat 24
      .byte $40
   .endrepeat
   .byte $7D 

show_options_menu:
   lda #OPTIONS_MENU_VISIBLE
   sta menu_visible
   ldx #(OPTIONS_X-1)
   ldy #2
   jsr print_set_vera_addr
   lda #$11
   sta VERA_addr_bank ; set stride to 1
   lda #26
   sta SB1
   ldx #0
   ldy #5
@loop:
   lda options_menu_block,x
   sta VERA_data0 ; print character
   lda #$01
   sta VERA_data0 ; make UI color
   inx
   cpx SB1
   bne @loop
   txa
   clc
   adc #26
   sta SB1
   inc VERA_addr_high
   lda #((OPTIONS_X-1)*2)
   sta VERA_addr_low
   dey
   bne @loop
   lda prg_header
   beq @print_tile_count
   ldx #(OPTIONS_X+22)
   ldy #3
   lda #$7A
   jsr print_char
@print_tile_count:
   lda #<tile_count
   sta ZP_PTR_1
   lda #>tile_count
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   ldx #(OPTIONS_X+15)
   ldy #5
   jmp print_word_dec ; tail-optimization


options_menu_click:
   cpy #6
   bpl @reset
   cpx #OPTIONS_X
   bmi @reset
   cpx #(OPTIONS_X+24)
   bpl @reset
   cpy #3
   bne @check_crt
   jsr reset_menu
   jmp toggle_prg_header ; tail-optimization
@check_crt:
   cpy #4
   bne @check_size
   jsr reset_menu
   jmp toggle_crt_mode ; tail-optimization
@check_size:
   cpy #5
   bne @reset
   jsr reset_menu
   jmp set_tileset_size ; tail-optimization
@reset:
   jmp reset_menu ; tail-optimization


about_panel_block:
   .byte $70
   .repeat 47
      .byte $40
   .endrepeat
   .byte $6e

   .byte "| X16 Tile Editor - Version 0.0.4a              |"
   .byte "| by Matt Heffernan                             |"
   .byte "| https://github.com/slithymatt/x16-tile-editor |"

   .byte $6d
   .repeat 47
      .byte $40
   .endrepeat
   .byte $7d

show_about_panel:
   lda #ABOUT_PANEL_VISIBLE
   sta menu_visible
   ldx #ABOUT_PANEL_X
   ldy #ABOUT_PANEL_Y
   jsr print_set_vera_addr
   lda #$11
   sta VERA_addr_bank ; set stride to 1
   lda #49
   sta SB1
   ldx #0
   ldy #5
@loop:
   lda about_panel_block,x
   sta VERA_data0
   lda #1
   sta VERA_data0
   inx
   cpx SB1
   bne @loop
   txa
   clc
   adc #49
   sta SB1
   inc VERA_addr_high
   lda #(ABOUT_PANEL_X*2)
   sta VERA_addr_low
   dey
   bne @loop
   rts

reset_menu:
   ldx #0
   ldy #2
   jsr print_set_vera_addr
   lda #<menu_bottom
   sta ZP_PTR_1
   lda #>menu_bottom
   sta ZP_PTR_1+1
   ldx #7
   ldy #0
@init_loop:
   lda (ZP_PTR_1),y
   sta VERA_data0
   iny
   cpy #80
   bne @init_loop
   tya
   clc
   adc ZP_PTR_1
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   inc VERA_addr_high
   stz VERA_addr_low
   ldy #0
   dex
   bne @init_loop
   ; reload current palette
   VERA_SET_ADDR PAL_VIZ,1
   ldx #0
   ldy #0
@pal_loop:
   lda #$A0
   sta VERA_data0
   stx VERA_data0   
   iny
   cpy #16
   bne @next_color
   ldy #0
   inc VERA_addr_high
   lda #<PAL_VIZ
   sta VERA_addr_low
@next_color:
   inx
   cpx #$3F ; first currently visible color
   bne @pal_loop
   jsr print_offset
   jsr load_tile
   stz menu_visible
   rts
   