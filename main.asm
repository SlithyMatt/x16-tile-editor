.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

.include "x16.inc"
.include "charmap.inc"
.include "initscreen.asm"

TILE_MAP = $1A800

start:
   jsr load_initscreen
   ; setup layer 0 as work layer, using default settings
   lda #$02 ; 32x32 4bpp
   sta VERA_L0_config
   lda #(TILE_MAP>>9)
   sta VERA_L0_mapbase
   lda #$03 ; tilebase $00000, 16x16 tiles
   sta VERA_L0_tilebase   
   ; load tile 0
    
@loop:
   wai
   bra @loop
   rts
