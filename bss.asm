; GLOBAL VARIABLES

sprite_mode: .res 1  ; 0 = tiles, 1 = tile-sized sprites, 2 = big sprites

tile_width: .res 2
tile_height: .res 2
tile_index: .res 2
tile_count: .res 2
fg_color: .res 1
bg_color: .res 1
bits_per_pixel: .res 1
palette_offset: .res 1
tile_viz_width: .res 1
tile_viz_height: .res 1

; scratch bytes
SB1 = $28
SB2 = $29
SB3 = $2A
SB4 = $2B

MOUSE_X = $2C
MOUSE_Y = $2E

IND_VEC = $30

PRINT_STRING_PTR = $32

; PRINT VARIABLES

print_bcd: .res 5
print_space: .res 1

; TILEVIZ VARIABLES

tile_addr: .res 3

PREV_TILE_X = 20
offset_down_tile_x: .res 1
offset_up_tile_x: .res 1
next_tile_x: .res 1
tile_num_x: .res 1

TILE_ADDR_X = 11
TILE_ADDR_Y = 51

prev_latch: .res 1
next_latch: .res 1
offset_up_latch: .res 1
offset_down_latch: .res 1


color_switch_latch: .res 1
tile_width_latch: .res 1
tile_height_latch: .res 1
color_depth_latch: .res 1

scratch_tile: .res 1024

tile_filename: .res 256
pal_filename: .res 256

file_error: .res 1


