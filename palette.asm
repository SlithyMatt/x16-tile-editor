palette_leftclick:
   jsr palette_getindex
   sta fg_color
   jsr palette_sel_update
   rts

palette_rightclick:
   jsr palette_getindex
   ; TODO - edit color
   rts

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