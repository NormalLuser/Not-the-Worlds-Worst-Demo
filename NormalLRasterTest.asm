VGAClock          = $0C ;$E2  ; IF NMI hooked up to vsync this will DEC.
SpriteW           = $E3       ; Sprite Width
SpriteH           = $E4       ; Sprite Height
SpriteImage       = $E5       ; Location of sprite in memory
SpriteImageH      = $E6       ; to draw FROM     -was OldPixX
OldPixY           = $E7       ; MOVE Old Pixel Location y offset
OldPixC           = $E8       ; MOVE Old Color
OldPixL           = $E9       ; MOVE Old Pixel Location
OldPixH           = $EA       ; MOVE memory address/ROW
BackColor         = $EB       ; Background/Color command color
PlotColor         = $EC       ; Color for plot function 
Screen            = $00;$ED       ; GFX screen location
ScreenH           = $01;$EE       ; to draw TO
Display           = $2000 


ISource           = $500
IDest             = $2000

DelayCount        = $80
ShrinkFactorV     = $19
ShrinkFactor      = $20
CurShrink         = $21
CurShrinkV        = $22
ACount            = $23
AFrames           = $24

Script            = $25
ScriptH           = $26
ScriptY           = $27

TmpA              = $30
TmpY              = $31
TmpX              = $32

RasterTmp         = $33
TmpV              = $34
RasterTmpT        = $35
RasterTmpV        = $36

RasterTmpS       = $37

RColor1           = $50
RColor2           = $51
RColor3           = $52
RColor4           = $53
RColor5           = $54
RasterTmpHT       = $56
RasterTmpHV       = $56

RScreenH          = $60
RScreen           = $61

RVScreenH          = $62
RVScreen           = $63


RTScreenH          = $64
RTScreen           = $65

RScreenHUp         = $66
RScreenUp          = $67

HBarOffScreenDelay = $68

VSineX             = $69

TopRasterStart     = $02
BottomRasterStart  = $42 



MsgPointer        = $10
MsgPointerH       = $11


TextLoc           = $12
TextLocH          = $13
TextLocTemp       = $14

TextScroll        = $15
MsgPointerY       = $16
MyMsgY            = $17
;DelayCount        = $18
DrawMSGLoopCount  = $19


RVScreenX         = $70

MyTemp           = $99

VStripScreen     = $A0
VStripScreenH    = $A1


HLine1          = $70
HLine2          = $71
HLine3          = $72
HLine4          = $73
HLine5          = $74
HLine6          = $75
HLine7          = $76

HLine1C         = $77
HLine2C         = $78
HLine3C         = $79
HLine4C         = $7A
HLine5C         = $7B
HLine6C         = $7C
HLine7C         = $7D

HSineCounter    = $7E


sX = $90
sY = $91
sL = $92
sSine = $93
sSine2 = $94
sSine3 = $95
RLEPointer = $96
RLEPointerH = $97




;Screen            = $00       ; GFX screen location
;ScreenH           = $01       ; to draw TO
;VGASync           = $E1;***** IF NMI hooked up to vsync this will be 1 after sync(s), you set to zero yourself *****
;VGAClock          = $C;***** IF NMI hooked up to vsync this will DEC *****




VLoopCount        = $03

VLoops            = 7
HSineLoops        = 7

;DrawTxtLine      = $1700

 .org $8000
 ;.ORG $200
 ; .org $DE00

RESET:

ProgramStart:
 LDA #1
 STA DelayCount
 LDA sSine
 ADC #47
 STA sSine2
 ADC #47
 STA sSine3
 
 ;jsr Delay
 jsr LoadRLE
 jsr MysSign






GetPlot: ;21 or 22 cycles, faster than lookup??
 lsr ;a           ; Divide Line count by 2 and shift bit 0 to carry
 bcc Plotis_even  ; Carry is even number
 ;CLC ;bcs is_odd ;odd number
 ADC #$1F ; Assume Carry is set. Add screen loction minus 1
 STA ScreenH
 LDA #$80 ; Odd row, low byte is 128
 STA Screen ;
 ;TXA
 ;STA (Screen),y
 RTS
Plotis_even:
 ADC #$20 ; Assume Carry is clear. Add Screen location
 STA ScreenH
 STZ Screen ; Even Row, low byte is 0
 ;TXA
 ;STA (Screen),y
 RTS

Delay: ; NormalLuser VGA clock delay routine:
 RTS ; Skip since no Vsync
  PHA           ; This results in 60 interrupts a second. IE on the V sync pulse.
  PHX
  PHY

  LDA DelayCount; Replace with a couple of nested loops and some nop's if you don't have NMI vsync.
  BEQ NoDelay   ; 0, No delay
  STA VGAClock  ; Store the number of cycles we want to wait.
DelayTop:    
  DEC VGAClock
  LDX #255
  LDY #47
; DelayEMUTop: ;Added delay for emulator
;   NOP
;   NOP
;   NOP
;   NOP
;   DEX
;   BNE DelayEMUTop 
;   DEY
;   BNE DelayEMUTop 
;   LDA VGAClock  ; See if the Vsync NMI has counted down to 0.
;   BNE DelayTop  ; Keep waiting until 0/Vsync NMI triggered.
NoDelay:
  PLY
  PLX
  PLA
 RTS            ; Finished countdown.




MySine:
Sine_64:
 .byte 32,33,34,34,35,36,37,37,38,39,40,40,41,42,43,43,44,45,46,46,47,48,48,49,50,50,51,52,52,53,53,54,54,55,56,56,57,57,58,58,58,59,59,60,60,60,61,61,61,62,62,62,62,63,63,63,63,63,63,64,64,64,64,64,64,64,64,64,64,64,63,63,63,63,63,63,62,62,62,62,61,61,61,60,60,60,59,59,58,58,58,57,57,56,56,55,54,54,53,53,52,52,51,50,50,49,48,48,47,46,46,45,44,43,43,42,41,40,40,39,38,37,37,36,35,34,34,33,32,31,30,30,29,28,27,27,26,25,24,24,23,22,21,21,20,19,18,18,17,16,16,15,14,14,13,12,12,11,11,10,10,9,8,8,7,7,6,6,6,5,5,4,4,4,3,3,3,2,2,2,2,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,3,3,3,4,4,4,5,5,6,6,6,7,7,8,8,9,10,10,11,11,12,12,13,14,14,15,16,16,17,18,18,19,20,21,21,22,23,24,24,25,26,27,27,28,29,30,30,31
     

MysSign:
 LDX sSine
 LDA MySine,x
 INC sSine
 LSR
 TAX
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw1
 LDA #$00
 jsr sLine
sNoDraw1:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw2
 LDA #$10
 jsr sLine
sNoDraw2:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw3
 LDA #$30
 jsr sLine
sNoDraw3
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw4
 LDA #$3F
 jsr sLine
sNoDraw4:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw5
 LDA #$20
 jsr sLine
sNoDraw5:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw6
 LDA #$0
 jsr sLine
sNoDraw6:

 LDX sSine2
 LDA MySine,x
 INC sSine2
 LSR
 TAX
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw7
 LDA #$00
 jsr sLine
sNoDraw7:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw8
 LDA #$04
 jsr sLine
sNoDraw8:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw9
 LDA #$0C
 jsr sLine
sNoDraw9
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw10
 LDA #$3E
 jsr sLine
sNoDraw10:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw11
 LDA #$08
 jsr sLine
sNoDraw11:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw12
 LDA #$0
 jsr sLine
sNoDraw12:
 LDX sSine3
 LDA MySine,x
 INC sSine3
 LSR
 TAX
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw13
 LDA #$00
 jsr sLine
sNoDraw13:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw14
 LDA #$01
 jsr sLine
sNoDraw14:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw15
 LDA #$03
 jsr sLine
sNoDraw15
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw16
 LDA #$0B
 jsr sLine
sNoDraw16:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw17
 LDA #$02
 jsr sLine
sNoDraw17:
 INX
 TXA
 JSR GetPlot
 LDY SpongeScreen, X
 LDA SpongeLen, X
 STA sL
 STX sX
 BEQ sNoDraw18
 LDA #$0
 jsr sLine
sNoDraw18:

sNoDraw:

 jsr Delay
 jmp MysSign


sLine:
 STA (Screen),y
 INY
 CPY sL
 BEQ sLineDone
 jmp sLine
sLineDone:
 RTS

; .ORG $1000


LoadRLE: ;56 BYTES, smashes all registers and Screen pointer
 LDA #$20 ;Blast it on the screen buffer, dump when full.
 STA ScreenH
 STZ Screen
 LDA #<RLEData
 STA RLEPointer
 LDA #>RLEData
 STA RLEPointerH
 LDY #0
LoadRLENext: ;Do your own init and jsr here if you want other load/store locations
; Read Two bytes
 LDA (RLEPointer),y
 TAX ;Count to X as counter
 INY
 LDA (RLEPointer),y ;Value to store RLE
 STY TmpY ;PHY
 LDY #0
LoadRLELoop:
 STA (Screen),y
 INC Screen
 BNE LoadRLESkipHInc
 INC ScreenH
 STA TmpA;PHA
 LDA ScreenH
 CMP #$40
 BEQ LoadRLEDone
 LDA TmpA ;PLA
LoadRLESkipHInc:
 DEX
 BNE LoadRLELoop
 LDY TmpY ;PLY
 INY
 BNE LoadRLENext
 INC RLEPointerH
 JMP LoadRLENext
LoadRLEDone:
 RTS


SpongeScreen: ; Start/End locations of little raster bars.
 .byte 00,00,10,08,08,07,07,07,06,06,06,06,06,06,06,05,05,05,06,06,06,06,06,07,07,08,10;,00,00,00,00,00,00,00,00,00,00,00,00,00,00
SpongeLen: ; Need extra zeros for lines past the bottom/top of screen. I won't draw if it is a zero len.
 .byte 00,00,31,33,34,34,34,35,35,35,35,33,32,32,31,31,31,31,31,31,30,30,30,30,30,29,24,00,00,00,00,00,00,00,00,00,00,00,00,00,00

RLEData:
;.incbin "NewBobDeskRasterRLE.bin";, auto
; .INCBIN "NewBobDeskRasterNEWRLE.BIN"
; 3,768 bytes for 6,400 byte screen (actually fills 8k)
 .BYTE $01,$00,$01,$15,$1A,$16,$01,$15
 .BYTE $05,$16,$04,$2A,$01,$1A,$01,$01
 .BYTE $0C,$06,$03,$15,$01,$14,$03,$00
 .BYTE $01,$15,$02,$00,$05,$28,$01,$29
 .BYTE $02,$19,$03,$15,$01,$16,$08,$06
 .BYTE $01,$16,$03,$06,$01,$16,$04,$06
 .BYTE $25,$16,$01,$00,$0B,$16,$11,$15
 .BYTE $06,$16,$04,$2A,$01,$01,$0A,$06
 .BYTE $02,$15,$01,$18,$01,$28,$0C,$29
 .BYTE $07,$28,$03,$15,$03,$16,$02,$06
 .BYTE $03,$16,$03,$06,$29,$16,$01,$01
 .BYTE $09,$16,$15,$00,$01,$15,$03,$16
 .BYTE $01,$1A,$03,$2A,$01,$01,$07,$06
 .BYTE $03,$15,$01,$19,$01,$28,$01,$29
 .BYTE $04,$2D,$04,$29,$08,$28,$03,$39
 .BYTE $01,$38,$02,$28,$01,$24,$01,$28
 .BYTE $01,$19,$01,$15,$31,$16,$01,$15
 .BYTE $04,$16,$03,$1A,$19,$00,$01,$05
 .BYTE $02,$16,$03,$2A,$01,$01,$04,$06
 .BYTE $02,$15,$01,$19,$01,$28,$02,$29
 .BYTE $05,$2D,$01,$29,$06,$28,$01,$3D
 .BYTE $01,$3C,$03,$3D,$01,$3C,$09,$3D
 .BYTE $03,$28,$02,$15,$2E,$16,$01,$15
 .BYTE $04,$16,$02,$1A,$01,$15,$1A,$00
 .BYTE $02,$16,$01,$1A,$02,$2A,$01,$01
 .BYTE $02,$06,$01,$16,$02,$15,$02,$28
 .BYTE $01,$29,$05,$2D,$02,$29,$05,$28
 .BYTE $02,$3D,$02,$3C,$0F,$3D,$02,$28
 .BYTE $01,$15,$2E,$16,$01,$15,$01,$16
 .BYTE $01,$1A,$01,$16,$02,$1A,$01,$16
 .BYTE $1B,$00,$01,$15,$02,$16,$01,$1A
 .BYTE $01,$2A,$01,$01,$01,$06,$02,$28
 .BYTE $01,$29,$06,$2D,$02,$29,$01,$28
 .BYTE $02,$3D,$03,$3C,$03,$3D,$01,$3C
 .BYTE $0C,$3D,$01,$3C,$03,$3D,$03,$3C
 .BYTE $01,$3D,$01,$28,$2F,$16,$02,$1A
 .BYTE $01,$2A,$01,$16,$01,$15,$1B,$00
 .BYTE $01,$01,$02,$16,$01,$1A,$01,$2A
 .BYTE $01,$00,$01,$15,$07,$2D,$01,$29
 .BYTE $03,$28,$02,$3C,$19,$3D,$02,$3C
 .BYTE $02,$3D,$01,$28,$01,$15,$2D,$16
 .BYTE $02,$1A,$02,$2A,$01,$01,$1C,$00
 .BYTE $02,$16,$01,$1A,$01,$29,$01,$18
 .BYTE $01,$29,$05,$2D,$01,$29,$03,$28
 .BYTE $01,$3D,$01,$3C,$20,$3D,$01,$24
 .BYTE $01,$15,$2E,$16,$02,$2A,$1D,$00
 .BYTE $01,$16,$01,$15,$01,$29,$01,$28
 .BYTE $01,$29,$04,$2D,$01,$29,$02,$28
 .BYTE $02,$3D,$01,$3C,$22,$3D,$01,$39
 .BYTE $01,$24,$01,$15,$01,$06,$2B,$16
 .BYTE $01,$1A,$01,$2A,$01,$1A,$1D,$00
 .BYTE $01,$15,$02,$28,$04,$2D,$01,$29
 .BYTE $02,$28,$01,$3D,$01,$3C,$01,$3D
 .BYTE $01,$3C,$25,$3D,$01,$28,$01,$19
 .BYTE $2B,$16,$01,$1A,$01,$2A,$01,$1A
 .BYTE $1D,$00,$01,$28,$01,$29,$04,$2D
 .BYTE $03,$28,$02,$3D,$01,$3C,$27,$3D
 .BYTE $01,$28,$01,$24,$28,$16,$02,$15
 .BYTE $02,$16,$02,$15,$1B,$00,$01,$15
 .BYTE $01,$18,$06,$2D,$01,$28,$01,$3C
 .BYTE $2D,$3D,$01,$19,$27,$16,$04,$15
 .BYTE $01,$16,$01,$15,$1A,$00,$01,$14
 .BYTE $01,$28,$07,$2D,$01,$3C,$2C,$3D
 .BYTE $01,$3C,$01,$3D,$01,$28,$01,$15
 .BYTE $29,$16,$01,$1A,$01,$2A,$01,$15
 .BYTE $1A,$00,$01,$29,$01,$28,$06,$2D
 .BYTE $01,$29,$01,$3C,$23,$3D,$01,$3C
 .BYTE $01,$3D,$01,$3C,$07,$3D,$01,$3C
 .BYTE $01,$28,$01,$19,$29,$16,$02,$1A
 .BYTE $01,$01,$19,$00,$02,$29,$06,$2D
 .BYTE $02,$28,$01,$3C,$21,$3D,$02,$3C
 .BYTE $01,$3D,$01,$00,$01,$29,$02,$3C
 .BYTE $04,$3D,$02,$3C,$01,$3D,$01,$24
 .BYTE $01,$15,$27,$16,$02,$1A,$01,$2A
 .BYTE $1A,$00,$01,$28,$07,$2D,$02,$28
 .BYTE $0B,$3D,$03,$3C,$05,$3D,$02,$3C
 .BYTE $0B,$3D,$01,$3C,$02,$3D,$01,$3C
 .BYTE $01,$3D,$01,$00,$01,$29,$02,$3C
 .BYTE $01,$3D,$01,$29,$01,$3C,$01,$3D
 .BYTE $01,$3C,$02,$3D,$01,$28,$01,$15
 .BYTE $29,$16,$01,$1A,$1A,$00,$01,$29
 .BYTE $06,$2D,$02,$28,$01,$3C,$0C,$3D
 .BYTE $01,$00,$01,$14,$03,$3D,$02,$3C
 .BYTE $01,$29,$11,$3D,$02,$14,$04,$3D
 .BYTE $02,$3C,$02,$3D,$01,$3C,$01,$3D
 .BYTE $01,$28,$29,$16,$01,$2A,$1A,$00
 .BYTE $07,$2D,$01,$28,$07,$3D,$02,$3C
 .BYTE $04,$3D,$01,$3C,$02,$00,$01,$3D
 .BYTE $04,$3C,$01,$00,$01,$14,$0A,$3D
 .BYTE $01,$3C,$01,$15,$01,$3D,$01,$29
 .BYTE $02,$14,$02,$2A,$01,$15,$01,$00
 .BYTE $01,$14,$01,$3D,$02,$3C,$03,$3D
 .BYTE $01,$3C,$01,$28,$01,$15,$07,$16
 .BYTE $01,$06,$1F,$16,$02,$1A,$01,$01
 .BYTE $19,$00,$06,$2D,$01,$29,$01,$28
 .BYTE $02,$3C,$07,$3D,$02,$29,$01,$3C
 .BYTE $01,$3D,$01,$3C,$01,$29,$01,$00
 .BYTE $02,$3D,$02,$3C,$01,$3D,$01,$00
 .BYTE $0B,$3D,$01,$3C,$01,$15,$09,$3F
 .BYTE $01,$00,$01,$3C,$04,$3D,$01,$3C
 .BYTE $01,$3D,$01,$19,$01,$15,$26,$16
 .BYTE $02,$1A,$01,$05,$19,$00,$06,$2D
 .BYTE $01,$29,$01,$3D,$02,$3C,$05,$3D
 .BYTE $01,$3C,$01,$28,$02,$00,$01,$3D
 .BYTE $01,$3C,$01,$3D,$01,$29,$01,$00
 .BYTE $02,$29,$03,$3D,$01,$00,$0B,$3D
 .BYTE $01,$3C,$0B,$3F,$01,$3D,$01,$3C
 .BYTE $03,$3D,$01,$3C,$01,$3D,$01,$29
 .BYTE $01,$15,$26,$16,$01,$1A,$01,$2A
 .BYTE $01,$1A,$18,$00,$01,$15,$05,$2D
 .BYTE $01,$29,$01,$28,$02,$3C,$07,$3D
 .BYTE $02,$3C,$01,$14,$01,$00,$01,$29
 .BYTE $09,$3F,$01,$00,$09,$3D,$01,$3C
 .BYTE $01,$3D,$04,$3F,$01,$1A,$01,$2A
 .BYTE $06,$3F,$01,$00,$01,$3C,$01,$3D
 .BYTE $01,$3C,$02,$3D,$01,$28,$01,$19
 .BYTE $27,$16,$02,$2A,$18,$00,$01,$29
 .BYTE $05,$2D,$01,$29,$01,$28,$02,$3C
 .BYTE $07,$3D,$02,$3C,$01,$3D,$01,$00
 .BYTE $01,$14,$0A,$3F,$02,$3D,$02,$3C
 .BYTE $04,$3D,$01,$3C,$01,$3D,$01,$14
 .BYTE $02,$3F,$02,$05,$01,$16,$01,$15
 .BYTE $01,$01,$05,$3F,$01,$2A,$02,$3D
 .BYTE $01,$3C,$01,$3D,$01,$3C,$01,$28
 .BYTE $01,$18,$26,$16,$01,$1A,$02,$2A
 .BYTE $18,$00,$01,$29,$05,$2D,$02,$28
 .BYTE $01,$3C,$08,$3D,$03,$3C,$01,$00
 .BYTE $0B,$3F,$01,$3C,$07,$3D,$01,$3C
 .BYTE $01,$3D,$01,$14,$02,$3F,$02,$1A
 .BYTE $01,$1B,$02,$1A,$01,$00,$05,$3F
 .BYTE $01,$29,$02,$3C,$01,$3D,$01,$3C
 .BYTE $01,$28,$01,$24,$27,$16,$02,$2A
 .BYTE $01,$16,$17,$00,$01,$28,$05,$2D
 .BYTE $02,$28,$01,$3C,$08,$3D,$01,$3C
 .BYTE $01,$3D,$01,$00,$06,$3F,$01,$2A
 .BYTE $02,$15,$01,$2A,$02,$3F,$01,$00
 .BYTE $07,$3D,$01,$3C,$01,$14,$02,$3F
 .BYTE $01,$1A,$01,$1B,$01,$15,$03,$00
 .BYTE $01,$1A,$01,$00,$04,$3F,$01,$2A
 .BYTE $01,$29,$02,$3C,$02,$3D,$01,$28
 .BYTE $01,$15,$22,$16,$01,$15,$03,$16
 .BYTE $03,$2A,$17,$00,$01,$28,$05,$2D
 .BYTE $02,$28,$01,$3C,$09,$3D,$01,$29
 .BYTE $06,$3F,$01,$00,$03,$1A,$01,$1B
 .BYTE $01,$00,$02,$3F,$01,$14,$01,$3C
 .BYTE $05,$3D,$01,$3C,$01,$14,$02,$3F
 .BYTE $01,$1A,$01,$1B,$04,$00,$01,$1A
 .BYTE $01,$16,$05,$3F,$01,$14,$02,$3C
 .BYTE $02,$3D,$01,$28,$01,$15,$22,$16
 .BYTE $01,$05,$03,$16,$01,$1A,$03,$2A
 .BYTE $15,$00,$01,$14,$01,$28,$05,$2D
 .BYTE $02,$28,$01,$3C,$06,$3D,$01,$3C
 .BYTE $01,$3D,$01,$29,$01,$2A,$05,$3F
 .BYTE $01,$1A,$02,$1B,$03,$00,$01,$1B
 .BYTE $01,$05,$02,$3F,$04,$3D,$03,$3C
 .BYTE $01,$2A,$02,$3F,$01,$1A,$01,$1B
 .BYTE $01,$1A,$02,$00,$01,$05,$01,$1B
 .BYTE $01,$00,$05,$3F,$01,$14,$02,$3C
 .BYTE $01,$3D,$01,$3C,$01,$29,$01,$19
 .BYTE $22,$16,$01,$01,$04,$16,$04,$2A
 .BYTE $01,$1A,$0E,$00,$01,$01,$03,$15
 .BYTE $01,$16,$01,$29,$01,$28,$05,$2D
 .BYTE $02,$28,$01,$3C,$06,$3D,$02,$3C
 .BYTE $01,$00,$05,$3F,$01,$2F,$02,$1B
 .BYTE $01,$01,$03,$00,$01,$1A,$01,$1B
 .BYTE $02,$3F,$01,$3D,$01,$3C,$01,$3D
 .BYTE $04,$3C,$01,$2A,$02,$3F,$01,$00
 .BYTE $03,$1B,$01,$1A,$01,$1B,$01,$1A
 .BYTE $01,$2A,$05,$3F,$01,$14,$01,$3D
 .BYTE $01,$3C,$01,$3D,$01,$3C,$01,$3D
 .BYTE $01,$19,$22,$16,$01,$00,$05,$16
 .BYTE $17,$2A,$01,$15,$01,$28,$05,$2D
 .BYTE $02,$28,$07,$3D,$02,$3C,$01,$2A
 .BYTE $05,$3F,$01,$15,$02,$1B,$04,$00
 .BYTE $01,$16,$01,$1B,$02,$3F,$01,$14
 .BYTE $01,$3D,$05,$3C,$01,$15,$03,$3F
 .BYTE $01,$15,$04,$1A,$01,$05,$06,$3F
 .BYTE $01,$14,$01,$3D,$01,$3C,$01,$3D
 .BYTE $01,$3C,$01,$3D,$01,$28,$22,$16
 .BYTE $01,$00,$01,$15,$05,$16,$12,$2A
 .BYTE $03,$1A,$01,$00,$01,$15,$01,$28
 .BYTE $05,$2D,$01,$29,$01,$28,$01,$3C
 .BYTE $06,$3D,$02,$3C,$01,$3E,$06,$3F
 .BYTE $02,$1B,$01,$1A,$03,$00,$01,$1B
 .BYTE $01,$1A,$02,$3F,$01,$00,$04,$3D
 .BYTE $02,$3C,$01,$00,$05,$3F,$02,$2A
 .BYTE $07,$3F,$01,$2A,$01,$29,$01,$3C
 .BYTE $04,$3D,$01,$24,$22,$16,$02,$01
 .BYTE $08,$16,$0B,$1A,$01,$16,$04,$15
 .BYTE $02,$00,$02,$15,$01,$28,$05,$2D
 .BYTE $01,$29,$01,$28,$01,$3C,$06,$3D
 .BYTE $02,$3C,$01,$3E,$06,$3F,$01,$15
 .BYTE $01,$1A,$04,$1B,$01,$1A,$01,$2A
 .BYTE $02,$3F,$01,$14,$01,$3D,$01,$3C
 .BYTE $05,$3D,$01,$14,$0D,$3F,$01,$29
 .BYTE $02,$3C,$02,$3D,$02,$3C,$01,$28
 .BYTE $22,$16,$01,$01,$01,$00,$08,$16
 .BYTE $06,$1A,$01,$16,$04,$15,$01,$05
 .BYTE $04,$01,$01,$00,$03,$15,$01,$28
 .BYTE $05,$2D,$01,$29,$01,$28,$01,$3C
 .BYTE $06,$3D,$02,$3C,$01,$2A,$07,$3F
 .BYTE $01,$00,$04,$1B,$01,$05,$03,$3F
 .BYTE $01,$14,$01,$3D,$01,$3C,$05,$3D
 .BYTE $01,$00,$0C,$3F,$01,$2A,$05,$3D
 .BYTE $02,$3C,$01,$28,$03,$15,$1F,$16
 .BYTE $03,$00,$04,$15,$05,$01,$03,$05
 .BYTE $05,$15,$05,$16,$01,$00,$04,$15
 .BYTE $01,$28,$05,$2D,$01,$29,$01,$28
 .BYTE $01,$3C,$07,$3D,$01,$3C,$01,$15
 .BYTE $08,$3F,$01,$2F,$02,$15,$01,$2A
 .BYTE $04,$3F,$01,$29,$02,$3C,$06,$3D
 .BYTE $0C,$3F,$01,$29,$01,$3C,$05,$3D
 .BYTE $01,$3C,$01,$28,$02,$25,$20,$14
 .BYTE $0A,$16,$06,$15,$01,$05,$01,$01
 .BYTE $02,$05,$03,$2A,$01,$15,$01,$1A
 .BYTE $04,$15,$01,$00,$01,$24,$06,$2D
 .BYTE $01,$28,$08,$3D,$01,$3C,$02,$29
 .BYTE $0E,$3F,$01,$2E,$08,$3D,$01,$3C
 .BYTE $03,$3F,$02,$2A,$05,$3F,$01,$2A
 .BYTE $01,$3D,$01,$3C,$06,$3D,$01,$3C
 .BYTE $01,$3D,$22,$25,$06,$16,$04,$15
 .BYTE $03,$05,$02,$01,$01,$05,$01,$01
 .BYTE $01,$15,$01,$1A,$01,$2A,$02,$2B
 .BYTE $01,$2F,$01,$1A,$05,$15,$01,$00
 .BYTE $01,$24,$06,$2D,$01,$29,$0A,$3D
 .BYTE $01,$00,$0E,$3F,$01,$15,$07,$3D
 .BYTE $02,$3C,$01,$2A,$01,$3F,$01,$15
 .BYTE $02,$00,$01,$29,$04,$3F,$01,$00
 .BYTE $01,$3D,$01,$3C,$08,$3D,$22,$25
 .BYTE $01,$15,$01,$1A,$01,$2A,$01,$15
 .BYTE $01,$2A,$03,$2B,$01,$15,$01,$1A
 .BYTE $02,$2A,$01,$16,$01,$2A,$02,$1A
 .BYTE $01,$16,$05,$15,$01,$16,$01,$1A
 .BYTE $01,$00,$05,$15,$01,$28,$06,$2D
 .BYTE $01,$29,$0B,$3D,$01,$2A,$01,$3F
 .BYTE $01,$2A,$01,$25,$01,$29,$02,$25
 .BYTE $06,$3F,$01,$2A,$01,$29,$07,$3D
 .BYTE $02,$3C,$01,$00,$01,$14,$01,$3C
 .BYTE $01,$3D,$01,$3C,$01,$3D,$01,$2A
 .BYTE $02,$3F,$01,$2A,$02,$3C,$06,$3D
 .BYTE $01,$3C,$02,$3D,$22,$10,$01,$05
 .BYTE $01,$15,$01,$16,$02,$15,$01,$16
 .BYTE $01,$15,$01,$1A,$04,$2A,$01,$2B
 .BYTE $01,$1A,$01,$2A,$02,$2B,$01,$2F
 .BYTE $02,$2B,$01,$1A,$02,$15,$01,$2A
 .BYTE $01,$00,$05,$15,$01,$28,$06,$2D
 .BYTE $01,$29,$01,$28,$01,$3C,$09,$3D
 .BYTE $01,$25,$01,$39,$05,$3D,$01,$39
 .BYTE $01,$25,$04,$3F,$01,$29,$01,$3C
 .BYTE $04,$3D,$01,$3C,$03,$3D,$01,$29
 .BYTE $01,$3D,$05,$3C,$01,$00,$01,$14
 .BYTE $0C,$3D,$01,$3C,$03,$14,$02,$10
 .BYTE $1D,$14,$02,$2A,$02,$05,$02,$15
 .BYTE $02,$1A,$01,$2A,$01,$15,$01,$2B
 .BYTE $02,$2A,$02,$2B,$01,$2F,$01,$2A
 .BYTE $01,$1A,$02,$2B,$01,$16,$01,$15
 .BYTE $01,$1A,$08,$15,$07,$2D,$01,$28
 .BYTE $01,$3C,$06,$3D,$01,$3C,$01,$39
 .BYTE $01,$3D,$03,$3C,$04,$3F,$01,$3D
 .BYTE $01,$3C,$01,$39,$01,$25,$01,$3F
 .BYTE $01,$15,$07,$3D,$01,$3C,$01,$3D
 .BYTE $03,$3C,$01,$3D,$02,$3C,$01,$3D
 .BYTE $01,$14,$01,$3D,$03,$3C,$0A,$3D
 .BYTE $01,$3C,$22,$10,$02,$2A,$02,$05
 .BYTE $02,$15,$01,$1A,$02,$2A,$01,$16
 .BYTE $02,$2B,$01,$1A,$03,$2B,$01,$2A
 .BYTE $01,$15,$02,$2A,$01,$16,$01,$15
 .BYTE $01,$1A,$08,$15,$07,$2D,$01,$28
 .BYTE $01,$3C,$06,$3D,$01,$3C,$02,$3D
 .BYTE $03,$3C,$04,$3F,$01,$3D,$01,$3C
 .BYTE $01,$39,$01,$25,$01,$3F,$01,$00
 .BYTE $07,$3D,$04,$3C,$02,$3D,$02,$3C
 .BYTE $01,$3D,$01,$00,$01,$3D,$03,$3C
 .BYTE $0A,$3D,$01,$3C,$05,$10,$1D,$14
 .BYTE $01,$01,$01,$00,$01,$15,$02,$2A
 .BYTE $01,$16,$02,$05,$01,$15,$01,$1A
 .BYTE $01,$16,$01,$15,$01,$2A,$01,$1A
 .BYTE $01,$15,$01,$05,$04,$16,$03,$2B
 .BYTE $01,$00,$07,$15,$07,$2D,$01,$28
 .BYTE $10,$3D,$02,$3F,$01,$3E,$01,$3C
 .BYTE $01,$3D,$01,$39,$01,$3C,$06,$3D
 .BYTE $03,$3C,$03,$3D,$01,$28,$01,$00
 .BYTE $01,$15,$01,$3D,$03,$3C,$0C,$3D
 .BYTE $01,$3C,$01,$00,$21,$15,$02,$05
 .BYTE $01,$01,$01,$05,$03,$2A,$03,$05
 .BYTE $01,$1A,$01,$2A,$01,$1A,$05,$2A
 .BYTE $02,$2B,$02,$2A,$01,$16,$01,$00
 .BYTE $07,$15,$07,$2D,$01,$28,$01,$3D
 .BYTE $01,$3C,$0E,$3D,$01,$3E,$02,$3F
 .BYTE $01,$3C,$01,$3D,$01,$39,$01,$3C
 .BYTE $07,$3D,$02,$3C,$01,$29,$01,$10
 .BYTE $01,$14,$01,$29,$01,$3D,$03,$3C
 .BYTE $02,$3D,$01,$00,$01,$29,$0B,$3D
 .BYTE $22,$15,$02,$05,$01,$01,$01,$00
 .BYTE $01,$15,$02,$2A,$01,$1A,$02,$05
 .BYTE $01,$2A,$04,$2B,$02,$2A,$01,$1A
 .BYTE $02,$2A,$02,$15,$01,$05,$01,$00
 .BYTE $07,$15,$07,$2D,$02,$28,$01,$3C
 .BYTE $0E,$3D,$01,$3E,$02,$3F,$01,$3C
 .BYTE $01,$3D,$01,$39,$01,$3C,$0A,$3D
 .BYTE $01,$29,$03,$3D,$03,$3C,$01,$3D
 .BYTE $01,$29,$01,$15,$01,$14,$0A,$3D
 .BYTE $01,$3C,$22,$15,$04,$05,$04,$01
 .BYTE $02,$05,$04,$15,$06,$16,$03,$15
 .BYTE $01,$00,$07,$15,$07,$2D,$01,$29
 .BYTE $01,$28,$01,$3C,$0E,$3D,$01,$3C
 .BYTE $03,$3D,$01,$29,$01,$3D,$01,$3C
 .BYTE $0B,$3D,$01,$3C,$01,$3D,$01,$29
 .BYTE $01,$14,$01,$00,$01,$2A,$03,$3F
 .BYTE $01,$14,$0A,$3D,$01,$3C,$22,$15
 .BYTE $02,$14,$01,$00,$01,$01,$02,$05
 .BYTE $01,$01,$01,$15,$02,$16,$03,$15
 .BYTE $07,$00,$03,$10,$01,$00,$07,$15
 .BYTE $08,$2D,$01,$28,$11,$3D,$01,$3C
 .BYTE $01,$39,$01,$25,$02,$3D,$08,$3C
 .BYTE $03,$3D,$02,$00,$07,$3F,$01,$14
 .BYTE $0A,$3D,$01,$3C,$01,$04,$01,$05
 .BYTE $20,$15,$02,$25,$01,$14,$01,$10
 .BYTE $04,$00,$09,$10,$05,$14,$02,$10
 .BYTE $01,$00,$06,$15,$08,$2D,$01,$28
 .BYTE $01,$39,$0E,$3D,$02,$3C,$01,$39
 .BYTE $01,$2A,$01,$3F,$01,$00,$01,$15
 .BYTE $07,$00,$01,$15,$02,$2A,$01,$15
 .BYTE $08,$3F,$01,$00,$01,$29,$0A,$3D
 .BYTE $01,$3C,$22,$15,$0C,$10,$07,$14
 .BYTE $04,$10,$01,$14,$01,$00,$04,$15
 .BYTE $01,$00,$01,$15,$08,$2D,$02,$28
 .BYTE $0D,$3D,$02,$3C,$01,$3D,$01,$25
 .BYTE $02,$3F,$01,$00,$01,$3F,$02,$2A
 .BYTE $03,$3F,$01,$2A,$04,$3F,$01,$00
 .BYTE $06,$3F,$02,$00,$01,$10,$0B,$3D
 .BYTE $01,$3C,$22,$15,$02,$10,$04,$14
 .BYTE $02,$10,$04,$14,$05,$10,$03,$14
 .BYTE $03,$10,$01,$14,$01,$00,$04,$15
 .BYTE $01,$00,$01,$15,$01,$29,$07,$2D
 .BYTE $01,$29,$01,$28,$0A,$3D,$02,$3C
 .BYTE $02,$3D,$01,$29,$01,$3E,$03,$3F
 .BYTE $01,$15,$02,$3F,$01,$15,$04,$3F
 .BYTE $01,$2A,$03,$3F,$01,$00,$01,$3F
 .BYTE $01,$25,$02,$00,$01,$10,$01,$14
 .BYTE $02,$20,$01,$10,$0B,$3D,$01,$3C
 .BYTE $02,$14,$20,$29,$04,$14,$02,$10
 .BYTE $04,$14,$02,$10,$06,$14,$02,$10
 .BYTE $03,$14,$01,$10,$01,$00,$04,$15
 .BYTE $01,$00,$01,$15,$01,$29,$07,$2D
 .BYTE $01,$29,$01,$28,$09,$3D,$01,$3C
 .BYTE $02,$3D,$01,$39,$01,$24,$01,$3A
 .BYTE $04,$3F,$01,$2A,$02,$3F,$01,$15
 .BYTE $04,$3F,$01,$2A,$03,$3F,$02,$00
 .BYTE $03,$10,$04,$20,$01,$00,$0B,$3D
 .BYTE $01,$3C,$01,$14,$01,$29,$02,$25
 .BYTE $01,$24,$1D,$14,$02,$10,$01,$14
 .BYTE $05,$10,$02,$14,$0A,$10,$05,$00
 .BYTE $06,$15,$01,$28,$08,$2D,$01,$28
 .BYTE $01,$3C,$08,$3D,$01,$3C,$02,$39
 .BYTE $01,$3D,$01,$29,$01,$15,$04,$3F
 .BYTE $01,$2A,$01,$3F,$01,$2A,$01,$00
 .BYTE $02,$15,$02,$00,$03,$10,$02,$14
 .BYTE $07,$20,$01,$10,$01,$29,$01,$3C
 .BYTE $0A,$3D,$01,$3C,$01,$2A,$04,$15
 .BYTE $1D,$00,$03,$10,$02,$14,$07,$10
 .BYTE $05,$00,$01,$14,$0C,$15,$01,$05
 .BYTE $01,$28,$08,$2D,$01,$29,$0A,$3D
 .BYTE $03,$3C,$01,$3D,$01,$14,$06,$10
 .BYTE $02,$14,$01,$10,$0E,$20,$02,$10
 .BYTE $0C,$3D,$01,$3C,$01,$3F,$01,$00
 .BYTE $01,$04,$1F,$15,$03,$00,$01,$10
 .BYTE $0F,$15,$01,$05,$05,$15,$01,$00
 .BYTE $04,$15,$01,$00,$01,$28,$01,$29
 .BYTE $08,$2D,$01,$3C,$0C,$3D,$02,$3C
 .BYTE $01,$00,$01,$10,$15,$20,$01,$10
 .BYTE $01,$29,$0C,$3D,$01,$3C,$01,$3F
 .BYTE $01,$2A,$20,$15,$01,$00,$01,$10
 .BYTE $11,$15,$01,$00,$05,$15,$01,$00
 .BYTE $04,$15,$01,$00,$02,$29,$08,$2D
 .BYTE $01,$3C,$0D,$3D,$01,$3C,$01,$00
 .BYTE $01,$10,$15,$20,$01,$00,$0E,$3D
 .BYTE $02,$3F,$39,$15,$01,$00,$04,$15
 .BYTE $01,$00,$01,$15,$01,$28,$01,$29
 .BYTE $02,$14,$05,$2D,$01,$3C,$0F,$3D
 .BYTE $01,$00,$01,$10,$13,$20,$01,$10
 .BYTE $01,$29,$0D,$3D,$01,$3C,$02,$3F
 .BYTE $01,$04,$1F,$00,$0A,$15,$01,$05
 .BYTE $04,$00,$01,$04,$0A,$15,$01,$05
 .BYTE $05,$15,$01,$00,$01,$3A,$03,$3F
 .BYTE $01,$2A,$03,$2D,$10,$3D,$01,$3C
 .BYTE $01,$39,$01,$00,$01,$20,$02,$25
 .BYTE $04,$20,$01,$24,$09,$20,$01,$10
 .BYTE $01,$29,$01,$3C,$0D,$3D,$01,$3C
 .BYTE $02,$3F,$01,$00,$29,$15,$04,$00
 .BYTE $01,$05,$0B,$15,$01,$05,$05,$15
 .BYTE $01,$00,$04,$3F,$01,$2A,$03,$2D
 .BYTE $01,$28,$0F,$3D,$01,$3C,$01,$3D
 .BYTE $01,$14,$01,$11,$02,$25,$01,$24
 .BYTE $03,$20,$02,$25,$08,$20,$01,$10
 .BYTE $01,$3D,$01,$3C,$0D,$3D,$01,$3C
 .BYTE $02,$3F,$01,$00,$22,$15,$02,$00
 .BYTE $01,$04,$14,$15,$01,$00,$05,$15
 .BYTE $03,$2F,$03,$3F,$01,$00,$02,$2D
 .BYTE $01,$28,$02,$3C,$0E,$3D,$01,$3C
 .BYTE $02,$3D,$01,$14,$02,$39,$02,$35
 .BYTE $01,$25,$04,$39,$01,$35,$01,$25
 .BYTE $01,$20,$01,$10,$01,$00,$01,$3D
 .BYTE $02,$3C,$0E,$3D,$01,$3C,$02,$00
 .BYTE $23,$15,$01,$00,$10,$15,$01,$14
 .BYTE $01,$29,$01,$14,$03,$15,$02,$00
 .BYTE $04,$15,$01,$3F,$02,$2F,$03,$3F
 .BYTE $01,$2A,$01,$29,$01,$2D,$01,$28
 .BYTE $01,$3D,$02,$3C,$0F,$3D,$01,$3C
 .BYTE $01,$3D,$01,$25,$01,$3A,$01,$39
 .BYTE $02,$35,$01,$25,$04,$39,$01,$35
 .BYTE $01,$10,$01,$14,$01,$3D,$03,$3C
 .BYTE $0E,$3D,$01,$3C,$05,$00,$20,$15
 .BYTE $01,$05,$0C,$15,$02,$00,$01,$14
 .BYTE $04,$29,$01,$00,$03,$15,$01,$00
 .BYTE $03,$15,$01,$00,$03,$2F,$04,$3F
 .BYTE $01,$29,$01,$2D,$01,$29,$01,$28
 .BYTE $15,$3D,$02,$00,$01,$15,$03,$25
 .BYTE $01,$29,$01,$25,$01,$10,$01,$3D
 .BYTE $01,$3C,$03,$3D,$01,$3C,$0F,$3D
 .BYTE $25,$15,$01,$05,$06,$15,$05,$00
 .BYTE $02,$14,$01,$15,$04,$29,$01,$25
 .BYTE $01,$00,$03,$15,$01,$00,$03,$15
 .BYTE $01,$00,$03,$2F,$04,$3F,$01,$19
 .BYTE $01,$2D,$01,$29,$01,$28,$15,$3D
 .BYTE $01,$29,$01,$14,$02,$00,$01,$10
 .BYTE $01,$15,$01,$14,$01,$00,$01,$10
 .BYTE $01,$3D,$02,$3C,$02,$3D,$01,$3C
 .BYTE $0F,$3D,$2C,$15,$01,$10,$01,$14
 .BYTE $01,$29,$03,$24,$02,$14,$04,$15
 .BYTE $01,$14,$04,$15,$01,$00,$03,$15
 .BYTE $01,$00,$03,$2F,$04,$3F,$01,$00
 .BYTE $02,$2D,$02,$28,$01,$3C,$01,$3D
 .BYTE $01,$3C,$10,$3D,$0A,$3C,$01,$3D
 .BYTE $01,$39,$01,$3C,$12,$3D,$04,$14
 .BYTE $01,$25,$1D,$29,$09,$15,$01,$00
 .BYTE $01,$10,$01,$14,$06,$15,$04,$00
 .BYTE $05,$15,$02,$00,$02,$15,$01,$00
 .BYTE $01,$3F,$02,$2F,$04,$3F,$01,$14
 .BYTE $01,$29,$01,$2D,$01,$29,$01,$28
 .BYTE $01,$3D,$02,$3C,$10,$3D,$01,$28
 .BYTE $02,$3D,$06,$3C,$01,$3D,$01,$24
 .BYTE $01,$3D,$02,$3C,$11,$3D,$02,$29
 .BYTE $02,$24,$1E,$14,$0A,$15,$02,$10
 .BYTE $04,$15,$01,$04,$01,$00,$09,$15
 .BYTE $02,$00,$02,$15,$01,$00,$02,$3F
 .BYTE $01,$2F,$04,$3F,$01,$15,$02,$2D
 .BYTE $01,$29,$01,$28,$01,$3D,$02,$3C
 .BYTE $11,$3D,$01,$28,$01,$39,$07,$3D
 .BYTE $01,$39,$03,$3C,$11,$3D,$01,$15
 .BYTE $04,$14,$20,$15,$01,$05,$06,$15
 .BYTE $02,$00,$01,$05,$0E,$15,$02,$00
 .BYTE $02,$15,$01,$00,$01,$01,$01,$00
 .BYTE $03,$15,$01,$00,$01,$15,$01,$29
 .BYTE $03,$2D,$01,$29,$01,$28,$01,$3C
 .BYTE $11,$3D,$03,$3C,$14,$3D,$02,$3C
 .BYTE $01,$3D,$01,$3C,$02,$3D,$01,$29
 .BYTE $01,$28,$01,$15,$01,$14,$01,$00
 .BYTE $01,$04,$21,$15,$01,$05,$01,$04
 .BYTE $13,$15,$01,$05,$01,$00,$01,$04
 .BYTE $01,$05,$03,$15,$01,$01,$02,$15
 .BYTE $01,$00,$01,$3D,$01,$29,$01,$00
 .BYTE $06,$2D,$01,$28,$16,$3D,$04,$3C
 .BYTE $0F,$3D,$01,$39,$01,$29,$03,$28
 .BYTE $02,$29,$26,$15,$02,$00,$0F,$15
 .BYTE $02,$00,$0C,$15,$01,$00,$01,$3C
 .BYTE $01,$3D,$01,$00,$06,$2D,$01,$29
 .BYTE $01,$28,$02,$3C,$13,$3D,$01,$3C
 .BYTE $05,$3D,$01,$3C,$02,$3D,$03,$3C
 .BYTE $03,$3D,$01,$29,$01,$28,$01,$14
 .BYTE $02,$29,$01,$2A,$05,$3F,$23,$15


MyNMI:
 RTI
MyIRQ:
 RTI



    .org $FFFA
    .word MyNMI
    .word RESET
    .word MyIRQ