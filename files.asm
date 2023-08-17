default_tile_filename: .asciiz "TILES.BIN"
default_pal_filename: .asciiz "PAL.BIN"

LOGICAL_FILE = 2
EMPTY_FILENAME = $FF

init_filenames:
   stz file_error
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
   stz file_error
   lda #LOGICAL_FILE
   ldx #8
   ldy #0 ; TODO set SA to 2 for headerless
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
   jsr SETNAM
   jsr READST
   beq @return
   sta file_error
   bra @return
@empty_filename:
   lda #EMPTY_FILENAME
   sta file_error
@return:
   rts

load_tile_file:
   jsr set_tile_filename
   lda file_error
   bne @return
   lda #2
   ldx #0
   ldy #0
   jsr LOAD
   jsr READST
   beq @return
   sta file_error
   jsr CLRCHN   
@return:
   rts

save_tile_file:
   jsr set_tile_filename
   jsr OPEN
   ldx #LOGICAL_FILE
   jsr CHKOUT
   jsr READST
   beq @start_write
   jmp @error
@start_write:
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
   jsr READST
   bne @error
   lda VERA_data0
   jsr CHROUT
   bra @save_loop
@error:
   sta file_error
@done:
   jsr CLOSE
   jmp CLRCHN ; tail-optimization


file_error_label: .asciiz "File Error:"
file_error_blank: .asciiz "              "

FILE_ERROR_LABEL_X = 1
FILE_ERROR_X = FILE_ERROR_LABEL_X + 12
FILE_ERROR_Y = 59 ; TODO - define variable for bottom row

print_file_error:
   lda file_error
   beq @blank
   lda #<file_error_label
   sta ZP_PTR_1
   lda #>file_error_label
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   ldx #FILE_ERROR_LABEL_X
   ldy #FILE_ERROR_Y
   jsr print_string
   lda file_error
   ldx #FILE_ERROR_X
   ldy #FILE_ERROR_Y
   jmp print_byte_hex ; tail-optimization
@blank:
   lda #<file_error_blank
   sta ZP_PTR_1
   lda #>file_error_blank
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   ldx #FILE_ERROR_LABEL_X
   ldy #FILE_ERROR_Y
   jmp print_string ; tail-optimization

