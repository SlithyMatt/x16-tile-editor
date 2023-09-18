CHOOSER_X = 23
CHOOSER_Y = 7
DIR_STAGING = $8000

CHOOSER_CHOICE_X = 38
CHOOSER_CHOICE_Y = 8
CHOOSER_SCROLL_X = 55
CHOOSER_SCROLL_UP_Y = 10
CHOOSER_SCROLL_DOWN_Y = 18
CHOOSER_CANCEL_X = 24
CHOOSER_CANCEL_Y = 20
CHOOSER_ACTION_X = 50
CHOOSER_ACTION_Y = CHOOSER_CANCEL_Y

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

   .byte "|                              |",$F1,"|"

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

CHOOSER_ACTION_OPEN_TILES = 0
CHOOSER_ACTION_OPEN_PAL = 1
CHOOSER_ACTION_SAVE = 2

chooser_open_tiles:
   jsr show_chooser
   stz chooser_scroll
   jsr scroll_chooser
   lda #CHOOSER_ACTION_OPEN_TILES
   sta chooser_action
   rts

dos_directory:
dos_directory_dirs_only: .byte "$:*=D"
end_dos_directory_dirs_only:

dos_directory_prgs_only: .byte "$:*=P"
end_dos_directory_prgs_only:

show_chooser:
   inc chooser_visible
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
   clc
   lda dir_list_len
   beq @no_dotdot
   lda #26
   bra @init_dir_list
@no_dotdot:
   lda #0
@init_dir_list:
   adc #<dir_list
   sta ZP_PTR_2
   lda #>dir_list
   adc #0
   sta ZP_PTR_2+1   
@dir_read_loop:
   jsr read_dir_listing_line
   lda dir_read_done
   bne @print_dirs
   lda dir_skipped
   inc
   cmp chooser_scroll
   bpl @start_dir_copy
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
   ldx #0
   cpx dir_list_len
   beq @load_file_listing
   stz filename_stage+26
   lda #<dir_list
   sta ZP_PTR_2
   lda #>dir_list
   sta ZP_PTR_2+1   
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
   cmp #$80 ; converted NULL
   bne @next_dir_char
   lda #0
   sta filename_stage+2,y
   bra @print_dir
@next_dir_char:
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
   adc #(CHOOSER_Y+3)
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
   sta ZP_PTR_2+1
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
   bra @file_read_loop
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
   cmp #$80 ; converted NULL
   bne @next_file_char
   lda #0
   sta filename_stage,y
   bra @print_file
@next_file_char:
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
   adc #(CHOOSER_Y+3)
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
   sta ZP_PTR_2+1
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
   ldy #4
@spaces:
   lda (ZP_PTR_1),y
   iny
   cmp #$20
   beq @spaces
   cmp #$22
   bne @not_file
@read_char:
   lda (ZP_PTR_1),y
   cmp #$22
   beq @end_filename
   sta filename_stage,x
   iny
   inx
   cpx #28
   bne @read_char
@end_filename:
   stz filename_stage,x
   bra @flush
@not_file:
   inc dir_read_done
@flush:
   jmp flush_line ; tail-optimization

  

chooser_open_pal:
   jsr show_chooser
   stz chooser_scroll
   jsr scroll_chooser
   lda #CHOOSER_ACTION_OPEN_PAL
   sta chooser_action
   rts

save_string: .asciiz " Save "

chooser_save_as:
   jsr show_chooser
   ldx #CHOOSER_ACTION_X
   ldy #CHOOSER_ACTION_Y
   lda #<save_string
   sta ZP_PTR_1
   lda #>save_string
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   jsr print_string
   stz chooser_scroll
   jsr scroll_chooser
   lda #CHOOSER_ACTION_SAVE
   sta chooser_action
   rts


chooser_click:
   lda button_latch
   bne @return
   inc button_latch
   cpy #CHOOSER_CHOICE_Y
   bne @check_scroll
   cpx #CHOOSER_CHOICE_X
   bmi @return
   cpx #(CHOOSER_CHOICE_X+17)
   bpl @return
   jmp chooser_choice_click ; tail-optimization
@check_scroll:
   cpy #CHOOSER_SCROLL_UP_Y
   bmi @return
   cpy #(CHOOSER_SCROLL_DOWN_Y+1)
   bpl @check_buttons
   cpx #(CHOOSER_X+1)
   bmi @return
   cpx #(CHOOSER_X+31)
   bpl @check_scrollbar
   jmp chooser_file_click ; tail-optimization
@check_scrollbar:
   cpx #CHOOSER_SCROLL_X
   bne @return
   cpy #CHOOSER_SCROLL_UP_Y
   bne @check_scroll_down
   jmp chooser_scroll_up ; tail-optimization
@check_scroll_down:
   cpy #CHOOSER_SCROLL_DOWN_Y
   bne @return
   jmp chooser_scroll_down ; tail-optimization
@check_buttons:
   cpy #CHOOSER_CANCEL_Y
   bne @return
   cpx #CHOOSER_CANCEL_X
   bmi @return
   cpx #(CHOOSER_CANCEL_X+8)
   bpl @check_action
   jmp chooser_cancel ; tail-optimization
@check_action:
   cpx #CHOOSER_ACTION_X
   bmi @return
   cpx #(CHOOSER_ACTION_X+6)
   bpl @return
   jmp chooser_action_click ; tail-optimization
@return:
   rts

chooser_choice_click:
   lda chooser_action
   cmp #CHOOSER_ACTION_SAVE
   bne @return
   ; TODO start cursor flashing at click position
@return:   
   rts

chooser_file_click:
   jsr check_double_click
   bcc @select
   jmp chooser_action_click ; tail-optimization
@select:
   stz selection_is_dir
   tya
   sec
   sbc #CHOOSER_SCROLL_UP_Y
   cmp dir_list_len
   bmi @select_dir
   sbc dir_list_len
   tax
   lda #<file_list
   sta ZP_PTR_1
   lda #>file_list
   sta ZP_PTR_1+1
@find_filename:
   cpx #0
   beq @choose
   dex
   lda ZP_PTR_1
   clc
   adc #28
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   bra @find_filename
@select_dir:
   inc selection_is_dir
   tax
   lda #<dir_list
   sta ZP_PTR_1
   lda #>dir_list
   sta ZP_PTR_1+1
@find_dir:
   cpx #0
   beq @choose
   dex
   lda ZP_PTR_1
   clc
   adc #26
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   bra @find_dir
@choose:
   ldy #0
@choose_loop:
   lda (ZP_PTR_1),y
   sta selected_file,y
   beq @print
   iny
   cpy #28
   bne @choose_loop
@print:
   ldy #0
   lda #<filename_stage
   sta ZP_PTR_2
   lda #>filename_stage
   sta ZP_PTR_2+1
@print_copy_loop:
   lda (ZP_PTR_1),y
   jsr ascii_to_screen_code
   cmp #$80
   beq @pad
   sta (ZP_PTR_2),y
   iny
   cpy #16
   bne @print_copy_loop
   lda (ZP_PTR_1),y
   beq @pad
   jsr ascii_to_screen_code
   tax
   iny
   lda (ZP_PTR_1),y
   bne @asterix
   dey
   txa
   sta (ZP_PTR_2),y
   iny
   bra @add_null
@asterix:
   dey
   lda #$2A
   sta (ZP_PTR_2),y
   iny
   bra @add_null
@pad:
   cpy #17
   beq @add_null
   lda #$20
   sta (ZP_PTR_2),y
   iny
   bra @pad
@add_null:
   lda #0
   sta (ZP_PTR_2),y
   lda #ZP_PTR_2
   ldx #CHOOSER_CHOICE_X
   ldy #CHOOSER_CHOICE_Y
   jmp print_string ; tail-optimization


chooser_clear_file_row: .asciiz "                             "

chooser_scroll_up:
   lda chooser_scroll
   beq @return
   dec chooser_scroll
   jsr chooser_clear_all
   jmp scroll_chooser ; tail-optimization
@return:
   rts

chooser_scroll_down:
   inc chooser_scroll
   jsr chooser_clear_all
   jmp scroll_chooser ; tail-optimization

chooser_clear_all:
   lda #<chooser_clear_file_row
   sta ZP_PTR_1
   lda #>chooser_clear_file_row
   sta ZP_PTR_1+1
   ldx #(CHOOSER_X+1)
   ldy #CHOOSER_SCROLL_UP_Y
@loop:
   lda #ZP_PTR_1
   jsr print_string
   iny
   cpy #(CHOOSER_SCROLL_DOWN_Y+1)
   bne @loop
   rts

chooser_cancel:
   stz chooser_visible
   jmp load_tile ; tail-optimization

chooser_action_click:
   lda selection_is_dir
   bne @change_dir
   ; TODO file action
   rts
@change_dir:
   ldx #3
@length_loop:
   lda dos_cd_start,x
   beq @do_cd
   inx
   bra @length_loop
@do_cd:
   txa
   ldx #<dos_cd_start
   ldy #>dos_cd_start
   jsr SETNAM
   lda #15
   ldx #8
   ldy #15
   jsr SETLFS
   jsr OPEN
   lda #15
   jsr CLOSE
   stz chooser_scroll
   jmp scroll_chooser ; tail-optimization
   