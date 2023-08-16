default_tile_filename: .asciiz "TILES.BIN"
default_pal_filename: .asciiz "PAL.BIN"

init_filenames:
   ldx #0
@loop1:
   lda default_tile_filename,x
   sta tile_filename,x
   inx
   cmp #0
   bne @loop1
@loop2:
   lda default_pal_filename,x
   sta pal_filename,x
   inx
   cmp #0
   bne @loop2
   rts

set_tile_filename:
   lda #1
   ldx #8
   ldy #0
   jsr SETLFS
   ldx #0
@measure_loop:
   lda tile_filename,x
   inx
   cmp #0
   bne @measure_loop
   dex
   beq @empty_filename
   txa
   ldx #<tile_filename
   ldy #>tile_filename
   jmp SETNAM ; tail-optimization
@empty_filename:
   ; TODO - define error condition
   rts

load_tile_file:
   jsr set_tile_filename
   lda #2
   ldx #0
   ldy #0
   jmp LOAD ; tail-optimization
@empty_filename:
   ; TODO - print error
   rts

save_tile_file:
   jsr set_tile_filename
   jsr OPEN
   ldx #1
   jsr CHKOUT
   stz VERA_ctrl
   VERA_SET_ADDR $00000,1
   ; TODO - omit header if not desired
   lda #0
   jsr CHROUT
   jsr CHROUT
@calculate_size:
   lda tile_count
   sta SB1
   lda tile_count+1
   sta SB2
   stz SB3
   lda tile_width
   sta SB4
   lda bits_per_pixel
   cmp #8
   beq @mult_width
   lsr SB4
   cmp #4
   bne @check_2bpp
   bra @mult_width
@check_2bpp:
   lsr SB4
   cmp #2
   bne @do_1bpp
   bra @mult_width
@do_1bpp:
   lsr SB4
@mult_width:
   lsr SB4
   bcs @get_height
   asl SB1
   rol SB2
   rol SB3
   bra @mult_width
@get_height:
   lda tile_height
   sta SB4
@mult_height:
   lsr SB4
   bcs @save_loop
   asl SB1
   rol SB2
   rol SB3
   bra @mult_height
@save_loop:
   dec SB1
   lda SB1
   cmp #$FF
   bne @check_done
   dec SB2
   lda SB2
   cmp #$FF
   bne @check_done
   dec SB3
   bmi @done
@check_done:
   lda SB1
   bne @next
   lda SB2
   bne @next
   lda SB3
   beq @done
@next:
   lda VERA_data0
   jsr CHROUT
   bra @save_loop
@done:
   jsr CLOSE
   jmp CLRCHN ; tail-optimization

