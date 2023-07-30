initscreen:
; menu bar
;  row 0 (upper border)
.byte $70,1
.repeat 3
   .repeat 9
      .byte $40,1
   .endrepeat
   .byte $72,1
.endrepeat
.repeat 40
   .byte $40,1
.endrepeat
.byte $72,1
.repeat 7
   .byte $40,1
.endrepeat
.byte $6E,1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
;  row 1 (text)
.byte "|",1," ",1,"F",1,"i",1,"l",1,"e",1," ",1," ",1," ",1," ",1,"|",1," ",1
.byte "V",1,"i",1,"e",1,"w",1," ",1," ",1," ",1," ",1,"|",1," ",1
.byte "O",1,"p",1,"t",1,"i",1,"o",1,"n",1,"s",1," ",1,"|",1
.repeat 13
   .byte " ",1
.endrepeat
.byte "X",1,"1",1,"6",1," ",1,"T",1,"i",1,"l",1,"e",1," ",1,"E",1,"d",1,"i",1,"t",1,"o",1,"r",1
.repeat 12
   .byte " ",1
.endrepeat
.byte "|",1," ",1,"A",1,"b",1,"o",1,"u",1,"t",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
;  row 2 (bottom border)
.byte $6d,1
.repeat 2
   .repeat 9
      .byte $40,1
   .endrepeat
   .byte $71,1
.endrepeat
.repeat 9
   .byte $40,1
.endrepeat
.byte $7d,1
.repeat 40
   .byte " ",1
.endrepeat
.byte $6d,1
.repeat 7
   .byte $40,1
.endrepeat
.byte $7d,1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
; index controls
.repeat 20
   .byte " ",1
.endrepeat
.byte "<",1,"<",1," ",1,"P",1,"r",1,"e",1,"v",1,"i",1,"o",1,"u",1,"s",1," ",1," ",1," ",1," ",1," ",1," ",1," ",1
.byte "P",1,"a",1,"l",1,"e",1,"t",1,"t",1,"e",1," ",1,"O",1,"f",1,"f",1,"s",1,"e",1,"t",1,":",1," ",1
.byte "-",1," ",1,"0",1,"+",1," ",1," ",1," ",1," ",1," ",1," ",1," ",1," ",1," ",1," ",1," ",1," ",1," ",1," ",1
.byte "N",1,"e",1,"x",1,"t",1," ",1,">",1,">",1," ",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
; window upper borders
.byte $70,1,$40,1,$40,1,$40,1," ",1,"P",1,"a",1,"l",1,"e",1,"t",1,"t",1,"e",1," ",1,$40,1,$40,1,$40,1,$40,1,$6e,1," ",1,$70,1
.repeat 23
   .byte $40,1
.endrepeat
.byte " ",1,"T",1,"i",1,"l",1,"e",1," ",1," ",1," ",1," ",1,"0",1," ",1
.repeat 23
   .byte $40,1
.endrepeat
.byte $72,1,$40,1,$6e,1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
; mid-windows
.byte "|",1,$A0,0,$A0,1,$A0,2,$A0,3,$A0,4,$A0,5,$A0,6,$A0,7,$A0,8,$A0,9,$A0,$a,$A0,$b,$A0,$c,$A0,$d,$A0,$e,$A0,$f,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1,$f1,1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$10,$A0,$11,$A0,$12,$A0,$13,$A0,$14,$A0,$15,$A0,$16,$A0,$17,$A0,$18,$A0,$19,$A0,$1a,$A0,$1b,$A0,$1c,$A0,$1d,$A0,$1e,$A0,$1f,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1,$5e,1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$20,$A0,$21,$A0,$22,$A0,$23,$A0,$24,$A0,$25,$A0,$26,$A0,$27,$A0,$28,$A0,$29,$A0,$2a,$A0,$2b,$A0,$2c,$A0,$2d,$A0,$2e,$A0,$2f,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1,$5e,1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$30,$A0,$31,$A0,$32,$A0,$33,$A0,$34,$A0,$35,$A0,$36,$A0,$37,$A0,$38,$A0,$39,$A0,$3a,$A0,$3b,$A0,$3c,$A0,$3d,$A0,$3e,$A0,$3f,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1,$5e,1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$40,$A0,$41,$A0,$42,$A0,$43,$A0,$44,$A0,$45,$A0,$46,$A0,$47,$A0,$48,$A0,$49,$A0,$4a,$A0,$4b,$A0,$4c,$A0,$4d,$A0,$4e,$A0,$4f,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1,$5e,1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$50,$A0,$51,$A0,$52,$A0,$53,$A0,$54,$A0,$55,$A0,$56,$A0,$57,$A0,$58,$A0,$59,$A0,$5a,$A0,$5b,$A0,$5c,$A0,$5d,$A0,$5e,$A0,$5f,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$60,$A0,$61,$A0,$62,$A0,$63,$A0,$64,$A0,$65,$A0,$66,$A0,$67,$A0,$68,$A0,$69,$A0,$6a,$A0,$6b,$A0,$6c,$A0,$6d,$A0,$6e,$A0,$6f,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$70,$A0,$71,$A0,$72,$A0,$73,$A0,$74,$A0,$75,$A0,$76,$A0,$77,$A0,$78,$A0,$79,$A0,$7a,$A0,$7b,$A0,$7c,$A0,$7d,$A0,$7e,$A0,$7f,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$80,$A0,$81,$A0,$82,$A0,$83,$A0,$84,$A0,$85,$A0,$86,$A0,$87,$A0,$88,$A0,$89,$A0,$8a,$A0,$8b,$A0,$8c,$A0,$8d,$A0,$8e,$A0,$8f,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$90,$A0,$91,$A0,$92,$A0,$93,$A0,$94,$A0,$95,$A0,$96,$A0,$97,$A0,$98,$A0,$99,$A0,$9a,$A0,$9b,$A0,$9c,$A0,$9d,$A0,$9e,$A0,$9f,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$a0,$A0,$a1,$A0,$a2,$A0,$a3,$A0,$a4,$A0,$a5,$A0,$a6,$A0,$a7,$A0,$a8,$A0,$a9,$A0,$aa,$A0,$ab,$A0,$ac,$A0,$ad,$A0,$ae,$A0,$af,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$b0,$A0,$b1,$A0,$b2,$A0,$b3,$A0,$b4,$A0,$b5,$A0,$b6,$A0,$b7,$A0,$b8,$A0,$b9,$A0,$ba,$A0,$bb,$A0,$bc,$A0,$bd,$A0,$be,$A0,$bf,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$c0,$A0,$c1,$A0,$c2,$A0,$c3,$A0,$c4,$A0,$c5,$A0,$c6,$A0,$c7,$A0,$c8,$A0,$c9,$A0,$ca,$A0,$cb,$A0,$cc,$A0,$cd,$A0,$ce,$A0,$cf,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$d0,$A0,$d1,$A0,$d2,$A0,$d3,$A0,$d4,$A0,$d5,$A0,$d6,$A0,$d7,$A0,$d8,$A0,$d9,$A0,$da,$A0,$db,$A0,$dc,$A0,$dd,$A0,$de,$A0,$df,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$e0,$A0,$e1,$A0,$e2,$A0,$e3,$A0,$e4,$A0,$e5,$A0,$e6,$A0,$e7,$A0,$e8,$A0,$e9,$A0,$ea,$A0,$eb,$A0,$ec,$A0,$ed,$A0,$ee,$A0,$ef,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
.byte "|",1,$A0,$f0,$A0,$f1,$A0,$f2,$A0,$f3,$A0,$f4,$A0,$f5,$A0,$f6,$A0,$f7,$A0,$f8,$A0,$f9,$A0,$fa,$A0,$fb,$A0,$fc,$A0,$fd,$A0,$fe,$A0,$ff,"|",1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
; bottom of palette window
.byte $6d,1
.repeat 16
   .byte $40,1
.endrepeat
.byte $7d,1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
; between palette and preview windows
.repeat 19
   .byte " ",1
.endrepeat
.byte "|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
; top of preview window
.byte $70,1,$40,1,$40,1,$40,1,$40,1," ",1,"P",1,"r",1,"e",1,"v",1,"i",1,"e",1,"w",1," ",1,$40,1,$40,1,$40,1,$6e,1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
; mid-windows
.repeat 8
   .byte "|",1
   .repeat 16
      .byte $A0,0
   .endrepeat
   .byte "|",1," ",1,"|",1
   .repeat 57
      .byte $A0,0
   .endrepeat
   .byte "|",1," ",1,"|",1
   .repeat 96
      .byte 0 ; offscreen
   .endrepeat
.endrepeat
; bottom preview window
.byte $6d,1
.repeat 16
   .byte $40,1
.endrepeat
.byte $7d,1," ",1,"|",1
.repeat 57
   .byte $A0,0
.endrepeat
.byte "|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
; mid-window
.repeat 24
   .repeat 19
      .byte " ",1
   .endrepeat
   .byte "|",1
   .repeat 57
      .byte $A0,0
   .endrepeat
   .byte "|",1," ",1,"|",1
   .repeat 96
      .byte 0 ; offscreen
   .endrepeat
.endrepeat
; bottom scrollbar
;   row 77 - top
.repeat 19
   .byte " ",1
.endrepeat
.byte $6b,1
.repeat 57
   .byte $40,1
.endrepeat
.byte $73,1,$f2,1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
;  row 78 - middle
.repeat 19
   .byte " ",1
.endrepeat
.byte "|",1,"<",1,$5e,1,$5e,1,$5e,1,$5e,1
.repeat 51
   .byte " ",1
.endrepeat
.byte ">",1,"|",1," ",1,"|",1
.repeat 96
   .byte 0 ; offscreen
.endrepeat
; row 79 - bottom
.repeat 19
   .byte " ",1
.endrepeat
.byte $6d,1
.repeat 57
   .byte $40,1
.endrepeat
.byte $71,1,$40,1,$7d,1
end_initscreen:

load_initscreen:
   lda #$0E  ; go to lowercase
   jsr CHROUT
   ; TODO: make sure that layer 1 is moved to default position
   lda #$68 ; 128x64 T256C
   sta VERA_L1_config
   stz VERA_ctrl
   lda #$11 ; stride = 1, address = $1B000
   sta VERA_addr_bank
   lda #$B0
   sta VERA_addr_high
   stz VERA_addr_low
   lda #<initscreen
   sta ZP_PTR_1
   lda #>initscreen
   sta ZP_PTR_1+1
   ldy #0
@loop:
   lda (ZP_PTR_1),y
   sta VERA_data0
   iny
   bne @loop
   lda ZP_PTR_1+1
   cmp #>end_initscreen
   beq @return
   inc ZP_PTR_1+1
   bra @loop
@return:
   rts