print_word_dec: ; A = ZP address of word
                ; X,Y = coordinates to print
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
   lda #1
   sta print_space
   lda print_bcd+2
   beq @print_space1
   ora #$30
   stz print_space
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
   stz print_space
@num2:
   ora #$30
   bra @print2
@print_space2:
   lda print_space
   beq @num2
   lda #$20
@print2:
   sta VERA_data0
   lda print_bcd+1
   and #$0F
   beq @print_space3
   stz print_space
@num3:
   ora #$30
   bra @print3
@print_space3:
   lda print_space
   beq @num3
   lda #$20
@print3:
   sta VERA_data0
   lda print_bcd
   lsr
   lsr
   lsr
   lsr
   beq @print_space4
   stz print_space
@num4:
   ora #$30
   bra @print4
@print_space4:
   lda print_space
   beq @num4
   lda #$20
@print4:
   sta VERA_data0
   lda print_bcd
   and #$0F
   ora #$30
   sta VERA_data0
   rts

print_byte_dec: ; A = byte to print in decimal
                ; X,Y = coordinates
   sta SB1   
   jsr print_set_vera_addr
   stz print_bcd
   stz print_bcd+1
   sed
   ldx #8
@loop:
   ; shift highest bit to C
   asl SB1
   ; BCD = BCD*2 + C
   lda print_bcd
   adc print_bcd
   sta print_bcd
   lda print_bcd+1
   adc print_bcd+1
   sta print_bcd+1
   dex
   bne @loop
   cld
   lda #1
   sta print_space
   lda print_bcd+1
   beq @print_space1
   stz print_space
   ora #$30
   bra @print1
@print_space1:
   lda #$20
@print1:
   sta VERA_data0
   lda print_bcd
   lsr
   lsr
   lsr
   lsr
   cmp #0
   beq @print_space2
@num2:
   ora #$30
   bra @print2
@print_space2:
   lda print_space
   beq @num2
   lda #$20
@print2:
   sta VERA_data0
   lda print_bcd
   and #$0F
   ora #$30
   sta VERA_data0
   rts

print_set_vera_addr: ; X,Y = coordinates to print
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
   rts

print_load_addrs: ; Input: A = ZP address of pointer to value; X,Y = coordinates to print
                  ; Output: IND_VEC = de-referenced pointer
   sta IND_VEC
   stz IND_VEC+1
   jsr print_set_vera_addr
   lda (IND_VEC)
   sta SB1
   ldy #1
   lda (IND_VEC),y
   sta IND_VEC+1
   lda SB1
   sta IND_VEC
   rts

print_vaddr: ; A = ZP address of pointer to 3-byte VRAM address
             ; X,Y = coordinates to print
   jsr print_load_addrs
   ldy #2
   lda (IND_VEC),y
   jsr get_hex_char
   sta VERA_data0
   dey
   lda (IND_VEC),y
   jsr _print_hex_byte
   lda (IND_VEC)
   jmp _print_hex_byte ; tail-optimization

get_hex_char:
   cmp #$A
   bpl @letter
   ora #$30
   bra @return
@letter:
   clc
   adc #$37
@return:
   rts

print_byte_hex: ; A = byte value to print in hex; X,Y = coordinates
   pha
   jsr print_set_vera_addr
   pla
_print_hex_byte: ; A = byte value to print in hex
   pha
   lsr
   lsr
   lsr
   lsr
   jsr get_hex_char
   sta VERA_data0
   pla
   and #$0F
   jsr get_hex_char
   sta VERA_data0
   rts

print_string: ; A = ZP address of pointer to null-terminated string (max length = 255)
               ; X,Y = coordinates to print
   phx
   phy
   jsr print_load_addrs
   ldy #0
@loop:
   lda (IND_VEC),y
   beq @return
   sta VERA_data0
   iny
   bra @loop
@return:
   ply
   plx
   rts

print_char: ; A = screen code to print
            ; X,Y = coordinates
   pha  
   jsr print_set_vera_addr
   pla
   sta VERA_data0
   rts
   
ascii_to_screen_code:
   cmp #$20
   bmi @control
   cmp #$60
   bmi @return  ; no change
   cmp #$80
   bmi @lowercase
   cmp #$A0
   bpl @return ; no change
@control: ; make control codes "inverted"
   ora #$80
   bra @return
@lowercase:
   sec
   sbc #$60
   bra @return
@return:
   rts