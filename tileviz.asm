PREVIEW_SPRITE_ATTR = $1FC08
PREVIEW_SPRITE_X = 40
PREVIEW_SPRITE_Y = 336
TILE_VIZ_X = 20
TILE_VIZ_Y = 5

max_tiles:
   .word 256   ; 8x8x1bpp
   .word 1024  ; 8x8x2bpp
   .word 1024  ; 8x8x4bpp
   .word 1024  ; 8x8x8bpp
   .word 256   ; 8x16x1bpp
   .word 1024  ; 8x16x2bpp
   .word 1024  ; 8x16x4bpp
   .word 848   ; 8x16x8bpp
   .word 256   ; 8x32x1bpp - invalid
   .word 1024  ; 8x32x2bpp - invalid
   .word 848   ; 8x32x4bpp
   .word 424   ; 8x32x8bpp
   .word 256   ; 8x64x1bpp - invalid
   .word 848   ; 8x64x2bpp - invalid
   .word 424   ; 8x64x4bpp
   .word 212   ; 8x64x8bpp
   .word 256   ; 16x8x1bpp
   .word 1024  ; 16x8x2bpp
   .word 1024  ; 16x8x4bpp
   .word 848   ; 16x8x8bpp
   .word 256   ; 16x16x1bpp
   .word 1024  ; 16x16x2bpp
   .word 848   ; 16x16x4bpp
   .word 424   ; 16x16x8bpp
   .word 256   ; 16x32x1bpp - invalid
   .word 848   ; 16x32x2bpp - invalid
   .word 424   ; 16x32x4bpp
   .word 212   ; 16x32x8bpp
   .word 256   ; 16x64x1bpp - invalid
   .word 424   ; 16x64x2bpp - invalid
   .word 212   ; 16x64x4bpp
   .word 106   ; 16x64x8bpp
   .word 256   ; 32x8x1bpp - invalid
   .word 1024  ; 32x8x2bpp - invalid
   .word 848   ; 32x8x4bpp
   .word 424   ; 32x8x8bpp
   .word 256   ; 32x16x1bpp - invalid
   .word 848   ; 32x16x2bpp - invalid
   .word 424   ; 32x16x4bpp
   .word 212   ; 32x16x8bpp
   .word 256   ; 32x32x1bpp - invalid
   .word 424   ; 32x32x2bpp - invalid
   .word 212   ; 32x32x4bpp
   .word 106   ; 32x32x8bpp
   .word 256   ; 32x64x1bpp - invalid
   .word 212   ; 32x64x2bpp - invalid
   .word 106   ; 32x64x4bpp
   .word 53    ; 32x64x8bpp
   .word 256   ; 64x8x1bpp - invalid
   .word 848   ; 64x8x2bpp - invalid
   .word 424   ; 64x8x4bpp
   .word 212   ; 64x8x8bpp
   .word 256   ; 64x16x1bpp - invalid
   .word 424   ; 64x16x2bpp - invalid
   .word 212   ; 64x16x4bpp
   .word 106   ; 64x16x8bpp
   .word 256   ; 64x32x1bpp - invalid
   .word 212   ; 64x32x2bpp - invalid
   .word 106   ; 64x32x4bpp
   .word 53    ; 64x32x8bpp
   .word 212   ; 64x64x1bpp - invalid
   .word 106   ; 64x64x2bpp - invalid
   .word 53    ; 64x64x4bpp
   .word 26    ; 64x64x8bpp


init_tileviz:
   lda #(PREV_TILE_X+34)
   sta offset_down_tile_x
   lda #(PREV_TILE_X+37)
   sta offset_up_tile_x
   lda #(PREV_TILE_X+52) 
   sta next_tile_x
   lda #46
   sta tile_num_x
   jsr tileviz_reset
   stz VERA_ctrl
   lda #($10 | ^PREVIEW_SPRITE_ATTR)
   sta VERA_addr_bank
   lda #>PREVIEW_SPRITE_ATTR
   sta VERA_addr_high
   lda #<PREVIEW_SPRITE_ATTR
   sta VERA_addr_low
   stz VERA_data0
   stz VERA_data0
   jsr center_preview_sprite
   lda preview_x
   sta VERA_data0
   lda preview_x+1
   sta VERA_data0
   lda preview_y
   sta VERA_data0
   lda preview_y+1
   sta VERA_data0
   lda #$0C ; Z = 3, no flips
   sta VERA_data0
   lda #$50 ; 16x16, PO = 0
   sta VERA_data0
   rts

reset_tile_count:
   lda tile_width
   lsr
   lsr
   lsr
   lsr
   bit #$04
   beq @reset_width
   lda #$30
   bra @add_height
@reset_width:
   asl
   asl
   asl
   asl
@add_height:
   sta SB1
   lda tile_height
   lsr
   lsr
   lsr
   lsr
   bit #$04
   beq @reset_height
   lda #$C0
   bra @add_depth
@reset_height:
   asl
   asl
@add_depth:
   ora SB1
   sta SB1
   lda bits_per_pixel
   lsr
   bit #$04
   beq @set_index
   lda #$03
@set_index:
   ora SB1
   asl
   tax
   lda max_tiles+1,x
   cmp tile_count+1
   bmi @set_count
   bne @return
   lda max_tiles,x
   bmi @high_comp
   lda tile_count
   bmi @set_count
   cmp max_tiles,x
   bmi @return
   bra @set_count
@high_comp:
   lda tile_count
   bpl @set_count
   cmp max_tiles,x
   bmi @return
@set_count:
   lda max_tiles+1,x
   sta tile_count+1
   lda max_tiles,x
   sta tile_count
@return:
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
   VERA_SET_ADDR TILE_VIZ,1
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
   lda #$A0
   sta VERA_data1
   txa
   asl
   tax
   rol
   and #$1
   jsr apply_offset
   sta VERA_data1
   dec SB1
   dey
   bne @single_bit_loop
   txa
   asl
   rol
   jsr apply_offset
   tax
   bra @last_pixel
@split_2:
   ldy #3
@two_bit_loop:
   lda #$A0
   sta VERA_data1
   txa
   asl
   rol
   tax
   rol
   and #$3
   jsr apply_offset
   sta VERA_data1
   dec SB1
   dey
   bne @two_bit_loop
   txa
   asl
   rol
   rol
   and #3
   jsr apply_offset
   tax
   bra @last_pixel
@split_4:
   lda #$A0
   sta VERA_data1
   txa
   lsr
   lsr
   lsr
   lsr
   jsr apply_offset
   sta VERA_data1
   dec SB1
   txa
   and #$0F
   jsr apply_offset
   tax
@last_pixel:
   lda #$A0
   sta VERA_data1
   stx VERA_data1
   dec SB1
   bne @render_tile
   lda VERA_data1
   lda VERA_data1 ; skip over line
   lda tile_viz_width
   sec
   sbc tile_width
   dec
@blackout_width:
   pha
   lda #$A0
   sta VERA_data1
   pla
   stz VERA_data1
   dec
   bne @blackout_width
   lda tile_width
   sta SB1
   inc VERA_addr_high
   lda #<TILE_VIZ
   sta VERA_addr_low
   dec SB2
   beq @calculate_height
   jmp @render_tile
@calculate_height:
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
   pha
   lda #$A0
   sta VERA_data1
   pla
   stz VERA_data1
   dec
   bne @blackout_full_width
   dex
   bne @blackout_height
   ; draw box around tile
   stz VERA_ctrl
   lda #$91
   sta VERA_addr_bank
   lda #($B0 + TILE_VIZ_Y - 1)
   sta VERA_addr_high
   lda #TILE_VIZ_X
   clc
   adc tile_width
   asl
   sta VERA_addr_low
   pha
   lda #$72
   sta VERA_data0
   lda #1
   sta VERA_ctrl
   lda #$91
   sta VERA_addr_bank
   lda #($B0 + TILE_VIZ_Y)
   sta VERA_addr_high
   pla
   inc
   sta VERA_addr_low
   ldx tile_height
@right_border_loop:
   lda #$5D
   sta VERA_data0
   lda #1
   sta VERA_data1
   dex
   bne @right_border_loop
   stz VERA_ctrl
   lda #$11
   sta VERA_addr_bank
   lda #($B0 + TILE_VIZ_Y)
   clc
   adc tile_height
   sta VERA_addr_high
   lda #(TILE_VIZ_X*2 - 2)
   sta VERA_addr_low
   lda #$6B
   sta VERA_data0
   lda VERA_data0 ; skip over this color
   ldx tile_width
@bottom_border_loop:
   lda #$40
   sta VERA_data0
   lda #1
   sta VERA_data0
   dex
   bne @bottom_border_loop
   lda #$7D
   sta VERA_data0
   lda #1
   sta VERA_data0
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
   lda bits_per_pixel
   cmp #4
   bmi @scale_to_4bpp
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
   lda bits_per_pixel
   and #$08
   asl
   asl
   asl
   asl
   ora SB1   
   sta VERA_data0
   bra @setxy
@scale_to_4bpp:
   jsr scale_sprite_to_4bpp
@setxy:
   lda preview_x
   sta VERA_data0
   lda preview_x+1
   sta VERA_data0
   lda preview_y
   sta VERA_data0
   lda preview_y+1
   sta VERA_data0
   lda VERA_data0 ; preserve Z and flips
   ; set height/width/PO
   lda tile_height
   cmp #64
   beq @height64
   asl
   asl
   and #$C0
   bra @set_height
@height64:
   lda #$C0
@set_height:
   sta SB1
   lda tile_width
   cmp #64
   beq @width64
   and #$30
   bra @set_width
@width64:
   lda #$30
@set_width:
   ora SB1
   sta SB1
   lda palette_offset
   ora SB1
   sta VERA_data0
   rts

apply_offset:
   sta SB3
   lda palette_offset
   asl
   asl
   asl
   asl
   ora SB3
   rts

center_preview_sprite:
   lda #64
   sec
   sbc tile_width
   lsr
   clc
   adc #<PREVIEW_SPRITE_X
   sta preview_x
   lda #0
   adc #>PREVIEW_SPRITE_X
   sta preview_x+1
   lda #64
   sec
   sbc tile_height
   lsr
   clc
   adc #<PREVIEW_SPRITE_Y
   sta preview_y
   lda #0
   adc #>PREVIEW_SPRITE_Y
   sta preview_y+1
   rts

SCALED_4BPP_SPRITE_VRAM = $1EC00

scale_sprite_to_4bpp:
   lda #<(SCALED_4BPP_SPRITE_VRAM >> 5)
   sta VERA_data0
   lda #>(SCALED_4BPP_SPRITE_VRAM >> 5)
   sta VERA_data0
   lda #1
   sta VERA_ctrl
   lda tile_addr+2
   ora #$10
   sta VERA_addr_bank
   lda tile_addr+1
   sta VERA_addr_high
   lda tile_addr
   sta VERA_addr_low
   lda bits_per_pixel
   cmp #1
   beq @load1bpp
   jmp @load2bpp
@load1bpp:
   lda tile_width
   lsr
   lsr
   lsr
   tax
   lda tile_height
   clc
@calc_loop1:
   dex
   beq @start_load1
   adc tile_height
   bra @calc_loop1
@start_load1:
   sta SB1
   lda #BRAM_BANK
   sta RAM_BANK
   ldx #0
@load_loop1:
   lda VERA_data1
   sta scratch_tile,x
   inx
   cpx SB1
   bne @load_loop1
   VERA_SET_ADDR SCALED_4BPP_SPRITE_VRAM,1
   ldx #0
@scale_loop1:
   lda scratch_tile,x
   sta SB2
   and #$80
   lsr
   lsr
   lsr
   sta SB3
   lda SB2
   and #$40
   lsr
   lsr
   lsr
   lsr
   lsr
   lsr
   ora SB3
   sta VERA_data1
   lda SB2
   and #$20
   lsr
   sta SB3
   lda SB2
   and #$10
   lsr
   lsr
   lsr
   lsr
   ora SB3
   sta VERA_data1
   lda SB2
   and #$08
   asl
   sta SB3
   lda SB2
   and #$04
   lsr
   lsr
   ora SB3
   sta VERA_data1
   lda SB2
   and #$02
   asl
   asl
   asl
   sta SB3
   lda SB2
   and #$01
   ora SB3
   sta VERA_data1
   inx
   cpx SB1
   bne @scale_loop1
   rts
@load2bpp:
   lda tile_width
   lsr
   lsr
   tax
   lda tile_height
   clc
@calc_loop2:
   dex
   beq @start_load2
   adc tile_height
   bra @calc_loop2
@start_load2:
   sta SB1
   ldx #0
@load_loop2:
   lda VERA_data1
   sta scratch_tile,x
   inx
   cpx SB1
   bne @load_loop2
   VERA_SET_ADDR SCALED_4BPP_SPRITE_VRAM,1
   ldx #0
@scale_loop2:
   lda scratch_tile,x
   sta SB2
   and #$C0
   lsr
   lsr
   sta SB3
   lda SB2
   and #$30
   lsr
   lsr
   lsr
   lsr
   ora SB3
   sta VERA_data1
   lda SB2
   and #$0C
   asl
   asl
   sta SB3
   lda SB2
   and #$03
   ora SB3
   sta VERA_data1
   inx
   cpx SB1
   bne @scale_loop2
   rts

tileviz_reset:
   lda menu_visible
   bne @return
   phx
   stz VERA_ctrl
   lda #$21
   sta VERA_addr_bank
   lda #$B3
   sta VERA_addr_high
   lda #(PREV_TILE_X * 2)
   sta VERA_addr_low
   ldx #0
@prev_loop:
   lda init_prev_string,x
   sta VERA_data0
   inx
   cpx #11
   bne @prev_loop
   lda next_tile_x
   asl
   sta VERA_addr_low
   ldx #0
@next_loop:
   lda init_next_string,x
   sta VERA_data0
   inx
   cpx #7
   bne @next_loop
   plx
@return:   
   rts

tile_navigate:
   lda button_latch
   bne @return
   cpx #PREV_TILE_X
   bmi @return
   cpx #PREV_TILE_X+12
   bpl @check_down
   lda tile_index
   bne @do_prev
   lda tile_index+1
   beq @return
@do_prev:
   jmp do_prev ; tail-optimization
@check_down:
   cpx offset_down_tile_x
   bne @check_up
   lda palette_offset
   beq @return
   jmp do_offset_down ; tail-optimization
@check_up:
   cpx offset_up_tile_x
   bne @check_next
   lda palette_offset
   cmp #15
   beq @return
   jmp do_offset_up ; tail-optimization
@check_next:
   cpx next_tile_x
   bmi @return
   lda next_tile_x
   clc
   adc #7
   stx SB1
   cmp SB1
   bmi @return
   ; TODO check for last tile
   jmp do_next ; tail-optimization
@return:
   rts

do_prev:
   inc button_latch
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
   jmp load_tile ; tail-optimization

do_next:
   inc button_latch
   lda tile_index
   clc
   adc #1
   sta SB1
   lda tile_index+1
   adc #0
   sta SB2
   cmp tile_count+1
   bne @increment
   lda SB1
   cmp tile_count
   bne @increment
   rts
@increment:
   lda SB1
   sta tile_index
   lda SB2
   sta tile_index+1
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
   jmp load_tile ; tail-optimization

do_offset_down:
   inc button_latch
   lda palette_offset
   dec
   and #$0F
   sta palette_offset
   jsr print_offset
   jmp load_tile ; tail-optimization

print_offset:
   lda palette_offset
   ldx offset_down_tile_x
   ldy #3
   jsr print_byte_dec
   lda #$2D ; backfill minus character
   ldx offset_down_tile_x
   ldy #3
   jmp print_char ; tail-optimization

do_offset_up:
   inc button_latch
   lda palette_offset
   inc
   and #$0F
   sta palette_offset
   jsr print_offset
   jmp load_tile ; tail-optimization

check_tileviz_xy:
   ; TODO handle scroll position/large sprites
   lda #TILE_VIZ_X
   clc
   adc tile_width
   sta SB1
   cpx SB1
   bpl @return
   lda #TILE_VIZ_Y
   clc
   adc tile_height
   sta SB1
   cpy SB1
@return:
   rts

tileviz_xy_to_vram:
   stz VERA_ctrl
   ; TODO handle scroll position
   txa
   sec
   sbc #TILE_VIZ_X
   sta SB1
   tya
   sec
   sbc #TILE_VIZ_Y
   sta SB2
   lda tile_width
   sta SB3
   lda bits_per_pixel
   cmp #1
   beq @get1bpp
   cmp #2
   beq @get2bpp
   cmp #4
   beq @get4bpp
   bra @get8bpp
@get1bpp:
   lsr SB1
   lsr SB3
@get2bpp:
   lsr SB1
   lsr SB3
@get4bpp:
   lsr SB1
   lsr SB3
@get8bpp:
   ; address = tile_addr + SB1 + SB2*SB3
   stz SB4
   lsr SB3
@mult_loop:
   lda SB3
   cmp #0
   beq @add_x
   lsr SB3
   asl SB2
   rol SB4
   bra @mult_loop
@add_x:
   lda SB1
   clc
   adc SB2
   sta SB1
   lda SB4
   adc #0
   sta SB2 ; SB1/2 = VRAM offset
   lda SB1
   clc
   adc tile_addr
   sta VERA_addr_low
   lda SB2
   adc tile_addr+1
   sta VERA_addr_high
   lda tile_addr+2
   adc #0
   sta VERA_addr_bank 
   rts

tileviz_set_pixel: ; A = 8-bit color index, X = clicked tile X
   sta SB1
   txa
   sec
   sbc #TILE_VIZ_X
   tax ; X = tile pixel X
   lda bits_per_pixel
   cmp #1
   beq @set1bpp
   cmp #2
   beq @set2bpp
   cmp #4
   beq @set4bpp
   lda SB1
   sta VERA_data0 ; 8bpp, just store the whole index
   bra @done
@set1bpp:
   lda SB1
   and #$01
   sta SB1
   txa
   and #$07
   sta SB2
   lda #7
   sec
   sbc SB2
   bne @startloop1bpp
   lda #1
   bra @insert
@startloop1bpp:
   tax
   lda #1
@loop1bpp:
   asl SB1
   asl
   dex
   bne @loop1bpp
   bra @insert
@set2bpp:
   lda SB1
   and #$03
   sta SB1
   txa
   and #$03
   sta SB2
   lda #3
   sec
   sbc SB2
   bne @startloop2bpp
   lda #3
   bra @insert
@startloop2bpp:
   tax
   lda #3
@loop2bpp:
   asl SB1
   asl SB1
   asl
   asl
   dex
   bne @loop2bpp
   bra @insert
@set4bpp:
   lda SB1
   and #$0F
   sta SB1
   txa
   and #$01
   bne @lower4bpp
   asl SB1
   asl SB1
   asl SB1
   asl SB1
   lda #$F0
   bra @insert
@lower4bpp:
   lda #$0F
@insert:
   eor #$FF
   sta SB2 ; bitmask
   lda VERA_data0
   and SB2
   ora SB1
   sta VERA_data0
@done:
   jmp load_tile ; tail-optimization

tileviz_leftclick:
   lda button_latch
   bne @return
   jsr check_tileviz_xy
   bpl @return
   lda dropper
   beq @set
   jmp tileviz_getcolor ; tail-optimization
@set:
   jsr tileviz_xy_to_vram  
   lda fg_color
   jmp tileviz_set_pixel ; tail-optimization
@return:
   rts

tileviz_rightclick:
   jsr check_tileviz_xy
   bpl @return
   jsr tileviz_xy_to_vram
   lda bg_color
   jmp tileviz_set_pixel ; tail-optimization
@return:
   rts

tileviz_getcolor:
   stz VERA_ctrl
   lda #$11
   sta VERA_addr_bank
   tya
   clc
   adc #$B0
   sta VERA_addr_high
   txa
   asl
   inc
   sta VERA_addr_low
   lda VERA_data0
   sta fg_color
   jsr palette_sel_update
   stz dropper
   jmp reset_mouse_cursor ; tail-optimization
   