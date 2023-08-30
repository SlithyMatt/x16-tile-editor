.include "default_pal.asm"

palette_leftclick:
   lda rgb_gui_on
   bne @check_gui
   lda button_latch
   bne @return
   jmp palette_select_fg_color ; tail-optimization
@check_gui:
   jmp check_rgb_gui_click ; tail-optimization
@return:
   rts


palette_select_fg_color:
   jsr palette_getindex
   sta fg_color
   jmp palette_sel_update ; tail-oprimization


palette_getindex: ; input: X,Y = screen coordinates
                  ; ouput: A = palette index
   tya
   sec
   sbc #TILE_VIZ_Y  ; A = relative Y
   asl
   asl
   asl
   asl
   dex
   stx SB1 ; relative X
   clc
   adc SB1 ; A = Y*16+X
   rts

palette_sel_update:
   ; load foreground color
   stz VERA_ctrl
   VERA_SET_ADDR FG_COLOR_BOX,2
   ldx #3
@fgc_loop:
   lda fg_color
   sta VERA_data0
   sta VERA_data0
   sta VERA_data0
   inc VERA_addr_high
   lda #<FG_COLOR_BOX
   sta VERA_addr_low
   dex
   bne @fgc_loop
   ; load background color
   VERA_SET_ADDR BG_COLOR_BOX,2
   ldx #3
@bgc_loop:
   lda bg_color
   sta VERA_data0
   sta VERA_data0
   sta VERA_data0
   inc VERA_addr_high
   lda #<BG_COLOR_BOX
   sta VERA_addr_low
   dex
   bne @bgc_loop
   ; update foreground index label
   lda fg_color
   ldx #3
   ldy #27
   jsr print_byte_dec
   ; update background index label
   lda bg_color
   ldx #12
   ldy #27
   jsr print_byte_dec
   rts

init_palette:
   stz rgb_gui_on
   jsr load_pal_file
   lda file_error
   bne @load_default
   rts
@load_default:
   stz file_error
   ; TODO stop LED flashing
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_palette,1
   ldx #0
@loop1:
   lda default_palette,x
   sta VERA_data0
   inx
   bne @loop1
@loop2:
   lda default_palette_midpoint,x
   sta VERA_data0
   inx
   bne @loop2
   rts

RGB_GUI_X = 5
RGB_GUI_Y = 13

rgb_gui:
.byte $70,$40,$6E,"     "
.byte "|X|     "
.byte $6B,$40,$5B,$40,$72,$40,$6E," "
.byte "|R|G|B| "
.byte $6B,$40,$5B,$40,$5B,$40,$73," "
.byte "|",$F1,"|",$F1,"|",$F1,"| "
.byte "|0|0|0| "
.byte "|",$F2,"|",$F2,"|",$F2,"| "
.byte $71,$40,$71,$40,$71,$40,$71,$40

palette_rightclick:
   lda rgb_gui_on
   bne @return
   jsr palette_select_fg_color
   ; show RGB GUI
   stz VERA_ctrl
   lda #$11
   sta VERA_addr_bank
   lda #($B0 + RGB_GUI_Y)
   sta VERA_addr_high
   lda #(RGB_GUI_X * 2)
   sta VERA_addr_low
   ldx #0
   ldy #(22 - RGB_GUI_Y)
@loop:
   lda rgb_gui,x
   sta VERA_data0
   lda #1 ; force it to default UI color
   sta VERA_data0
   inx
   txa
   and #$07
   bne @loop
   inc VERA_addr_high
   lda #(RGB_GUI_X * 2)
   sta VERA_addr_low
   dey
   bne @loop
   jsr print_fg_rgb
   inc rgb_gui_on ; RGB GUI is on, disable palette selection until closed
@return:
   rts

print_fg_rgb:
   jsr load_fgc_red
   jsr get_hex_char
   ldx #(RGB_GUI_X+1)
   ldy #(RGB_GUI_Y+6)
   jsr print_char
   jsr load_fgc_gb
   lsr
   lsr
   lsr
   lsr
   jsr get_hex_char
   ldx #(RGB_GUI_X+3)
   ldy #(RGB_GUI_Y+6)
   jsr print_char
   jsr load_fgc_gb
   and #$0F
   jsr get_hex_char
   ldx #(RGB_GUI_X+5)
   ldy #(RGB_GUI_Y+6)
   jmp print_char ; tail-optimization

check_rgb_gui_click:
   lda button_latch
   bne @return
   cpy #(RGB_GUI_Y+1)
   bmi @return
   bne @check_up
   cpx #(RGB_GUI_X+1)
   bne @return
   jmp close_rgb_gui ; tail-optimization
@check_up:
   cpy #(RGB_GUI_Y+5)
   bne @check_down
   cpx #(RGB_GUI_X+1)
   bne @check_g_up
   jmp fgc_red_up ; tail-optimization
@check_g_up:
   cpx #(RGB_GUI_X+3)
   bne @check_b_up
   jmp fgc_green_up ; tail-optimization
@check_b_up:
   cpx #(RGB_GUI_X+5)
   bne @return
   jmp fgc_blue_up ; tail-optimization
@check_down:
   cpy #(RGB_GUI_Y+7)
   bne @return
   cpx #(RGB_GUI_X+1)
   bne @check_g_down
   jmp fgc_red_down ; tail-optimization
@check_g_down:
   cpx #(RGB_GUI_X+3)
   bne @check_b_down
   jmp fgc_green_down ; tail-optimization
@check_b_down:
   cpx #(RGB_GUI_X+5)
   bne @return
   jmp fgc_blue_down ; tail-optimization
@return:
   rts


close_rgb_gui:
   inc button_latch
   stz VERA_ctrl
   lda #$11
   sta VERA_addr_bank
   lda #($B0 + RGB_GUI_Y)
   sta VERA_addr_high
   lda #(RGB_GUI_X * 2)
   sta VERA_addr_low
   ldx #0
   ldy #(21 - RGB_GUI_Y)
@loop:
   lda #$A0 ; back to inverted space
   sta VERA_data0
   sty SB1
   lda #16
   sec
   sbc SB1
   asl
   asl
   asl
   asl
   sta SB1
   txa
   and #$07
   clc
   adc #(RGB_GUI_X-1)
   ora SB1
   sta VERA_data0 ; back to palette color
   inx
   txa
   and #$07
   bne @loop
   inc VERA_addr_high
   lda #(RGB_GUI_X * 2)
   sta VERA_addr_low
   dey
   bne @loop
   ldx #$40
   ldy #7
@bar_loop:
   stx VERA_data0 ; back to horizontal bar
   lda VERA_data0 ; skip color
   dey
   bne @bar_loop
   stz rgb_gui_on ; re-enable palette selection
@return:
   rts

load_fgc_red:
   jsr load_pal_bank_high
   lda fg_color
   sec
   rol
   sta VERA_addr_low
   lda VERA_data0
   rts

load_pal_bank_high:
   inc button_latch
   stz VERA_ctrl
   lda #$01 ; zero stride
   sta VERA_addr_bank
   lda #>VRAM_palette
   bit fg_color
   bpl @set_high_addr
   inc
@set_high_addr:
   sta VERA_addr_high
   rts

load_fgc_gb:
   jsr load_pal_bank_high
   lda fg_color
   asl
   sta VERA_addr_low
   lda VERA_data0
   rts

fgc_red_up:
   jsr load_fgc_red
   inc
   and #$0F
   sta VERA_data0
   jmp print_fg_rgb ; tail-optimization

fgc_green_up:
   jsr load_fgc_gb
   clc
   adc #$10
   sta VERA_data0
   jmp print_fg_rgb ; tail-optimization

fgc_blue_up:
   jsr load_fgc_gb
   sta SB1
   inc
   and #$0F
   sta SB2
   lda SB1
   and #$F0
   ora SB2
   sta VERA_data0
   jmp print_fg_rgb ; tail-optimization

fgc_red_down:
   jsr load_fgc_red
   dec
   and #$0F
   sta VERA_data0
   jmp print_fg_rgb ; tail-optimization

fgc_green_down:
   jsr load_fgc_gb
   sec
   sbc #$10
   sta VERA_data0
   jmp print_fg_rgb ; tail-optimization

fgc_blue_down:
   jsr load_fgc_gb
   sta SB1
   dec
   and #$0F
   sta SB2
   lda SB1
   and #$F0
   ora SB2
   sta VERA_data0
   jmp print_fg_rgb ; tail-optimization

