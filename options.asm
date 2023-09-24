toggle_prg_header:
   ;TODO
   rts

TILESET_SIZE_X = 23
TILESET_SIZE_Y = 7

tileset_size_block:
   .byte $70
   .repeat 17
      .byte $40
   .endrepeat
   .byte $6e

   .byte "| Tile Set Size:  |"

   .byte "|     ",$70
   .repeat 5
      .byte $40
   .endrepeat
   .byte $6e,"     |"

   .byte "|     |     |     |"

   .byte "|     ",$6d
   .repeat 5
      .byte $40
   .endrepeat
   .byte $7d,"     |"

   .byte $6b
   .repeat 8
      .byte $40
   .endrepeat
   .byte $72
   .repeat 8
      .byte $40
   .endrepeat
   .byte $73

   .byte "| Cancel |   Ok   |"

   .byte $6d
   .repeat 8
      .byte $40
   .endrepeat
   .byte $71
   .repeat 8
      .byte $40
   .endrepeat
   .byte $7d


set_tileset_size:
   ldx #TILESET_SIZE_X
   ldy #TILESET_SIZE_Y
   jsr print_set_vera_addr
   lda #$11
   sta VERA_addr_bank ; set stride to 1
   ldx #8
   ldy #0
   lda #<tileset_size_block
   sta ZP_PTR_1
   lda #>tileset_size_block
   sta ZP_PTR_1+1
@loop:
   lda (ZP_PTR_1),y
   sta VERA_data0
   lda #1
   sta VERA_data0
   iny
   cpy #19
   bne @loop
   dex
   beq @print_size
   tya
   clc
   adc ZP_PTR_1
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   inc VERA_addr_high
   lda #(TILESET_SIZE_X*2)
   sta VERA_addr_low
   ldy #0
   bra @loop
@print_size:
   jsr print_tile_count
   inc tileset_size_visible
   stz cursor_state
   lda tile_count
   sta old_tile_count
   lda tile_count+1
   sta old_tile_count+1
   rts

print_tile_count:
   lda #<tile_count
   sta ZP_PTR_1
   lda #>tile_count
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   ldx #(TILESET_SIZE_X+7)
   ldy #(TILESET_SIZE_Y+3)
   jsr print_word_dec
   rts

tileset_size_cursor_tick:
   jsr GETIN
   bne @check_backspace
   jmp @advance
@check_backspace:
   cmp #$14
   bne @check_enter
   lda cursor_pos
   beq @advance
   lda #(TILESET_SIZE_X+7)
   clc
   adc cursor_pos
   tax
   ldy #(TILESET_SIZE_Y+3)
   lda #$20
   jsr print_char
   dec cursor_pos
   dex
   lda #$A0
   jsr print_char
   lda #30
   sta cursor_countdown
   lda #1
   sta cursor_state
   rts
@check_enter:
   cmp #$0D
   bne @check_number
   jsr convert_tileset_size
   jsr print_tile_count
   stz cursor_state
   rts
@check_number:
   ldx cursor_pos
   cpx #4
   bpl @advance
   cmp #$30
   bmi @advance
   cmp #$3A
   bpl @advance
   ldx cursor_pos
   sta new_tile_count_string,x
   pha
   lda #(TILESET_SIZE_X+7)
   clc
   adc cursor_pos
   tax
   ldy #(TILESET_SIZE_Y+3)
   pla
   jsr print_char
   inc cursor_pos
@advance:
   dec cursor_countdown
   bne @return
   lda #30
   sta cursor_countdown
   lda cursor_state
   eor #$03
   sta cursor_state
   cmp #1
   bne @space
   lda #$A0
   bra @print
@space:
   lda #$20
@print:
   pha
   lda #(TILESET_SIZE_X+7)
   clc
   adc cursor_pos
   tax
   ldy #(TILESET_SIZE_Y+3)
   pla
   jmp print_char ; tail-optimization
@return:
   rts

convert_tileset_size:
   lda #<new_tile_count_string
   sta ZP_PTR_1
   lda #>new_tile_count_string
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   ldy cursor_pos
   jsr string_to_word
   lda bin_word
   sta tile_count
   lda bin_word+1
   sta tile_count+1
   jmp reset_tile_count ; tail-optimization

string_to_word:
   phy
   sta IND_VEC
   stz IND_VEC+1
   lda (IND_VEC)
   sta SB1
   ldy #1
   lda (IND_VEC),y
   sta IND_VEC+1
   lda SB1
   sta IND_VEC   
   stz bin_word+1
   ply
   cpy #0
   bne @init
   stz bin_word
   rts
@init: 
   stz dec_word
   stz dec_word+1
   ldx #1
   dey
@bcd_loop:
   lda (IND_VEC),y
   and #$0F
   sta dec_word,x
   cpy #0
   beq @convert
   dey
   lda (IND_VEC),y
   asl
   asl
   asl
   asl
   ora dec_word,x
   sta dec_word,x
   cpy #0
   beq @convert
   dey
   dex
   bra @bcd_loop
@convert:
   jsr convert_bcd_to_word
   rts

convert_bcd_to_word:
   jsr nxt_bcd  ;Get next BCD value
   sta bin_word   ;Store in LSBY
   ldx #3
@get_nxt:
   jsr nxt_bcd  ;Get next BCD value
   jsr mpy10
   dex
   bne @get_nxt
   rts

nxt_bcd:
   ldy #$04
   lda #$00
@mv_bits:
   asl dec_word+1
   rol dec_word
   rol
   dey
   bne @mv_bits
   rts

mpy10:
   sta SB1    ;Save digit just entered
   lda bin_word+1
   pha
   lda bin_word
   pha
   asl bin_word   ;Multiply partial
   rol bin_word+1 ;result by 2
   asl bin_word   ;Multiply by 2 again
   rol bin_word+1
   pla          ;Add original result
   adc bin_word
   sta bin_word
   pla
   adc bin_word+1
   sta bin_word+1
   asl bin_word   ;Multiply result by 2
   rol bin_word+1
   lda SB1    ;Add digit just entered
   adc bin_word
   sta bin_word
   lda #$00
   adc bin_word+1
   sta bin_word+1
   rts


tileset_size_blank: .byte $A0,"    ",0

tileset_size_click:
   lda button_latch
   bne @return
   inc button_latch
   lda cursor_state
   bne @check_buttons
   cpy #(TILESET_SIZE_Y+3)
   bne @check_buttons
   cpx #(TILESET_SIZE_X+7)
   bmi @return
   cpx #(TILESET_SIZE_X+12)
   bpl @return
   ldx #(TILESET_SIZE_X+7)
   lda #<tileset_size_blank
   sta ZP_PTR_1
   lda #>tileset_size_blank
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   jsr print_string
   stz cursor_pos
   lda #1
   sta cursor_state
   lda #30
   sta cursor_countdown
   rts
@check_buttons:
   cpy #13
   bne @return
   cpx #(TILESET_SIZE_X+1)
   bmi @return
   cpx #(TILESET_SIZE_X+9)
   bpl @check_ok
   lda old_tile_count
   sta tile_count
   lda old_tile_count+1
   sta tile_count
@close:
   stz cursor_state
   stz tileset_size_visible
   jmp load_tile ; tail optimization
@check_ok:
   cpx #(TILESET_SIZE_X+10)
   bmi @return
   cpx #(TILESET_SIZE_X+18)
   bpl @return
   lda cursor_state
   beq @close
   jsr convert_tileset_size
   bra @close
@return:
   rts

toggle_crt_mode:
   ;TODO
   rts
