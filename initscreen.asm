initscreen:
; menu bar
;  row 0 (upper border)
.byte $70
.repeat 3
   .repeat 9
      .byte $40
   .endrepeat
   .byte $72
.endrepeat
.repeat 40
   .byte $40
.endrepeat
.byte $72
.repeat 7
   .byte $40
.endrepeat
.byte $6E

;  row 1 (text)
.byte "| File    | View    | Options |"
.repeat 13
   .byte " "
.endrepeat
.byte "X16 Tile Editor"
.repeat 12
   .byte " "
.endrepeat
.byte "| About |"

menu_bottom:
;  row 2 (bottom border)
.byte $6d
.repeat 2
   .repeat 9
      .byte $40
   .endrepeat
   .byte $71
.endrepeat
.repeat 9
   .byte $40
.endrepeat
.byte $7d
.repeat 40
   .byte " "
.endrepeat
.byte $6d
.repeat 7
   .byte $40
.endrepeat
.byte $7d

; index controls
.repeat 20
   .byte " "
.endrepeat
init_prev_string:
.byte "<< Previous       Palette Offset: - 0+              "
init_next_string:
.byte "Next >> "

; window upper borders
.byte $70,$40,$40,$40,$40," Palette ",$40,$40,$40,$6e," ",$70
.repeat 21
   .byte $40
.endrepeat
.byte " Tile    0 "
.repeat 25
   .byte $40
.endrepeat
.byte $72,$40,$6e

; mid-windows

.byte "|"
.repeat 16
   .byte $A0
.endrepeat
.byte "| |"
.repeat 57
   .byte $A0
.endrepeat
.byte "|",$f1,"|"

.repeat 4
   .byte "|"
   .repeat 16
      .byte $A0
   .endrepeat
   .byte "| |"
   .repeat 57
      .byte $A0
   .endrepeat
   .byte "|",$5e,"|"
.endrepeat

.repeat 11
   .byte "|"
   .repeat 16
      .byte $A0
   .endrepeat
   .byte "| |"
   .repeat 57
      .byte $A0
   .endrepeat
   .byte "| |"
.endrepeat

; bottom of palette window
.byte $6d
.repeat 16
   .byte $40
.endrepeat
.byte $7d," |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

; between palette and preview windows
.byte "  ",$70,$40,$40,$40,$6e
.repeat 4
   .byte " "
.endrepeat
.byte $70,$40,$40,$40,$6e,"   |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte "  |",$a0,$a0,$a0,"|"
.byte $70,$40,$40,$6e
.byte "|",$a0,$a0,$a0,"|   |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"


.byte "  |",$a0,$a0,$a0,"|"
.byte "|<>|"
.byte "|",$a0,$a0,$a0,"|   |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte "  |",$a0,$a0,$a0,"|"
.byte $6d,$40,$40,$7d
.byte "|",$a0,$a0,$a0,"|   |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte "  ",$6b,$40,$40,$40,$73
.repeat 4
   .byte " "
.endrepeat
.byte $6b,$40,$40,$40,$73,"   |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte "  |  1|"
.repeat 4
   .byte " "
.endrepeat
.byte "|  0|   |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte "  ",$6d,$40,$40,$40,$7d
.repeat 4
   .byte " "
.endrepeat
.byte $6d,$40,$40,$40,$7d,"   |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte " ",$70
.repeat 7
   .byte $40
.endrepeat
.byte $72
.repeat 7
   .byte $40
.endrepeat
.byte $6e," |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte " |Dropper| "
.byte "Clear | |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte " ",$6b
.repeat 7
   .byte $40
.endrepeat
.byte $5b
.repeat 7
   .byte $40
.endrepeat
.byte $73," |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte " | Copy  | "
.byte "Paste | |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte " ",$6d
.repeat 7
   .byte $40
.endrepeat
.byte $71
.repeat 7
   .byte $40
.endrepeat
.byte $7d," |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.repeat 8
   .byte " "
.endrepeat
.byte $70,$40,$6e
.repeat 8
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.repeat 8
   .byte " "
.endrepeat
.byte "|",$f1,"|"
.repeat 8
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.repeat 4
   .byte " "
.endrepeat
.byte $70,$40,$72,$40,$71,$40,$71,$40,$72,$40,$6e
.repeat 4
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.repeat 4
   .byte " "
.endrepeat
.byte "|",$f3,"|Shift|",$f0,"|"
.repeat 4
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.repeat 4
   .byte " "
.endrepeat
.byte $6d,$40,$71,$40,$72,$40,$72,$40,$71,$40,$7d
.repeat 4
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.repeat 8
   .byte " "
.endrepeat
.byte "|",$f2,"|"
.repeat 8
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.repeat 8
   .byte " "
.endrepeat
.byte $6d,$40,$7d
.repeat 8
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

; top of preview window
.byte $70,$40,$40,$40,$40," Preview ",$40,$40,$40,$6e," |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

; mid-windows
.repeat 8
   .byte "|"
   .repeat 16
      .byte " "
   .endrepeat
   .byte "| |"
   .repeat 57
      .byte $A0
   .endrepeat
   .byte "| |"
.endrepeat

; bottom preview window
.byte $6d
.repeat 16
   .byte $40
.endrepeat
.byte $7d," |"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte " Address: $00000"
.repeat 3
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte " Width:  16"
.repeat 8
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte " Height: 16"
.repeat 8
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte " Color Depth:  16"
.repeat 2
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte " H-Flip: Off"
.repeat 7
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "| |"

.byte " V-Flip: Off"
.repeat 7
   .byte " "
.endrepeat
.byte "|"
.repeat 57
   .byte $A0
.endrepeat
.byte "|",$f2,"|"

; bottom scrollbar
;   row 77 - top
.repeat 19
   .byte " "
.endrepeat
.byte $6b
.repeat 57
   .byte $40
.endrepeat
.byte $5b,$40,$73

;  row 78 - middle
.repeat 19
   .byte " "
.endrepeat
.byte "|",$f3,$5e,$5e,$5e,$5e
.repeat 51
   .byte " "
.endrepeat
.byte $f0,"| |"

; row 79 - bottom
.repeat 19
   .byte " "
.endrepeat
.byte $6d
.repeat 57
   .byte $40
.endrepeat
.byte $71,$40,$7d

arrowheads:
.byte %01000000
.byte %01110000
.byte %01111100
.byte %01111111
.byte %01111111
.byte %01111100
.byte %01110000
.byte %01000000

.byte %00011000
.byte %00011000
.byte %00111100
.byte %00111100
.byte %01111110
.byte %01111110
.byte %11111111
.byte %00000000

.byte %11111111
.byte %01111110
.byte %01111110
.byte %00111100
.byte %00111100
.byte %00011000
.byte %00011000
.byte %00000000

.byte %00000001
.byte %00000111
.byte %00011111
.byte %01111111
.byte %01111111
.byte %00011111
.byte %00000111
.byte %00000001

TEXT_START = $1B000
PAL_VIZ = TEXT_START+$502
FG_COLOR_BOX = TEXT_START+$1707
BG_COLOR_BOX = TEXT_START+$1719
TILE_VIZ = TEXT_START+$528

load_initscreen:
   lda #$0E  ; go to lowercase
   jsr CHROUT
   ; TODO: make sure that layer 1 is moved to default position
   lda #$68 ; 128x64 T256C
   sta VERA_L1_config
   ; put arrowheads into character set
   stz VERA_ctrl
   VERA_SET_ADDR $1F780,1
   lda #<arrowheads
   sta ZP_PTR_1
   lda #>arrowheads
   sta ZP_PTR_1+1
   ldy #0
@ah_loop1:
   lda (ZP_PTR_1),y
   sta VERA_data0
   iny
   cpy #32
   bne @ah_loop1
   ldy #0
@ah_loop2:
   lda (ZP_PTR_1),y
   eor #$FF ; reverse video
   sta VERA_data0
   iny
   cpy #32
   bne @ah_loop2
   ; load into layer 1 tile map
   VERA_SET_ADDR TEXT_START,1
   lda #<initscreen
   sta ZP_PTR_1
   lda #>initscreen
   sta ZP_PTR_1+1
   ldy #0
   ldx #60
@loop:
   lda (ZP_PTR_1),y
   sta VERA_data0
   lda #1
   sta VERA_data0
   iny
   cpy #80
   bne @loop
   ldy #0
   inc VERA_addr_high
   stz VERA_addr_low
   lda ZP_PTR_1
   clc
   adc #80
   sta ZP_PTR_1
   lda ZP_PTR_1+1
   adc #0
   sta ZP_PTR_1+1
   dex
   bne @loop
   ; load current palette
   VERA_SET_ADDR (PAL_VIZ+1),2
   ldx #0
   ldy #0
@pal_loop:
   stx VERA_data0
   iny
   cpy #16
   bne @next_color
   ldy #0
   inc VERA_addr_high
   lda #<(PAL_VIZ+1)
   sta VERA_addr_low
@next_color:
   inx
   bne @pal_loop
   ; update palette selections
   jsr palette_sel_update
   rts
