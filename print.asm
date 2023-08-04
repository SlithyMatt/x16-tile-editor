print_bcd: .res 5

print_word_dec:
   jsr print_load_addrs
   lda (IND_VEC)
   sta SB1
   lda (IND_VEC),y
   sta SB2
   stz print_bcd
   stz print_bcd+1
   stz print_bcd+2
   sed
   ldx #16
@main_loop:
   ; shift highest bit to C
   asl SB1
   rol SB2
   ldy #0
   ; BCD = BCD*2 + C
   php
@add_loop:
   plp
   lda print_bcd,y
   adc print_bcd,y
   sta print_bcd,y
   php
   iny
   cpy #3
   bne @add_loop
   plp
   dex
   bne @main_loop
   cld
   lda print_bcd+2
   beq @print_space1
   ora #$30
   bra @print1
@print_space1:
   lda #$20
@print1:
   sta VERA_data0
   lda print_bcd+1
   lsr
   lsr
   lsr
   lsr
   beq @print_space2
   ora #$30
   bra @print2
@print_space2:
   lda #$20
@print2:
   sta VERA_data0
   lda print_bcd+1
   and #$0F
   beq @print_space3
   ora #$30
   bra @print3
@print_space3:
   lda #$20
@print3:
   sta VERA_data0
   lda print_bcd
   lsr
   lsr
   lsr
   lsr
   beq @print_space4
   ora #$30
   bra @print4
@print_space4:
   lda #$20
@print4:
   sta VERA_data0
   lda print_bcd
   and #$0F
   ora #$30
   sta VERA_data0
   rts

print_load_addrs:
   sta IND_VEC
   stz IND_VEC+1
   stz VERA_ctrl
   lda #$21
   sta VERA_addr_bank
   tya
   clc
   adc #$B0
   sta VERA_addr_high
   txa
   asl
   sta VERA_addr_low
   lda (IND_VEC)
   sta SB1
   ldy #1
   lda (IND_VEC),y
   sta SB2
   lda SB1
   sta IND_VEC
   lda SB2
   sta IND_VEC+1
   rts

print_vaddr:
   jsr print_load_addrs
   ldy #2
   lda (IND_VEC),y
   jsr print_hex_digit
   dey
   lda (IND_VEC),y
   jsr print_hex_byte
   lda (IND_VEC)
   jsr print_hex_byte
   rts

print_hex_digit:
   cmp #$A
   bpl @letter
   ora #$30
   bra @print
@letter:
   clc
   adc #$37
@print:
   sta VERA_data0
   rts

print_hex_byte:
   pha
   lsr
   lsr
   lsr
   lsr
   jsr print_hex_digit
   pla
   and #$0F
   jsr print_hex_digit
   rts
   