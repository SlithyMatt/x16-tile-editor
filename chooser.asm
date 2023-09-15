CHOOSER_X = 23
CHOOSER_Y = 7
DIR_STAGING = $8000

chooser_block: ; 34x15
   .byte $70
   .repeat 32
      .byte $40
   .endrepeat
   .byte $6e

   .byte "| Choose File:                   |"

   .byte $6b
   .repeat 30
      .byte $40
   .endrepeat
   .byte $72,$40,$73

   .byte "| ",$F4," ..                         |",$F1,"|"

   .repeat 3
      .byte "|                              |",$66,"|"
   .endrepeat

   .repeat 4
      .byte "|                              | |"
   .endrepeat

   .byte "|                              |",$F2,"|"

   .byte $6b
   .repeat 8
      .byte $40
   .endrepeat
   .byte $72
   .repeat 16
      .byte $40
   .endrepeat
   .byte $72
   .repeat 4
      .byte $40
   .endrepeat
   .byte $71,$40,$73

   .byte "| Cancel |                | Open |"

   .byte $6d
   .repeat 8
      .byte $40
   .endrepeat
   .byte $71
   .repeat 16
      .byte $40
   .endrepeat
   .byte $71
   .repeat 6
      .byte $40
   .endrepeat
   .byte $7d

chooser_open_tiles:
   jsr show_chooser
   lda #0
   sta chooser_scroll
   jsr scroll_chooser
   ; TODO set state
   rts

dos_directory:
dos_directory_dirs_only: .byte "$:*=D"
end_dos_directory_dirs_only:

dos_directory_prgs_only: .byte "$:*=P"
end_dos_directory_prgs_only:

show_chooser:
   ldx #CHOOSER_X
   ldy #CHOOSER_Y
   jsr print_set_vera_addr
   lda #$11
   sta VERA_addr_bank ; set stride to 1
   lda #<chooser_block
   sta ZP_PTR_1
   lda #>chooser_block
   sta ZP_PTR_1+1
   ldx #15
   ldy #0
@loop:
   lda (ZP_PTR_1),y
   sta VERA_data0
   lda #1 ; set to UI color
   sta VERA_data0
   iny
   cpy #34
   bne @loop
   dex
   beq @return
   lda ZP_PTR_1
   clc
   adc #34
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   inc VERA_addr_high
   lda #(CHOOSER_X*2)
   sta VERA_addr_low
   ldy #0
   bra @loop
@return:
   rts


scroll_chooser: ; input: A = scroll position
   stz file_list_len
   stz dir_list_len
   stz dir_read_done
   stz dir_skipped
   lda chooser_scroll
   beq @scroll_zero
   lda #1
   ldx #<dos_directory
   ldy #>dos_directory
   jsr SETNAM
   lda #1
   ldx #8
   ldy #0
   jsr SETLFS
   lda #0
   ldx #<DIR_STAGING
   stx ZP_PTR_1
   ldy #>DIR_STAGING
   sty ZP_PTR_1+1
   jsr LOAD
   jsr flush_line
   stz SB1
@read_loop:
   jsr read_dir_listing_line
   lda dir_read_done
   bne @check_scroll
   inc SB1
   bra @read_loop
@check_scroll:
   lda SB1
   cmp #9
   bmi @scroll_zero
   sec
   sbc #8
   cmp chooser_scroll
   bpl @get_dirs
   sta chooser_scroll
   bra @get_dirs
@scroll_zero:
   stz chooser_scroll
   lda #$2E ; "."
   sta dir_list
   sta dir_list+1
   stz dir_list+2
   inc dir_list_len
@get_dirs:
   stz dir_read_done
   lda #(end_dos_directory_dirs_only-dos_directory_dirs_only)
   ldx #<dos_directory_dirs_only
   ldy #>dos_directory_dirs_only
   jsr SETNAM
   lda #1
   ldx #8
   ldy #0
   jsr SETLFS
   lda #0
   ldx #<DIR_STAGING
   stx ZP_PTR_1
   ldy #>DIR_STAGING
   sty ZP_PTR_1+1
   jsr LOAD
   jsr flush_line
   lda #<dir_list
   sta ZP_PTR_2
   lda #>dir_list
   sta ZP_PTR_2+1   
@dir_read_loop:
   jsr read_dir_listing_line
   lda dir_read_done
   bne @print_dirs
   lda dir_skipped
   cmp chooser_scroll
   beq @start_dir_copy
   inc dir_skipped
   bra @dir_read_loop
@start_dir_copy:
   ldy #0
@dir_copy_loop:
   lda filename_stage,y
   sta (ZP_PTR_2),y
   beq @next_dir
   iny
   cpy #26
   beq @next_dir
   bra @dir_copy_loop
@next_dir:
   inc dir_list_len
   lda dir_list_len
   cmp #9
   bpl @print_dirs
   lda ZP_PTR_2
   clc
   adc #26
   sta ZP_PTR_2
   lda ZP_PTR_2+1
   adc #0
   sta ZP_PTR_2+1
   bra @dir_read_loop
@print_dirs:
   lda #<filename_stage
   sta ZP_PTR_3
   lda #>filename_stage
   sta ZP_PTR_3+1
   stz filename_stage+26
   ldx #0
   lda #<dir_list
   sta ZP_PTR_2
   lda #>dir_list
   sta ZP_PTR_2+1
   cpx dir_list_len
   beq @check_dir_count
@dir_loop:
   lda #$F4 ; file folder icon
   sta filename_stage
   lda #$20
   sta filename_stage+1   
   ldy #0
@dir_stage_loop:
   lda (ZP_PTR_2),y
   jsr ascii_to_screen_code
   sta filename_stage+2,y
   beq @print_dir
   iny
   cpy #25
   bne @dir_stage_loop
   lda (ZP_PTR_2),y
   sta filename_stage+25
   beq @print_dir
   iny
   lda (ZP_PTR_2),y
   beq @print_dir
   lda #$2A ; "*"
   sta filename_stage+25
@print_dir:
   phx
   txa
   clc
   adc #(CHOOSER_Y+4)
   tay
   ldx #(CHOOSER_X+2)
   lda #ZP_PTR_3
   jsr print_string
   lda ZP_PTR_2
   clc
   adc #26
   sta ZP_PTR_2
   lda ZP_PTR_2+1
   adc #0
   sta ZP_PTR_2
   plx
   inx
   cpx dir_list_len
   bne @dir_loop
@check_dir_count:
   lda dir_list_len
   cmp #9
   bne @load_file_listing
   jmp @done
@load_file_listing:
   stz dir_read_done
   lda #(end_dos_directory_prgs_only-dos_directory_prgs_only)
   ldx #<dos_directory_prgs_only
   ldy #>dos_directory_prgs_only
   jsr SETNAM
   lda #LOGICAL_FILE
   ldx #8
   ldy #0
   jsr SETLFS
   lda #0
   ldx #<DIR_STAGING
   stx ZP_PTR_1
   ldy #>DIR_STAGING
   sty ZP_PTR_1+1
   jsr LOAD
   jsr flush_line
   lda #<file_list
   sta ZP_PTR_2
   lda #>file_list
   sta ZP_PTR_2+1   
@file_read_loop:
   jsr read_dir_listing_line
   lda dir_read_done
   bne @print_files
   lda dir_skipped
   cmp chooser_scroll
   beq @start_file_copy
   inc dir_skipped
   bra @file_read_loop
@start_file_copy:
   ldy #0
@file_copy_loop:
   lda filename_stage,y
   sta (ZP_PTR_2),y
   beq @next_file
   iny
   cpy #28
   beq @next_file
   bra @file_copy_loop
@next_file:
   inc file_list_len
   lda file_list_len
   clc
   adc dir_list_len
   cmp #9
   bpl @print_files
   lda ZP_PTR_2
   clc
   adc #28
   sta ZP_PTR_2
   lda ZP_PTR_2+1
   adc #0
   sta ZP_PTR_2+1
   bra @start_file_copy
@print_files:
   lda #<filename_stage
   sta ZP_PTR_3
   lda #>filename_stage
   sta ZP_PTR_3+1
   stz filename_stage+28
   ldx #0
   lda #<file_list
   sta ZP_PTR_2
   lda #>file_list
   sta ZP_PTR_2+1
   cpx file_list_len
   beq @done
@file_loop:
   ldy #0
@file_stage_loop:
   lda (ZP_PTR_2),y
   jsr ascii_to_screen_code
   sta filename_stage,y
   beq @print_file
   iny
   cpy #27
   bne @file_stage_loop
   lda (ZP_PTR_2),y
   sta filename_stage+27
   beq @print_file
   iny
   lda (ZP_PTR_2),y
   beq @print_file
   lda #$2A ; "*"
   sta filename_stage+27
@print_file:
   phx
   txa
   clc
   adc dir_list_len
   adc #(CHOOSER_Y+4)
   tay
   ldx #(CHOOSER_X+2)
   lda #ZP_PTR_3
   jsr print_string
   lda ZP_PTR_2
   clc
   adc #28
   sta ZP_PTR_2
   lda ZP_PTR_2+1
   adc #0
   sta ZP_PTR_2
   plx
   inx
   cpx file_list_len
   bne @file_loop
@done:
   ; TODO change scroll nub
   rts



flush_line:
   phy
   ldy #4 ; skip past line header
@loop:
   lda (ZP_PTR_1),y
   iny
   cmp #0 ; check for null
   bne @loop
   tya
   clc
   adc ZP_PTR_1
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   ply
   rts

read_dir_listing_line:
   ldx #0
   ldy #6
   lda (ZP_PTR_1),y
   cmp #$22
   bne @not_file
   iny
@read_char:
   lda (ZP_PTR_1),y
   cmp #$22
   beq @end_filename
   sta filename_stage,x
   iny
   inx
   cpx #27
   bne @read_char
@end_filename:
   stz filename_stage,x
   bra @flush
@not_file:
   inc dir_read_done
@flush:
   jmp flush_line ; tail-optimization

   

chooser_open_pal:
   rts

chooser_save_as:
   rts
