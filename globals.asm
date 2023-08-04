

sprite_mode:
.byte 0  ; 0 = tiles, 1 = tile-sized sprites, 2 = big sprites

tile_width:
.byte 16

tile_height:
.byte 16

tile_index:
.word 0

fg_color:
.byte 1

bg_color:
.byte 0

bits_per_pixel:
.byte 4

palette_offset:
.byte 0

tile_viz_width:
.byte 57

tile_viz_height:
.byte 52

; scratch bytes
SB1 = $28
SB2 = $29
SB3 = $2A
SB4 = $2B

MOUSE_X = $2C
MOUSE_Y = $2E

IND_VEC = $30

init_globals:
   stz sprite_mode
   lda #16
   sta tile_height
   sta tile_width
   lda #1
   sta fg_color
   stz tile_index
   stz bg_color
   lda #4
   sta bits_per_pixel
   stz palette_offset
   rts
