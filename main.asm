.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

   jmp start

.include "x16.inc"
.include "charmap.inc"
.include "initscreen.asm"

start:
   jsr load_initscreen
@loop:
   wai
   bra @loop
   rts
