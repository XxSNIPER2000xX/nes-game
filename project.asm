.segment "HEADER"
  .byte "NES" 
  .byte $1a 
  .byte $02
  .byte $01
  .byte %00000000
  .byte $00 
  .byte $00 
  .byte $00
  .byte $00 
  .byte $00,$00,$00,$00,$00
;  ----------------------------------------------------------

.segment "STARTUP"            ; avoids warnings
.segment "CODE"

WaitVblank:
:
    BIT $2002
    BPL :-
    RTS

; -----------------------------------------------------------

RESET:                        ; reset routine
  SEI
  CLD
  LDX #$00                    ; turn of screen
  STX $2000
  STX $2001
  DEX
  TXS
  LDX #0
  TXA
  
  JSR WaitVblank

ClearMemory:                  ; clr mem b/c old memory may be left on reset
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0200, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0300, x
  INX
  BNE ClearMemory

  JSR WaitVblank

; -----------------------------------------------------------
  
  BIT $2002                   ; checks for clear vblank flag -> PPU WARM UP
Wait1:
  BIT $2002                   ; read vblank flag
  BPL Wait1                   ; keep reading until vblank flag is set
Wait2:
  BIT $2002                   ; read the vblank flag
  BPL Wait2                   ; keep reading until it's set again

  LDA #$3F                    ; point to palette in VRAM - $3F00
  STA $2006
  LDA #$00
  STA $2006
  
  LDA #$20                    ; point to nametable 0 in VRAM
  STA $2006
  LDA #$00
  STA $2006

  LDY #04                     ; clear nametables
ClearNameTables:
  LDX #$00
  LDA #$00
PPULoop:
  STA $2007
  DEX
  BNE PPULoop

  DEY
  BNE ClearNameTables

; -----------------------------------------------------------

  LDA #$20                    ; point to first nametable in VRAM
  STA $2006
  LDA #$00
  STA $2006

  LDY #$00
  LDX #$04

  LDA #$3F                   ; writing colour
  STA $2006
  LDA #$00
  STA $2006
  LDA #$16                    ; orange
  STA $2007
  
VBLANK:                       ; turning on screen
 BIT $2002
 BPL VBLANK

 LDA #%10001000
 STA $2000
 LDA #%00011110               ; rendering on
 STA $2001

 LDX #$00                     ; set scroll to zero
 STX $2005
 STX $2005

; -----------------------------------------------------------

Infinite:
  JMP Infinite

; -----------------------------------------------------------

.segment "VECTORS"
    .word VBLANK
    .word RESET
    .word 0

.segment "CHARS" 
