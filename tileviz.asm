PREVIEW_SPRITE_ATTR = $1FC08
PREVIEW_SPRITE_X = 64
PREVIEW_SPRITE_Y = 360

init_tileviz:
   lda #(PREV_TILE_X+34)
   sta offset_down_tile_x
   lda #(PREV_TILE_X+37)
   sta offset_up_tile_x
   lda #(PREV_TILE_X+52) 
   sta next_tile_x
   lda #47
   sta tile_num_x
   jsr tileviz_clear_latches
   stz VERA_ctrl
   lda #($10 | ^PREVIEW_SPRITE_ATTR)
   sta VERA_addr_bank
   lda #>PREVIEW_SPRITE_ATTR
   sta VERA_addr_high
   lda #<PREVIEW_SPRITE_ATTR
   sta VERA_addr_low
   stz VERA_data0
   stz VERA_data0
   lda #<PREVIEW_SPRITE_X
   sta VERA_data0
   lda #>PREVIEW_SPRITE_X
   sta VERA_data0
   lda #<PREVIEW_SPRITE_Y
   sta VERA_data0
   lda #>PREVIEW_SPRITE_Y
   sta VERA_data0
   lda #$0C ; Z = 3, no flips
   sta VERA_data0
   lda #$50 ; 16x16, PO = 0
   sta VERA_data0
   rts

load_tile:
   ; calculate tile address
   ; a = width * height * bpp/8 * index
   lda tile_index
   sta tile_addr
   lda tile_index+1
   sta tile_addr+1
   stz tile_addr+2
   lda bits_per_pixel
   sta SB1
   lda tile_width
   sta SB2
@shift_width:
   lda #8
   cmp SB1
   beq @mult_width
   lsr SB2
   asl SB1
   bra @shift_width
@mult_width:
   lda #1
   cmp SB2
   beq @mult_height
   lsr SB2
   asl tile_addr
   rol tile_addr+1
   bra @mult_width
@mult_height:
   lda tile_height
   sta SB1
@mult_height_loop:
   lda #1
   cmp SB1
   beq @load_tile_addr
   lsr SB1
   asl tile_addr
   rol tile_addr+1
   rol tile_addr+2
   bra @mult_height_loop
@load_tile_addr:
   stz VERA_ctrl
   lda tile_addr+2
   ora #$10 ; stride = 1
   sta VERA_addr_bank
   lda tile_addr+1
   sta VERA_addr_high
   lda tile_addr
   sta VERA_addr_low
   ; load tile viz address for port 1
   lda #1
   sta VERA_ctrl
   VERA_SET_ADDR TILE_VIZ,2
   lda tile_width
   sta SB1
   lda tile_height
   sta SB2
@render_tile:
   ldx VERA_data0
   lda bits_per_pixel
   cmp #8
   beq @last_pixel
   cmp #4
   beq @split_4
   cmp #2
   beq @split_2
   ldy #7
@single_bit_loop:
   txa
   asl
   tax
   rol
   and #$1
   sta VERA_data1
   dec SB1
   dey
   bne @single_bit_loop
   txa
   asl
   rol
   tax
   bra @last_pixel
@split_2:
   ldy #3
@two_bit_loop:
   txa
   asl
   rol
   asl
   rol
   tax
   and #$3
   sta VERA_data1
   dec SB1
   dey
   bne @two_bit_loop
   txa
   asl
   rol
   asl
   rol
   and #3
   tax
   bra @last_pixel
@split_4:
   txa
   lsr
   lsr
   lsr
   lsr
   sta VERA_data1
   dec SB1
   txa
   and #$0F
   tax
   @last_pixel:
   stx VERA_data1
   dec SB1
   bne @render_tile
   lda tile_viz_width
   sec
   sbc tile_width
@blackout_width:
   stz VERA_data1
   dec
   bne @blackout_width
   lda tile_width
   sta SB1
   inc VERA_addr_high
   lda #<TILE_VIZ
   sta VERA_addr_low
   dec SB2
   bne @render_tile
   lda tile_viz_height
   sec
   sbc tile_height
   tax
   lda tile_viz_width
   bra @blackout_full_width
@blackout_height:
   inc VERA_addr_high
   lda #<TILE_VIZ
   sta VERA_addr_low
   lda tile_viz_width
@blackout_full_width:
   stz VERA_data1
   dec
   bne @blackout_full_width
   dex
   bne @blackout_height
   ; update display text for tile index
   lda #<tile_index
   sta ZP_PTR_1
   lda #>tile_index
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   ldx tile_num_x
   ldy #4
   jsr print_word_dec
   ; update display text for tile address
   lda #<tile_addr
   sta ZP_PTR_1
   lda #>tile_addr
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   ldx #TILE_ADDR_X
   ldy #TILE_ADDR_Y
   jsr print_vaddr
   ; update preview sprite
   stz VERA_ctrl
   lda #($10 | ^PREVIEW_SPRITE_ATTR)
   sta VERA_addr_bank
   lda #>PREVIEW_SPRITE_ATTR
   sta VERA_addr_high
   lda #<PREVIEW_SPRITE_ATTR
   sta VERA_addr_low
   lda tile_addr+2
   sta SB2
   lda tile_addr+1
   sta SB1
   lda tile_addr
   lsr SB2
   ror SB1
   ror
   ldx #4
@shift_tile_addr:
   lsr SB1
   ror
   dex
   bne @shift_tile_addr
   sta VERA_data0
   lda SB1
   ; TODO set mode bit if 8bpp
   sta VERA_data0
   ; TODO set X/Y
   lda VERA_data0 ; preserve Z and flips
   ; TODO set height/width/PO
   rts

tileviz_clear_latches:
   stz prev_latch
   stz next_latch
   stz offset_down_latch
   stz offset_up_latch
   stz VERA_ctrl
   lda #$21
   sta VERA_addr_bank
   lda #$B3
   sta VERA_addr_high
   lda #(PREV_TILE_X * 2)
   sta VERA_addr_low
   ldx #0
@loop:
   lda init_prev_string,x
   sta VERA_data0
   inx
   cpx #59
   bne @loop
   rts

tile_navigate:
   cpx #PREV_TILE_X
   bmi @return
   cpx #PREV_TILE_X+12
   bpl @check_down
   lda prev_latch
   bne @return
   lda tile_index
   beq @return
   jsr do_prev
   bra @return
@check_down:
   cpx offset_down_tile_x
   bne @check_up
   lda offset_down_latch
   bne @return
   lda palette_offset
   beq @return
   jsr do_offset_down
   bra @return
@check_up:
   cpx offset_up_tile_x
   bne @check_next
   lda offset_up_latch
   bne @return
   lda palette_offset
   cmp #15
   beq @return
   jsr do_offset_up
   bra @return
@check_next:
   cpx next_tile_x
   bmi @return
   lda next_tile_x
   clc
   adc #7
   stx SB1
   cmp SB1
   bmi @return
   lda next_latch
   bne @return
   ; TODO check for last tile
   jsr do_next
@return:
   rts

do_prev:
   inc prev_latch
   dec tile_index
   stz VERA_ctrl
   lda #$21
   sta VERA_addr_bank
   lda #$B3
   sta VERA_addr_high
   lda #(PREV_TILE_X * 2)
   sta VERA_addr_low
   ldx #0
@loop:
   lda init_prev_string,x
   ora #$80
   sta VERA_data0
   inx
   cpx #11
   bne @loop
   jsr load_tile
   rts

do_next:
   inc next_latch
   inc tile_index
   stz VERA_ctrl
   lda #$21
   sta VERA_addr_bank
   lda #$B3
   sta VERA_addr_high
   lda next_tile_x
   asl
   sta VERA_addr_low
   ldx #0
@loop:
   lda init_next_string,x
   ora #$80
   sta VERA_data0
   inx
   cpx #7
   bne @loop
   jsr load_tile
   rts

do_offset_down:
   inc offset_down_latch
   dec palette_offset


   jsr load_tile
   rts

do_offset_up:
   inc offset_up_latch
   inc palette_offset


   jsr load_tile
   rts

tileviz_leftclick:
   rts
