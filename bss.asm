; GLOBAL VARIABLES

sprite_mode: .res 1  ; 0 = tiles, 1 = tile-sized sprites, 2 = big sprites

metadata:
tile_width: .res 1
tile_height: .res 1
bits_per_pixel: .res 1
tile_count: .res 2
end_metadata:

tile_index: .res 2
fg_color: .res 1
bg_color: .res 1
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

FILENAME_PTR = $34

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

preview_x: .res 2
preview_y: .res 2

button_latch: .res 1

scratch_tile: .res 1024

tile_filename_prefix: .res 2
tile_filename: .res 29

pal_filename_prefix: .res 2
pal_filename: .res 33

meta_filename_prefix: .res 2
meta_filename: .res 34

file_error: .res 1
file_sa: .res 1

rgb_gui_on: .res 1

dropper: .res 1
clipboard: .res 4096

menu_visible: .res 1

exit_req: .res 1

file_list: .res (28*9)
file_list_len: .res 1
dir_list: .res (26*9)
dir_list_len: .res 1
dir_skipped: .res 1
dir_read_done: .res 1

filename_stage: .res 29
chooser_scroll: .res 1
chooser_visible: .res 1
chooser_action: .res 1

double_click_countdown: .res 1
double_click_x: .res 1
double_click_y: .res 1

dos_cd_start: .res 3
selected_file: .res 29
selection_is_dir: .res 1
selection_is_file: .res 1

cursor_pos: .res 1
cursor_state: .res 1 ; 0 = off, 1 = cursor, 2 = character
cursor_countdown: .res 1

tileset_size_visible: .res 1
old_tile_count: .res 2
new_tile_count_string: .res 5
dec_word: .res 2
bin_word: .res 2
