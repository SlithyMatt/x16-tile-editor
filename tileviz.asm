tile_addr:
   .res 3

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
   ; update preview sprite

   rts

