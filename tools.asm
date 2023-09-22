tool_strings:

COLOR_SWITCH_X = 8
COLOR_SWITCH_Y = 24
color_switch_string: .asciiz "<>"

CLEAR_BTN_X = 10
CLEAR_BTN_Y = 30
clear_button_string: .asciiz " Clear "

DROPPER_BTN_X = 2
DROPPER_BTN_Y = CLEAR_BTN_Y
dropper_button_string: .asciiz "Dropper"

COPY_BTN_X = DROPPER_BTN_X
COPY_BTN_Y = DROPPER_BTN_Y+2
copy_button_string: .asciiz " Copy  "

PASTE_BTN_X = CLEAR_BTN_X
PASTE_BTN_Y = COPY_BTN_Y
paste_button_string: .asciiz " Paste "

end_tool_strings:

on_string:  .asciiz "On "
off_string: .asciiz "Off"

SHIFT_UP_X = 9
SHIFT_UP_Y = 35

SHIFT_LEFT_X = 5
SHIFT_LEFT_Y = 37

SHIFT_RIGHT_X = 13
SHIFT_RIGHT_Y = 37

SHIFT_DOWN_X = 9
SHIFT_DOWN_Y = 39

TILE_WIDTH_X = 9
TILE_WIDTH_Y = 52

TILE_HEIGHT_X = 9
TILE_HEIGHT_Y = 53

COLOR_DEPTH_X = 14
COLOR_DEPTH_Y = 54

HFLIP_X = 9
HFLIP_Y = 55

VFLIP_X = 9
VFLIP_Y = 56

TOOL_STRINGS_REVERSED = $0400

.macro PRINT_REVERSED_TOOL_STRING string_addr, chx, chy
   lda #<(TOOL_STRINGS_REVERSED + string_addr - tool_strings)
   sta PRINT_STRING_PTR
   lda #>(TOOL_STRINGS_REVERSED + string_addr - tool_strings)
   sta PRINT_STRING_PTR+1
   lda #PRINT_STRING_PTR
   ldx #chx
   ldy #chy
   jsr print_string
.endmacro

.macro STRING_TABLE_ENTRY string_addr, chx, chy
   .addr string_addr 
   .byte chx,chy   
.endmacro

tool_string_table:
   STRING_TABLE_ENTRY color_switch_string,COLOR_SWITCH_X,COLOR_SWITCH_Y
   STRING_TABLE_ENTRY clear_button_string,CLEAR_BTN_X,CLEAR_BTN_Y
   STRING_TABLE_ENTRY dropper_button_string,DROPPER_BTN_X,DROPPER_BTN_Y
   STRING_TABLE_ENTRY copy_button_string,COPY_BTN_X,COPY_BTN_Y
   STRING_TABLE_ENTRY paste_button_string,PASTE_BTN_X,PASTE_BTN_Y
end_tool_string_table:


VRAM_DEFAULT_CURSOR = $1EE00
VRAM_DROPPER_CURSOR = $1EE80

dropper_cursor:
   .byte $21,$10,$00,$00,$00,$00,$00,$00
   .byte $12,$11,$00,$00,$00,$00,$00,$00
   .byte $11,$22,$11,$00,$00,$00,$00,$00
   .byte $01,$22,$22,$10,$00,$00,$00,$00
   .byte $00,$12,$20,$01,$00,$00,$00,$00
   .byte $00,$12,$00,$00,$10,$10,$00,$00
   .byte $00,$01,$00,$00,$01,$11,$00,$00
   .byte $00,$00,$10,$00,$11,$11,$00,$00
   .byte $00,$00,$01,$01,$11,$11,$10,$00
   .byte $00,$00,$00,$11,$11,$11,$11,$00
   .byte $00,$00,$01,$11,$11,$11,$11,$10
   .byte $00,$00,$00,$11,$11,$11,$11,$10
   .byte $00,$00,$00,$00,$11,$11,$11,$11
   .byte $00,$00,$00,$00,$01,$11,$11,$11
   .byte $00,$00,$00,$00,$00,$11,$11,$10
   .byte $00,$00,$00,$00,$00,$00,$11,$00


init_tools:
   ; init tool variables
   stz dropper
   ; copy reveresed strings
   lda #<tool_strings
   sta ZP_PTR_1
   lda #>tool_strings
   sta ZP_PTR_1+1
   lda #<TOOL_STRINGS_REVERSED
   sta ZP_PTR_2
   lda #>TOOL_STRINGS_REVERSED
   sta ZP_PTR_2+1
   ldy #0
@loop:
   lda (ZP_PTR_1),y
   beq @copy
   ora #$80
@copy:
   sta (ZP_PTR_2),y
   iny
   cpy #(end_tool_strings - tool_strings)
   bne @loop
   ; load dropper cursor into VRAM
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_DROPPER_CURSOR,1
   ldx #0
@dropper_loop:
   lda dropper_cursor,x
   sta VERA_data0
   inx
   cpx #128
   bne @dropper_loop
   ; copy default cursor sprite to safe part of VRAM
   VERA_SET_ADDR VRAM_sprattr,1
   lda VERA_data0
   sta SB1
   lda VERA_data0
   sta SB2
   ldx #5
@shift_loop:
   asl SB1
   rol SB2
   dex
   bne @shift_loop
   lda #0
   rol ; A = bank bit
   ora #$10 ; stride = 1
   sta VERA_addr_bank
   lda SB2
   sta VERA_addr_high
   lda SB1
   sta VERA_addr_low
   lda #1
   sta VERA_ctrl
   lda #($10 | ^VRAM_DEFAULT_CURSOR)
   sta VERA_addr_bank
   lda #>VRAM_DEFAULT_CURSOR
   sta VERA_addr_high
   lda #<VRAM_DEFAULT_CURSOR
   sta VERA_addr_low
   ldx #128
@copy_loop:
   lda VERA_data0
   asl
   asl
   asl
   asl
   bcc @upper_pixel
   lda #$20 ; replace opaque black with color #2
@upper_pixel:
   sta SB1
   lda VERA_data0
   bit #$10
   beq @combine_pixels
   lda #$02 ; replace opaque black with color #2
@combine_pixels:
   ora SB1  ; downsample to 4bpp
   sta VERA_data1
   dex
   bne @copy_loop
   ; setup sprite zero with default cursor
   jsr reset_mouse_cursor
   ; refresh all tools
   jsr tools_reset
   rts

reset_mouse_cursor:
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_sprattr,1
   lda #<(VRAM_DEFAULT_CURSOR>>5)
   sta VERA_data0
   lda #(VRAM_DEFAULT_CURSOR>>13)
   sta VERA_data0
   rts

tools_reset:
   phx
   phy
   ldy #0
   lda #<tool_string_table
   sta ZP_PTR_1
   lda #>tool_string_table
   sta ZP_PTR_1+1
@loop:
   lda (ZP_PTR_1),y
   sta ZP_PTR_2
   iny
   lda (ZP_PTR_1),y
   sta ZP_PTR_2+1
   iny
   lda (ZP_PTR_1),y
   tax
   iny
   phy
   lda (ZP_PTR_1),y
   tay
   lda #ZP_PTR_2
   jsr print_string
   ply
   iny
   cpy #(end_tool_string_table-tool_string_table)
   bne @loop
   ; reset shift buttons
   ldx #SHIFT_UP_X
   ldy #SHIFT_UP_Y
   lda #$F1
   jsr print_char
   ldx #SHIFT_LEFT_X
   ldy #SHIFT_LEFT_Y
   lda #$F3
   jsr print_char
   ldx #SHIFT_RIGHT_X
   ldy #SHIFT_RIGHT_Y
   lda #$F0
   jsr print_char
   ldx #SHIFT_DOWN_X
   ldy #SHIFT_DOWN_Y
   lda #$F2
   jsr print_char
   ply
   plx
   rts


tools_click:
   lda button_latch
   bne @return
   cpy #COLOR_SWITCH_Y
   bne @check_buttons
   cpx #COLOR_SWITCH_X
   bmi @return
   cpx #(COLOR_SWITCH_X+2)
   bpl @return
   jmp switch_colors ; tail-optimization
@check_buttons:
   cpy #CLEAR_BTN_Y
   bne @check_copy
   cpx #CLEAR_BTN_X
   bmi @check_dropper
   cpx #(CLEAR_BTN_X+8)
   bpl @return
   jmp clear_tile ; tail-optimization
@check_dropper:
   cpx #DROPPER_BTN_X
   bmi @return
   cpx #(DROPPER_BTN_X+8)
   bpl @return
   jmp start_dropper ; tail-optimization
@check_copy:
   cpy #COPY_BTN_Y
   bne @check_shift_up
   cpx #COPY_BTN_X
   bmi @return
   cpx #(COPY_BTN_X+8)
   bpl @check_paste
   jmp copy_tile ; tail-optimization
@check_paste:
   cpx #PASTE_BTN_X
   bmi @return
   cpx #(PASTE_BTN_X+8)
   bpl @return
   jmp paste_tile ; tail-optimization
@return:
   rts
@check_shift_up:
   cpy #SHIFT_UP_Y
   bne @check_shift_left
   cpx #SHIFT_UP_X
   bne @return
   jmp shift_up ; tail-optimization
@check_shift_left:
   cpy #SHIFT_LEFT_Y
   bne @check_shift_down
   cpx #SHIFT_LEFT_X
   bne @check_shift_right
   jmp shift_left ; tail-optimization
@check_shift_right:
   cpx #SHIFT_RIGHT_X
   bne @return
   jmp shift_right ; tail-optimization
@check_shift_down:
   cpy #SHIFT_DOWN_Y
   bne @check_tile_width
   cpx #SHIFT_DOWN_X
   bne @return
   jmp shift_down ; tail-optimization
@check_tile_width:
   cpy #TILE_WIDTH_Y
   bne @check_tile_height
   cpx #TILE_WIDTH_X
   bmi @return
   cpx #(TILE_WIDTH_X+2)
   bpl @return
   jmp next_width ; tail-optimization
@check_tile_height:
   cpy #TILE_HEIGHT_Y
   bne @check_color_depth
   cpx #TILE_HEIGHT_X
   bmi @return
   cpx #(TILE_HEIGHT_X+2)
   bpl @return
   jmp next_height ; tail-optimization
@check_color_depth:
   cpy #COLOR_DEPTH_Y
   bne @check_hflip
   cpx #COLOR_DEPTH_X
   bmi @return
   cpx #(COLOR_DEPTH_X+3)
   bpl @return
   jmp next_color_depth ; tail-optimization
@check_hflip:
   cpy #HFLIP_Y
   bne @check_vflip
   cpx #HFLIP_X
   bmi @return
   cpx #(HFLIP_X+3)
   bpl @return
   jmp toggle_hflip ; tail-optimization
@check_vflip:
   cpy #VFLIP_Y
   bne @return
   cpx #VFLIP_X
   bmi @return
   cpx #(VFLIP_X+3)
   bpl @return
   jmp toggle_vflip ; tail-optimization


toggle_hflip:
   inc button_latch
   stz VERA_ctrl
   VERA_SET_ADDR (PREVIEW_SPRITE_ATTR+6),0
   lda VERA_data0
   eor #$01
   sta VERA_data0
   bit #$01
   beq @print_off
   lda #<on_string
   sta ZP_PTR_1
   lda #>on_string
   sta ZP_PTR_1+1
   bra @print
@print_off:
   lda #<off_string
   sta ZP_PTR_1
   lda #>off_string
   sta ZP_PTR_1+1
@print:
   lda #ZP_PTR_1
   ldx #HFLIP_X
   ldy #HFLIP_Y
   jmp print_string ; tail-optimization

toggle_vflip:
   inc button_latch
   stz VERA_ctrl
   VERA_SET_ADDR (PREVIEW_SPRITE_ATTR+6),0
   lda VERA_data0
   eor #$02
   sta VERA_data0
   bit #$02
   beq @print_off
   lda #<on_string
   sta ZP_PTR_1
   lda #>on_string
   sta ZP_PTR_1+1
   bra @print
@print_off:
   lda #<off_string
   sta ZP_PTR_1
   lda #>off_string
   sta ZP_PTR_1+1
@print:
   lda #ZP_PTR_1
   ldx #VFLIP_X
   ldy #VFLIP_Y
   jmp print_string ; tail-optimization
   

get_row_size: ; output: A = bytes per row
   lda bits_per_pixel
   sta SB1
   lda tile_width
   sta SB2
@loop:
   lda SB1
   cmp #8
   beq @return
   asl SB1
   lsr SB2
   bra @loop
@return:
   lda SB2
   rts

shift_up:
   inc button_latch
   ldx #SHIFT_UP_X
   ldy #SHIFT_UP_Y
   lda #$F6
   jsr print_char
   jsr get_row_size
   sta SB2
@setup_addr:
   stz VERA_ctrl
   lda tile_addr+2
   ora #$10
   sta VERA_addr_bank
   lda tile_addr+1
   sta VERA_addr_high
   lda tile_addr
   sta VERA_addr_low
   lda #1
   sta VERA_ctrl
   lda SB2
   clc
   adc tile_addr
   sta VERA_addr_low
   lda #0
   adc tile_addr+1
   sta VERA_addr_high
   lda #0
   adc tile_addr+2
   ora #$10
   sta VERA_addr_bank
   lda SB2 ; preserve row size
   pha
   jsr get_tile_size
   pla
   sta SB2
   tya
   sec
   sbc SB2
   tay
   txa
   sbc #0
   tax
@copy_loop:
   lda VERA_data1
   sta VERA_data0
   dey
   bne @copy_loop
   cpx #0
   beq @start_blank
   dex
   bra @copy_loop
@start_blank:
   ldx SB2
@blank_loop:
   stz VERA_data0
   dex
   bne @blank_loop
   jmp load_tile ; tail-optimization

shift_left:
   inc button_latch
   ldx #SHIFT_LEFT_X
   ldy #SHIFT_LEFT_Y
   lda #$F8
   jsr print_char
   jsr get_row_size
   sta SB1
   stz VERA_ctrl
   lda tile_addr+2
   ora #$10
   sta VERA_addr_bank
   lda tile_addr+1
   sta VERA_addr_high
   lda tile_addr
   sta VERA_addr_low
   lda #1
   sta VERA_ctrl
   lda tile_addr+2
   ora #$10
   sta VERA_addr_bank
   lda tile_addr+1
   sta VERA_addr_high
   lda tile_addr
   sta VERA_addr_low
   ldx #0
   ldy tile_height
@read_row:
   lda VERA_data0
   sta scratch_tile,x
   inx
   cpx SB1
   bne @read_row
   phy
   lda bits_per_pixel
   cmp #8
   bne @bitwise_shift
   ldx #1
   bra @write_row
@bitwise_shift:
   ldy bits_per_pixel
@shift_loop:
   ldx SB1
   dex
   asl scratch_tile,x
@roll_loop:
   php
   cpx #0
   beq @next_bit
   dex
   plp
   rol scratch_tile,x
   bra @roll_loop
@next_bit:
   plp
   dey
   bne @shift_loop
@write_row:
   lda scratch_tile,x
   sta VERA_data1
   inx
   cpx SB1
   bne @write_row
   lda bits_per_pixel
   cmp #8
   bne @next_row
   stz VERA_data1
@next_row:
   ply
   ldx #0
   dey
   bne @read_row
   jmp load_tile ; tail-optimization


shift_right:
   inc button_latch
   ldx #SHIFT_RIGHT_X
   ldy #SHIFT_RIGHT_Y
   lda #$F5
   jsr print_char
   jsr get_row_size
   sta SB1
   stz VERA_ctrl
   lda tile_addr+2
   ora #$10
   sta VERA_addr_bank
   lda tile_addr+1
   sta VERA_addr_high
   lda tile_addr
   sta VERA_addr_low
   lda #1
   sta VERA_ctrl
   lda tile_addr+2
   ora #$10
   sta VERA_addr_bank
   lda tile_addr+1
   sta VERA_addr_high
   lda tile_addr
   sta VERA_addr_low
   ldx #0
   ldy tile_height
@read_row:
   lda VERA_data0
   sta scratch_tile,x
   inx
   cpx SB1
   bne @read_row
   phy
   stx SB2
   lda bits_per_pixel
   cmp #8
   bne @bitwise_shift
   stz VERA_data1
   dec SB2
   bra @write_row
@bitwise_shift:
   ldy bits_per_pixel
@shift_loop:
   ldx #0
   lsr scratch_tile,x
@roll_loop:
   php
   inx
   cpx SB1
   beq @next_bit
   plp
   ror scratch_tile,x
   bra @roll_loop
@next_bit:
   plp
   dey
   bne @shift_loop
@write_row:
   ldx #0
@write_loop:
   lda scratch_tile,x
   sta VERA_data1
   inx
   cpx SB2
   bne @write_loop
@next_row:
   ply
   ldx #0
   dey
   bne @read_row
   jmp load_tile ; tail-optimization


shift_down:
   inc button_latch
   ldx #SHIFT_DOWN_X
   ldy #SHIFT_DOWN_Y
   lda #$F7
   jsr print_char
   jsr get_row_size
   pha
   jsr get_tile_size
   pla
   sta SB1
   tya
   clc
   adc tile_addr
   sta SB2
   txa
   adc tile_addr+1
   sta SB3
   lda tile_addr+2
   adc #0
   sta SB4
   stz VERA_ctrl
   ora #$18
   sta VERA_addr_bank
   lda SB3
   sta VERA_addr_high
   lda SB2
   sta VERA_addr_low
   lda #1
   sta VERA_ctrl
   lda SB2
   sec
   sbc SB1
   sta VERA_addr_low
   lda SB3
   sbc #0
   sta VERA_addr_high
   lda SB4
   sbc #0
   ora #$18
   sta VERA_addr_bank
   lda VERA_data0 ; bump
   lda VERA_data1 ; bump
   tya
   sec
   sbc SB1
   tay
   txa
   sbc #0
   tax
@copy_loop:
   lda VERA_data1
   sta VERA_data0
   dey
   bne @copy_loop
   cpx #0
   beq @start_blank
   dex
   bra @copy_loop
@start_blank:
   ldx SB1
@blank_loop:
   stz VERA_data0
   dex
   bne @blank_loop
   jmp load_tile ; tail-optimization
   
clear_tile:
   inc button_latch
   PRINT_REVERSED_TOOL_STRING clear_button_string,CLEAR_BTN_X,CLEAR_BTN_Y
   lda bits_per_pixel
   sta SB1
   lda tile_width
   sta SB2
@shift_width:
   lda #8
   cmp SB1
   beq @set_width
   lsr SB2
   asl SB1
   bra @shift_width
@set_width:
   ldx SB2
   ldy tile_height
   stz VERA_ctrl
   lda #$10
   clc
   adc tile_addr+2
   sta VERA_addr_bank
   lda tile_addr+1
   sta VERA_addr_high
   lda tile_addr
   sta VERA_addr_low
@loop:
   stz VERA_data0
   dex
   bne @loop
   ldx SB2
   dey
   bne @loop
   jmp load_tile ; tail-optimization

start_dropper:
   inc button_latch
   PRINT_REVERSED_TOOL_STRING dropper_button_string,DROPPER_BTN_X,DROPPER_BTN_Y
   inc dropper
   ; setup sprite zero with dropper cursor
   stz VERA_ctrl
   VERA_SET_ADDR VRAM_sprattr,1
   lda #<(VRAM_DROPPER_CURSOR>>5)
   sta VERA_data0
   lda #(VRAM_DROPPER_CURSOR>>13)
   sta VERA_data0
   rts

get_tile_size: ; output: Y/X = bytes in tile asset
   lda bits_per_pixel
   sta SB1
   lda tile_width
   sta SB2
@shift_width:
   lda #8
   cmp SB1
   beq @set_width
   lsr SB2
   asl SB1
   bra @shift_width
@set_width:
   lda tile_height
   stz SB1
@multiply:
   lsr SB2
   beq @done
   asl
   rol SB1
   bra @multiply
@done:
   ldx SB1
   tay
   rts

copy_tile:
   inc button_latch
   PRINT_REVERSED_TOOL_STRING copy_button_string,COPY_BTN_X,COPY_BTN_Y
   stz VERA_ctrl
   lda tile_addr+2
   ora #$10
   sta VERA_addr_bank
   lda tile_addr+1
   sta VERA_addr_high
   lda tile_addr
   sta VERA_addr_low
   jsr get_tile_size
   lda #<clipboard
   sta ZP_PTR_1
   lda #>clipboard
   sta ZP_PTR_1+1
@loop:
   dey
   cpy #$FF
   bne @copy_byte
   cpx #0
   beq @done
   dex
   inc ZP_PTR_1+1
@copy_byte:
   lda VERA_data0
   sta (ZP_PTR_1),y
   bra @loop
@done:
   rts

paste_tile:
   inc button_latch
   PRINT_REVERSED_TOOL_STRING paste_button_string,PASTE_BTN_X,PASTE_BTN_Y
   stz VERA_ctrl
   lda tile_addr+2
   ora #$10
   sta VERA_addr_bank
   lda tile_addr+1
   sta VERA_addr_high
   lda tile_addr
   sta VERA_addr_low
   jsr get_tile_size
   lda #<clipboard
   sta ZP_PTR_1
   lda #>clipboard
   sta ZP_PTR_1+1
@loop:
   dey
   cpy #$FF
   bne @copy_byte
   cpx #0
   beq @done
   dex
   inc ZP_PTR_1+1
@copy_byte:
   lda (ZP_PTR_1),y
   sta VERA_data0
   bra @loop
@done:
   jmp load_tile ; tail-optimization

next_width:
   inc button_latch
   lda tile_width
   asl
   cmp #64 ; TODO - support 64
   bne @set_width
   lda #8
@set_width:
   sta tile_width
   cmp #32
   bpl @update
   lsr
   lsr
   lsr
   lsr
   sta SB1
   lda VERA_L0_tilebase
   and #$FE
   ora SB1
   sta VERA_L0_tilebase
@update:
   lda #$40
   ldy #(TILE_VIZ_Y-1)
   ldx #(TILE_VIZ_X+8)
   jsr print_char
   ldx #(TILE_VIZ_X+16)
   jsr print_char
   ldx #(TILE_VIZ_X+32)
   jsr print_char
   jsr center_preview_sprite
   jsr load_tile
   jsr reset_tile_count 
print_tile_width:
   lda tile_width
   ldx #(TILE_WIDTH_X-1)
   ldy #TILE_WIDTH_Y
   jmp print_byte_dec ; tail-optimization

next_height:
   inc button_latch
   lda tile_height
   asl
   cmp #64 ; TODO - support 64
   bne @set_height
   lda #8
@set_height:
   sta tile_height
   cmp #32
   bpl @update
   lsr
   lsr
   lsr
   and #$02
   sta SB1
   lda VERA_L0_tilebase
   and #$FD
   ora SB1
   sta VERA_L0_tilebase
@update:
   lda #$5D
   ldx #(TILE_VIZ_X-1)
   ldy #(TILE_VIZ_Y+8)
   jsr print_char
   ldy #(TILE_VIZ_Y+16)
   jsr print_char
   ldy #(TILE_VIZ_Y+32)
   jsr print_char
   jsr center_preview_sprite
   jsr load_tile
   jsr reset_tile_count 
print_tile_height:
   lda tile_height
   ldx #(TILE_HEIGHT_X-1)
   ldy #TILE_HEIGHT_Y
   jmp print_byte_dec ; tail-optimization
  


string256: .asciiz "256"

next_color_depth:
   inc button_latch
   lda bits_per_pixel
   asl
   cmp #16
   bne @set_depth
   lda #1
@set_depth:
   sta bits_per_pixel
   jsr load_tile
   jsr reset_tile_count
print_color_depth:
   lda bits_per_pixel
   cmp #1
   bne @check2
   lda #2
   bra @print_depth
@check2:
   cmp #2
   bne @check4
   lda #4
   bra @print_depth
@check4:
   cmp #4
   bne @print256
   lda #16
@print_depth:
   ldx #COLOR_DEPTH_X
   ldy #COLOR_DEPTH_Y
   jsr print_byte_dec
   bra @return
@print256:
   lda #<string256
   sta ZP_PTR_1
   lda #>string256
   sta ZP_PTR_1+1
   lda #ZP_PTR_1
   ldx #COLOR_DEPTH_X
   ldy #COLOR_DEPTH_Y
   jsr print_string
@return:
   rts
   

switch_colors:
   inc button_latch
   PRINT_REVERSED_TOOL_STRING color_switch_string,COLOR_SWITCH_X,COLOR_SWITCH_Y
   lda bg_color
   pha
   lda fg_color
   sta bg_color
   pla
   sta fg_color
   jmp palette_sel_update ; tail-optimization
@return:
   rts