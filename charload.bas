10 FOR I=0 TO 2047
20 VPOKE 0,I,VPEEK(1,$F000+I)
30 NEXT I
40 LOAD "TILEEDIT.ROM",8,0,$3000
50 SYS $3000
