toggle_prg_header:
   ;TODO
   rts

tileset_size_block:
   .byte $70
   .repeat 17
      .byte $40
   .endrepeat
   .byte $6e

   .byte "| Tile Set Size:  |"

   .byte "|     ",$70
   .repeat 5
      .byte $40
   .endrepeat
   .byte $6e,"     |"

   .byte "|     |     |     |"

   .byte "|     ",$6d
   .repeat 5
      .byte $40
   .endrepeat
   .byte $7d,"     |"

   .byte $6b
   .repeat 8
      .byte $40
   .endrepeat
   .byte $72
   .repeat 8
      .byte $40
   .endrepeat
   .byte $73

   .byte "| Cancel |   Ok   |"

   .byte $6d
   .repeat 8
      .byte $40
   .endrepeat
   .byte $71
   .repeat 8
      .byte $40
   .endrepeat
   .byte $7d


set_tileset_size:
   ;TODO
   rts

toggle_crt_mode:
   ;TODO
   rts
