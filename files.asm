default_tile_filename: .asciiz "TILES.BIN"
default_pal_filename: .asciiz "TILES.BIN.PAL"
default_meta_filename: .asciiz "TILES.BIN.META"

LOGICAL_FILE = 2
EMPTY_FILENAME = $FF

init_filenames:
   stz file_error
   lda #$40 ; "@"
   sta tile_filename_prefix
   sta pal_filename_prefix
   sta meta_filename_prefix
   lda #$3A ; ":"
   sta tile_filename_prefix+1
   sta pal_filename_prefix+1
   sta meta_filename_prefix+1
   ldx #0
@loop1:
   lda default_tile_filename,x
   sta tile_filename,x
   inx
   cmp #0
   bne @loop1
   ldx #0
@loop2:
   lda default_pal_filename,x
   sta pal_filename,x
   inx
   cmp #0
   bne @loop2
   ldx #0
@loop3:
   lda default_meta_filename,x
   sta meta_filename,x
   inx
   cmp #0
   bne @loop3
   rts

set_filename: ; FILENAME_PTR = address of null-terminated filename
   stz file_error
   lda #LOGICAL_FILE
   ldx #SD_DEVICE
   ldy file_sa
   jsr SETLFS
   ldy #0
@measure_loop:
   lda (FILENAME_PTR),y
   iny
   cmp #0
   bne @measure_loop
   dey
   beq @empty_filename
   tya
   ldx FILENAME_PTR
   ldy FILENAME_PTR+1
   jsr SETNAM
   bra @return
@empty_filename:
   lda #EMPTY_FILENAME
   sta file_error
@return:
   rts

load_tile_file:
   jsr set_meta_filename
   jsr load_metadata
   lda prg_header
   inc
   and #2   
   eor #2
   sta file_sa
   lda #<tile_filename
   sta FILENAME_PTR
   lda #>tile_filename
   sta FILENAME_PTR+1
   jsr set_filename
   lda file_error
   bne @return
   lda #2
   ldx #0
   ldy #0
   jsr LOAD
   jsr READST
   and #$BF ; clear EOF bit
   sta file_error
   bne @return
   jsr set_pal_filename
   jmp load_pal_file ; tail-optimization
@return:
   rts

load_metadata:
   ; backup metadata
   ldx #(end_metadata-metadata-1)
@backup_loop:
   lda metadata,x
   sta metadata_backup,x
   dex
   bne @backup_loop
   lda #2 ; never use header for metadata
   sta file_sa
   lda #<meta_filename
   sta FILENAME_PTR
   lda #>meta_filename
   sta FILENAME_PTR+1
   jsr set_filename
   lda file_error
   bne @return
   lda #0
   ldx #<metadata
   ldy #>metadata
   jsr LOAD
   jsr READST
   and #$BF ; clear EOF bit
   sta file_error
   beq @reset_ui
   ; restore the metadata
   ldx #(end_metadata-metadata-1)
@restore_loop:
   lda metadata_backup,x
   sta metadata,x
   dex
   bne @restore_loop
@reset_ui:
   lda #$40
   ldy #(TILE_VIZ_Y-1)
   ldx #(TILE_VIZ_X+8)
   jsr print_char
   ldx #(TILE_VIZ_X+16)
   jsr print_char
   ldx #(TILE_VIZ_X+32)
   jsr print_char
   lda #$5D
   ldx #(TILE_VIZ_X-1)
   ldy #(TILE_VIZ_Y+8)
   jsr print_char
   ldy #(TILE_VIZ_Y+16)
   jsr print_char
   ldy #(TILE_VIZ_Y+32)
   jsr print_char
   jsr reset_tile_count
   jsr print_tile_width
   jsr print_tile_height
   jsr print_color_depth
@return:
   rts

load_pal_file:
   lda prg_header
   inc
   and #2
   eor #2
   sta file_sa
   lda #<pal_filename
   sta FILENAME_PTR
   lda #>pal_filename
   sta FILENAME_PTR+1
   jsr set_filename
   lda file_error
   bne @return
   lda #(2 + ^VRAM_palette)
   ldx #<VRAM_palette
   ldy #>VRAM_palette
   jsr LOAD
   jsr READST
   and #$BF ; clear EOF bit
   sta file_error
@return:
   rts

save_tile_file:
   lda #1
   sta file_sa
   lda #<tile_filename_prefix
   sta FILENAME_PTR
   lda #>tile_filename_prefix
   sta FILENAME_PTR+1
   jsr set_filename
   jsr OPEN
   jsr READST
   beq @do_chkout
   jmp @error
@do_chkout:
   ldx #LOGICAL_FILE
   jsr CHKOUT
   bcc @continue_check_chkout
   jmp @error
@continue_check_chkout:
   jsr READST
   beq @start_write
   jmp @error
@start_write:
   stz VERA_ctrl
   VERA_SET_ADDR $00000,1
   lda prg_header
   beq @calculate_size
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
   ; one more byte
   lda VERA_data0
   jsr CHROUT
   lda #LOGICAL_FILE
   jsr CLOSE
   jsr READST
   sta file_error
   jsr CLRCHN
   jsr set_meta_filename
save_metadata:
   lda #1
   sta file_sa
   lda #<meta_filename_prefix
   sta FILENAME_PTR
   lda #>meta_filename_prefix
   sta FILENAME_PTR+1
   jsr set_filename
   lda #<metadata
   sta ZP_PTR_1
   lda #>metadata
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   ldx #<end_metadata
   ldy #>end_metadata
   jsr BSAVE
   jsr set_pal_filename
save_pal_file:
   lda #1
   sta file_sa
   lda #<pal_filename_prefix
   sta FILENAME_PTR
   lda #>pal_filename_prefix
   sta FILENAME_PTR+1
   jsr set_filename
   jsr OPEN
   jsr READST
   beq @do_chkout
   jmp @error
@do_chkout:
   ldx #LOGICAL_FILE
   jsr CHKOUT
   bcc @continue_check_chkout
   jmp @error
@continue_check_chkout:
   jsr READST
   beq @start_write
   jmp @error
@start_write:
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_palette,1
   lda prg_header
   beq @after_header
   lda #0
   jsr CHROUT
   jsr CHROUT
@after_header:
   ldx #0
   ldy #1
@write_loop: ; write 512 bytes
   jsr READST
   bne @error
   lda VERA_data0
   jsr CHROUT
   dex
   bne @write_loop
   dey
   beq @write_loop
   jsr READST
   beq @done
@error:
   sta file_error
@done:
   lda #LOGICAL_FILE
   jsr CLOSE
   jsr READST
   sta file_error
   jmp CLRCHN ; tail-optimization

set_meta_filename:
   ldx #0
@meta_filename_loop:
   lda tile_filename,x
   beq @meta_suffix
   sta meta_filename,x
   inx
   cpx #28
   bne @meta_filename_loop
@meta_suffix: ; append ".META"
   lda #$2e
   sta meta_filename,x
   inx
   lda #$4d
   sta meta_filename,x
   inx
   lda #$45
   sta meta_filename,x
   inx
   lda #$54
   sta meta_filename,x
   inx
   lda #$41
   sta meta_filename,x
   inx
   stz meta_filename,x
   rts

set_pal_filename:
   ldx #0
@pal_filename_loop:
   lda tile_filename,x
   beq @pal_suffix
   sta pal_filename,x
   inx
   cpx #28
   bne @pal_filename_loop
@pal_suffix: ; append ".PAL"
   lda #$2e
   sta pal_filename,x
   inx
   lda #$50
   sta pal_filename,x
   inx
   lda #$41
   sta pal_filename,x
   inx
   lda #$4c
   sta pal_filename,x
   inx
   stz pal_filename,x
   rts

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

