tool_strings:

COLOR_SWITCH_X = 8
COLOR_SWITCH_Y = 24
color_switch_string:
   .asciiz "<>"

end_tool_strings:

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
end_tool_string_table:

init_tools:
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
   ; clear latches and refresh all tools
   jsr tools_clear_latches
   rts

tools_clear_latches:
   phx
   phy
   stz color_switch_latch
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
   ply
   plx
   rts


tools_click:
   cpy #COLOR_SWITCH_Y
   bne @check_buttons
   cpx #COLOR_SWITCH_X
   bmi @return
   cpx #(COLOR_SWITCH_X+2)
   bpl @return
   jsr switch_colors
@check_buttons:

@return:
   rts
   

switch_colors:
   lda color_switch_latch
   bne @return
   inc color_switch_latch
   PRINT_REVERSED_TOOL_STRING color_switch_string,COLOR_SWITCH_X,COLOR_SWITCH_Y
   lda bg_color
   pha
   lda fg_color
   sta bg_color
   pla
   sta fg_color
   jsr palette_sel_update
@return:
   rts