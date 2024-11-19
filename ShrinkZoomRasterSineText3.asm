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


VStripScreen     = $A0
VStripScreenH    = $A1

;Screen            = $00       ; GFX screen location
;ScreenH           = $01       ; to draw TO
;VGASync           = $E1;***** IF NMI hooked up to vsync this will be 1 after sync(s), you set to zero yourself *****
;VGAClock          = $C;***** IF NMI hooked up to vsync this will DEC *****




VLoopCount        = $03

VLoops            = 7

;DrawTxtLine      = $1700

 .ORG $200
 ; .org $DE00


ProgramStart:
 STZ RasterTmpT
 LDA #15
 STA RasterTmpV
 LDA #25
 STA RasterTmpS 
 
;  LDA #0
;  jsr FillScreen

 LDA #1
 STA DelayCount
 ;JSR UpText

MyOrg:
 LDA #1
 STA DelayCount



 STZ Screen ; Ben Eater's Worlds Worst Video card 
; LDA TextLoc
 ;STA Screen
 LDA #$25   ; uses the upper 8Kb of system RAM
 ;LDA TextLocH
 STA ScreenH; This starts at location $2000
 LDY #$0
 ;LDY $99
 LDY #$80
 STY Screen
 STY $99
MoveText:
 ;LDY #0
 jsr Delay
 jsr DelaySafe ;Extra Delay to get rid of tearing
 jsr DelaySafe
 jsr DelaySafe
 jsr DelaySafe
 ;jsr DelaySmall
 
 jsr DrawTxtLine ;$1600 ;Stuck TXT function here for now.
 ;jsr Delay
 DEC $99
 LDY $99
 BEQ MoveContinue
 STY Screen
 ;inc ScreenH
 LDA ScreenH
 ;cmp #50
 ;rts
 ;BCS MoveContinue
 jmp MoveText
MoveContinue:
 

 LDA #30
 STA DelayCount 
 LDA #0
 JSR Delay ;Vsync
 ;JSR FillScreen

 LDA #VLoops
 STA VLoopCount


;  STZ RasterTmpT
;  LDA #15
;  STA RasterTmpV

;  LDA #25
;  STA RasterTmpS 

 

Start:
 LDA #1
 STA DelayCount ;Vsync
 
 LDA #120 ;120 = 611 cycles. 163/826 cycles matches Hline bt this works
 STA HBarOffScreenDelay


 LDA #$20;TopRasterStart;#$2 ;$20
 STA RVScreenH
 LDA #$00
 STA RVScreen
 stz TmpV
 ldx #104
 
 ; Change colors
 LDY RasterTmpT
 jsr RasterLoad
 STY RasterTmpT 

 LDY RasterTmpV
 jsr RasterLoad
 STY RasterTmpV

 LDY RasterTmpS
 jsr RasterLoad
 STY RasterTmpS

VLoopTop:
    LDA TmpV
    STA RVScreen
    STA Screen
    LDA RVScreenH
    STA ScreenH
    LDY RasterTmpT
    jsr RasterLoad
   ; STY RasterTmpT
    ; JSR Delay ;Vsync 
    ; Delay moved to bottom of loop
   
    ; Bar 1
    jsr VBar;VLine
    
    STX RVScreen
    STX RVScreenX
    DEX
    
    ; Bar 2
    LDY RasterTmpV
    jsr RasterLoad
    ; Sync for raster bar 2.
    ; Without the bar tears because the 'scanbeam' catches up to the draw.
    ; JSR Delay ;Vsync
    PHY ; 7730 cycles delay instead of vsync.
    PHX ; Much smoother/faster with just the 1 vysnc at the end
    LDY #255
    LDX #10
    JSR DelaySmallY
    ;JSR DelayTinY
    CLC ;  Could do something else here like txt or music?
    PLX
    PLY
    
    jsr VBar
    
    ; Bar 3
    LDY VSineX
    inc VSineX
    LDA Sine,Y
    ADC #17 ;Center it
    STA RVScreen
    STA Screen
    LDY RasterTmpS
    jsr RasterLoad
    ; Vsync sandwich keeps this bar on top and provides for rest of timeing
    ;IE The Sync Anchor is here 
    JSR Delay ;Vsync ; Make sure we are done drawing the 2 previous bars
    jsr VBar
    
        PHY ; 7730 cycles delay instead of vsync.
    PHX ; Much smoother/faster with just the 1 vysnc at the end
    LDY #255
    LDX #10
    JSR DelaySmallY
    ;JSR DelayTinY
    CLC ;  Could do something else here like txt or music?
    PLX
    PLY

    CLC
    LDA #10
    ADC RVScreen
    STA RVScreen
    jsr VBar  ;Wow! With the new draw routine I can Cram another line in!

    JSR Delay ;Vsync ; Make sure this 1 bar is done.

    inc TmpV
    lda TmpV
    CMP #104
    BNE VLoopTop
VLoopBottom: 
  
  ;jmp Start
  ;rts
   
  DEC VLoopCount
  LDA VLoopCount

  ;BNE Start 
  BEQ VLoopEnd
  JMP Start
VLoopEnd:

; ; Text
;  STZ Screen ; Ben Eater's Worlds Worst Video card 
;  STA Screen
;  LDA #$30   ; uses the upper 8Kb of system RAM
;  STA ScreenH; This starts at location $2000 
;  jsr $1600

UpText:
 LDA #1
 STA DelayCount
 ;STZ Screen ; Ben Eater's Worlds Worst Video card 
; LDA TextLoc
 ;STA Screen
 LDA #$3A ;C   ; uses the upper 8Kb of system RAM
 ;LDA TextLocH
 STA ScreenH; This starts at location $2000
 STA VStripScreenH 
 LDY #$0;#$80
 STA Screen
 STA VStripScreen
 ;LDY $99
 
 

MoveTextUp:
 ;LDY #0
 jsr Delay
  ;Extra Delay to get rid of tearing
   LDY #255
   LDX #13
   JSR DelaySmallY
 
 LDA Screen
 STA VStripScreen
 LDA ScreenH
 STA VStripScreenH
 jsr DrawTxtLine;$1600 ;Stuck TXT function here for now.
 
 jsr VStripDraw

 
 STZ Screen

 jsr Delay
 ;Extra Delay to get rid of tearing
   LDY #255
   LDX #13
   JSR DelaySmallY

 LDA Screen
 STA VStripScreen
 LDA ScreenH
 STA VStripScreenH
 jsr DrawTxtLine;$1600 ;Stuck TXT function here for now.

 jsr VStripDraw
 


 LDY #$80
 STY Screen
 DEC ScreenH
 
 
 LDA ScreenH
 CMP #$29
 BEQ MoveContinueUp

 jsr Delay
 


 jmp MoveTextUp
MoveContinueUp:


 LDY RasterTmpV
 jsr RasterLoad
 ;STY RasterTmpV



; H Rasters



 LDA TopRasterStart;#$2 ;$20
 STA RVScreenH
 LDA #$00
 STA RVScreen

 STZ RasterTmp
 LDA #1
 STA DelayCount 
 JSR Delay
 ;LDY #4
 ;JSR DelayTinY
 LDA #0
 ;JSR FillScreen
 LDA #$20
 STA RScreenH
 LDA #$00
 STA RScreen
 LDA #0
 STA DelayCount 
 
;  ; Change colors
;  LDY RasterTmpT
;  jsr RasterLoad
;  STY RasterTmpT 
;  LDY RasterTmpV
;  jsr RasterLoad
;  STY RasterTmpV


Top:
 LDA #1
 STA DelayCount 
 LDA #TopRasterStart;#$2 ; $20
 STA RScreenH
 LDA #$00
 STA RScreen
 LDY #140;#57
 STY TmpY
 
 
 LDA #BottomRasterStart;#$3C ;#$3B
 STA RScreenHUp
 STA ScreenH
 LDA #$00; #$80
 STA RScreenUp
 STA Screen

; Multi-Bar render 12 Raster bars total
; Using Line routine that bounds checks
TheLoop:  
  ; Down Multi-Bar Raster
  LDY RasterTmpT
  JSR RasterLoad
  ;JSR Delay ; Vsync
  


  JSR HBarDown
  jsr HBarRenderDown
  jsr HBarRenderDown
  jsr HBarRenderDown
  jsr HBarRenderDown
  jsr HBarRenderDown
  jsr HBarRenderDown ; x 7 Raster lines down
  ;jsr HBarRenderDown
  ;jsr HBarRenderDown
  ;jsr HBarRenderDown
  JSR NextHLineRH
   ;White Bar Screen clke?
  ; LDA #63 ;color
  ; LDY #99 ;$51 ;len 
  ; JSR HLine
  ; JSR NextHLineRH
  
  ; Up Multi-Bar Raster
  LDY RasterTmpV
 ; JSR RasterLoad
  LDA RScreenHUp
  STA ScreenH
  LDA RScreenUp
  STA Screen

  ;JSR Delay ; Vsync
  jsr HBarRenderUp
  jsr HBarRenderUp
  jsr HBarRenderUp
  jsr HBarRenderUp
  jsr HBarRenderUp ; x5 Raster Lines up 
  JSR LastHLine
  ldy TmpY
  DEY
  STY TmpY
  BNE TheLoop

 

 LDY #140;#57
 STY TmpY
 
 
 ;Change colors
 ;INC RasterTmpT
 LDY RasterTmpT
 jsr RasterLoad
 STY RasterTmpT 
 ;INC RasterTmpV
 LDY RasterTmpV
 jsr RasterLoad
 STY RasterTmpV
 LDY RasterTmpS
 jsr RasterLoad
 STY RasterTmpS


; jmp Top
 ;jmp Start
 ;jmp MyOrg
 jmp ZoomDemoRestart




RasterLoad:
 ;LDY RasterTmp
 CLC
RasterLoadY:
 CPY #35 ;7 colors x 5 lines
 ;BNE NoRasterLoadReset
 BCC NoRasterLoadReset
 LDY #0
 CLC ;Seems to need this to not glitch other things?
NoRasterLoadReset:
 LDA RasterColors,y
 STA RColor1
 INY
 LDA RasterColors,y
 STA RColor2
 INY
 LDA RasterColors,y
 STA RColor3
 INY
 LDA RasterColors,y
 STA RColor4
 INY
 LDA RasterColors,y
 STA RColor5
 INY
 ;STY RasterTmp
 RTS



ZoomDemoRestart:
    LDA  #>ScriptTbl
    STA ScriptH
    LDA  #<ScriptTbl
    STA Script
    LDY #0
    STY ScriptY

ATop: 
  
  JSR ReadScript
  TAX
  jmp (JumpTbl, x)
  
  RTS
; jmp ATop



Shrink:
SrSourceH: 
 lda #$06
 sta SrLSource+2
SrSourceL:
 lda #$0
 sta SrLSource+1
SrDestH:
 lda #$20
 sta SrLDest+2
SrDestL:
 lda #0
 sta SrLDest+1

SrLoopIm: 
 ldx #0
 lda ShrinkFactorV
 sta CurShrinkV
SrLoopNext: ;Image loop
 PHX
 LDX #0 ;#32 ;32 'lines' as each line is 255 IE 2 lines each
 LDY #0
 lda ShrinkFactor
 sta CurShrink
 ;lda ShrinkFactorV
 ;sta CurShrinkV
SrLoopImL:

SrLSource: 
 LDA ISource,X ;$0500,X ;Absolute index source memory address, starting at $500 for example
SrLDest:
 STA $2000,Y   ;Absolute index dest memory address, starting at $2000 for screen
 iny
 inx
SrSkip:
  dec CurShrink
  bne SrNoSkip
  INX ;Skip a pixel IE make the image smaller.

  lda ShrinkFactor
  sta CurShrink
SrNoSkip:
SrWidth:
 cpx #101 ; width +1 for edge
 bcc SrLoopImL ;loop until our line len


SrVShrinkLoop: 
 ; Modifies the code above:
 ; 16 bit add to go to next row.
 PLX
 clc
 lda #$80
 ADC SrLSource+1
 sta SrLSource+1
 lda #$0
 adc SrLSource+2
 sta SrLSource+2
 clc
 
 DEC CurShrinkV
 BNE SrVNoSkip 
 clc

 lda #$80
 ADC SrLSource+1
 sta SrLSource+1
 lda #$0
 adc SrLSource+2
 sta SrLSource+2
 lda ShrinkFactorV
 sta CurShrinkV
 inx
 
SrVNoSkip:
 clc
 lda #$80
 ADC SrLDest+1
 sta SrLDest+1
 lda #$0
 adc SrLDest+2
 sta SrLDest+2
 cmp #$40      ; $4000 is off screen. Will crash system if we stomp on the ACIA and VIA
 BCS SrRTS
 ;PLX
 inx
SrHeight:
 CPX #63 ;height in  lines.. 
 bcc SrLoopNext ;if we're not there yet, loop
SrRTS:
 RTS


Zoom:
 lda ShrinkFactor
 sta CurShrink
 lda ShrinkFactorV
 sta CurShrinkV
ZSourceH: 
 lda #$05
 sta ZDLSource+2
 sta ZSLSource+2
ZSourceL:
 lda #$80
 sta ZDLSource+1
 sta ZSLSource+1
ZDestH:
 lda #$20
 sta ZDLDest+2
 sta ZDLDest2+2
 sta ZDLDestDL+2
 sta ZDLDest2DL+2
 sta ZSLDest+2
 sta ZSLDest2+2 
ZDestL:
 lda #0
 sta ZDLDest+1
 sta ZDLDest2+1
 sta ZSLDest+1
 sta ZSLDest2+1
 lda #$80
 sta ZDLDestDL+1
 sta ZDLDest2DL+1

ZLoopIm: ;Image loop
ZSrHeight:
 LDX #0;#60 ;height in  lines.. /2 
ZLoopNext: ; Next line (double line?)
 PHX
 LDX #0 ;#32 ;32 'lines' as each line is 255 IE 2 lines each
 LDY #0
 lda ShrinkFactor
 sta CurShrink
ZoomStart:
  dec CurShrinkV
  BEQ ZDouble
ZSLoopImL: ; Next pixel in line
; --- Single Line ---
ZSLSource: 
  LDA $0500,X ;Absolute index source memory address, starting at $500 for example
ZSLDest:
  STA $2000,Y ;Absolute index dest memory address, starting at $2000 for screen
  INY
  dec CurShrink
  bne ZSNoDouble
ZSLDest2:      ; Double pixel 
  STA $2000,Y ; Absolute index dest memory address, starting at $2000 for screen
  iny
  lda ShrinkFactor
  sta CurShrink
ZSNoDouble: ;Not a Double pixel
 inx
ZSSrWidth:
 cpx #100 ;cpy #100 ; width
 bcc ZSLoopImL ;loop until our line len
 ;cpy #100 ; Max width
 ;bcc ZSLoopImL ;loop until our line len
; Next row of source
  clc
  lda #$80
  ADC ZDLSource+1
  sta ZDLSource+1
  sta ZSLSource+1
  lda #$0
  adc ZDLSource+2
  sta ZDLSource+2
  sta ZSLSource+2
; Inc single line vals of dest
 clc
 lda #$80
 ADC ZSLDest+1 ; Add the SINGLE line value
 ;Single line function update
 sta ZSLDest+1   ; Save single line value
 sta ZSLDest2+1
 sta ZDLDest+1   ; Save DOUBLE line value
 sta ZDLDest2+1
 lda #$0
 adc ZSLDest+2; Add the SINGLE line value
 ;Single line function update
 sta ZSLDest+2  ; Save single line value
 sta ZSLDest2+2

  sta ZDLDest+2  ; Save DOUBLE line value
  sta ZDLDest2+2
 
 cmp #$40 ;off screen, don't continue 
 beq ZDDonePLX;ZSEndLine
 
ZSEndLine:
; --- Line(s) done, check for more lines?
 PLX
 dex 
 ;INX
 ;bne ZLoopNext ;if we're not there yet, loop
 ;RTS
 BEQ ZDDone
 jmp ZLoopNext
ZDDone:
  RTS
ZDDonePLX:
  PLX
  RTS

ZDouble:
 lda ShrinkFactorV
 sta CurShrinkV
 ; ; Inc double line vals of dest
 clc
 lda #$80
 ADC ZDLDest+1  ;Add the SINGLE line value
 sta ZDLDestDL+1
 sta ZDLDest2DL+1;Save Double line value
 lda #$0
 adc ZDLDest+2
 sta ZDLDestDL+2
 sta ZDLDest2DL+2
; Double Line update done.
ZDLoopImL: ; Next pixel in line
; --- Double Line ---
ZDLSource: 
  LDA $0500,X ;Absolute index source memory address, starting at $500 for example
ZDLDest:
  STA $2000,Y ;Absolute index dest memory address, starting at $2000 for screen
ZDLDestDL: ;Store double line
  STA $2080,Y ;Absolute index dest memory address, starting at $2000 for screen
  INY
  dec CurShrink
  bne ZDNoDouble
ZDLDest2:      ; Double pixel 
  STA $2000,Y ; Absolute index dest memory address, starting at $2000 for screen
ZDLDest2DL:    ; Store double line, double pixel
  STA $2080,Y ; Absolute index dest memory address, starting at $2000 for screen
  iny
  lda ShrinkFactor
  sta CurShrink
ZDNoDouble:
 inx
ZDSrWidth:
 cpx #100
 bcc ZDLoopImL ;loop until our line len
ZDSrWidthy:
; cpy #100 ; Max width
; bcc ZDLoopImL ;loop until our line len
; --- Double Line Done  ---
; --- Update Vals  ---
 ; Self modify code:
; Next row of source
  clc
  lda #$80
  ADC ZDLSource+1
  sta ZDLSource+1
  sta ZSLSource+1
  lda #$0
  adc ZDLSource+2
  sta ZDLSource+2
  sta ZSLSource+2
; Inc single line vals of dest
 clc
 lda #$80
 ADC ZDLDestDL+1 ; Add the DOUBLE line value
 ;Single line function update
 sta ZSLDest+1   ; Save single line value
 sta ZSLDest2+1
 sta ZDLDest+1   ; Save DOUBLE line value
 sta ZDLDest2+1
 lda #$0
 adc ZDLDestDL+2; Add the DOUBLE line value
 ;Single line function update
 sta ZSLDest+2  ; Save single line value
 sta ZSLDest2+2
 sta ZDLDest+2  ; Save DOUBLE line value
 sta ZDLDest2+2
 cmp #$40 ;off screen, don't continue 
 beq ZSEndLineOS
ZDEndLine: ; End Double line
; --- Line(s) done, check for more lines?
 PLX
 dex 
 beq ZDDoneRTS
 dex
 beq ZDDoneRTS
 jmp ZLoopNext ;if we're not there yet, loop
ZSEndLineOS:
 PLX
 dex 
ZDDoneRTS:
 RTS



FillScreen:  ; Color in A, X,Y and Screen pointer are smashed
; LDA #$00   ; Ben Eater's Worlds Worst Video card
  LDY #$20   ; uses the upper 8Kb of system RAM
  STY ScreenH; This starts at location $2000
  ;LDY #0 
  ldx #32    ; Fill even and odd lines, IE 64 lines / 2
FillScreenLoop:
; Use this 'Faster Fill' routine since I already have an unrolled HLine routine for Raster Bars.
; 52,690 cycles to clear screen. 8.23 cycles per pixel, follows scan line.
; best routine is only 32,704 cycles, but does not follow the scan beam and also takes up more room.
 STZ Screen ;  
 ;jsr HLine  ; Draw Even Line
 jsr HLineNoBounds
 ldy #$80
 STY Screen
 ;jsr HLine  ; Draw Odd Line
 jsr HLineNoBounds
 inc ScreenH; Next pair of lines
 DEX                ; Unrolling this Loop 32x saves less than 160 cycles.
 BNE FillScreenLoop ; Leave it looped for now.
 RTS

; Small Fill routine, not very fast. Does not need line draw routine.
  ; STA (Screen),Y ; Clears offscreen area as well. IE 8k window is filled.
  ; INY
  ; BNE .MemLoop
  ; INC ScreenH
  ; LDX ScreenH
  ; CPX #$40 ;Top of screen memory is $3F-FF, 
  ; BNE .MemLoop; Do until $40-00
; Reset Screen? Not needed right now. 
;   STZ Screen ; Ben Eater's Worlds Worst Video card 
;   LDA #$20   ; uses the upper 8Kb of system RAM
;   STA ScreenH; This starts at location $2000
; RTS
 
DelaySmall:  ; Trashes X and Y
  LDX #255
  LDY #255

DelaySmallY: ; Delay in X and Y
  DEY
  BNE DelaySmallY
  DEX 
  BNE DelaySmallY

  RTS

DelaySafe: ; Delay in X, trashes Y
  PHY
  ;LDX #255
  LDY #255
DelaySafeLoop:
  nop
  DEY
  BNE DelaySafeLoop
  CLC
  PLY
  RTS

DelayTinY:
  DEY
  BNE DelayTinY
  RTS

Delay: ; NormalLuser VGA clock delay routine:
  PHA           ; This results in 60 interrupts a second. IE on the V sync pulse.
  LDA DelayCount; Replace with a couple of nested loops and some nop's if you don't have NMI vsync.
  BEQ NoDelay   ; 0, No delay
  STA VGAClock  ; Store the number of cycles we want to wait.
DelayTop:    
  LDA VGAClock  ; See if the Vsync NMI has counted down to 0.
  BNE DelayTop  ; Keep waiting until 0/Vsync NMI triggered.
NoDelay:
  PLA
 RTS            ; Finished countdown.



jHLine:
  JSR ReadScript  
  STA ScreenH    
  JSR ReadScript
  STA Screen
  JSR ReadScript
  TAY   ;LEN in Y
  JSR ReadScript ;Get Color in A
  JSR HLine ;Draw line
 JMP ATop;RTS

jRTS:
 RTS

jFillScreen:
  JSR ReadScript
  JSR FillScreen
 JMP ATop

jDelay:
  JSR ReadScript
  STA DelayCount
  JSR Delay
 JMP ATop

jZoom:
  JSR ReadScript
  sta ZSourceH+1
  JSR ReadScript
  sta ZSourceL+1
  JSR ReadScript
  sta ZDestH+1
  JSR ReadScript
  sta ZDestL+1
  JSR ReadScript
  sta ZDSrWidth+1
  sta ZSSrWidth+1
  JSR ReadScript
  sta ZSrHeight+1
  JSR ReadScript
  sta ShrinkFactor
  JSR ReadScript
  sta ShrinkFactorV
  JSR Zoom
 JMP ATop

jShrink:
  JSR ReadScript
  sta SrSourceH+1
  JSR ReadScript
  sta SrSourceL+1
  JSR ReadScript
  sta SrDestH+1
  JSR ReadScript
  sta SrDestL+1
  JSR ReadScript
  sta SrWidth+1
  JSR ReadScript
  sta SrHeight+1
  JSR ReadScript
  sta ShrinkFactor
  JSR ReadScript
  sta ShrinkFactorV
  JSR Shrink
 JMP ATop

jRestart:
  ;JMP ZoomDemoRestart
  JMP MyOrg;ProgramStart

ReadScript:
  STY TmpY
  LDY ScriptY
  LDA (Script),y
  TAX
  INY
  BNE RSkipInc
  INC ScriptH
RSkipInc:
  STY ScriptY
  LDY TmpY
 RTS

tRTS     = 0
tFill    = 2
tDelay   = 4
tZoom    = 6
tShrink  = 8
tRestart = 10
tHLine   = 12

JumpTbl:  ;  0         2         4      6       8        10       12
    .word  jRTS, jFillScreen, jDelay, jZoom, jShrink, jRestart, jHLine
 .byte "Script" 
ScriptTbl:
    ; .byte  tFill, 0, tDelay, 30, tFill, 5, tDelay, 20, tFill, 63 
    ; .byte  tFill, 63 

    ;   Zoom   Source     Dest    W / H Zoom/V 
    ; .byte  tZoom , $8A, $80, $20, $00, 55, 63, 1, 1
    ; .byte  tDelay, 60
    ; .byte  tZoom , $8A, $80, $20, $00, 68, 64, 2, 2
    ; .byte  tDelay, 60
    ; .byte  tZoom , $8A, $80, $20, $00, 68, 64, 3, 3
    ; .byte  tDelay, 60
    ; .byte  tZoom , $8A, $80, $20, $00, 68, 63, 4, 4
    ; .byte  tDelay, 60
    ; .byte  tZoom , $8A, $80, $20, $00, 68, 64, 5, 5
    ; .byte  tDelay, 60
    ; .byte  tShrink, $8A, $80, $20, $00, 68, 64, 1, 1
    ; ; .byte  tDelay, 60
    ; .byte  tFill, 63 
 
     .byte  tFill, 63 
   ;.byte  tFill, 0

    ;    .byte tHLine,$20,$00,100,63
    ; .byte tHLine,$20,$80,100,63
    ; .byte tHLine,$21,$00,100,63
    ; .byte tHLine,$21,$80,100,63
    ; .byte tHLine,$22,$00,100,63
    ; .byte tHLine,$22,$80,100,63
    ; .byte tHLine,$23,$00,100,63
    ; .byte tHLine,$23,$80,100,63
    ; .byte tHLine,$24,$00,100,63
    ; .byte tHLine,$24,$80,100,63
    ; .byte tHLine,$25,$00,100,63
    ; .byte tHLine,$25,$80,100,63
    ; .byte tHLine,$26,$00,100,63
    ; .byte tHLine,$26,$80,100,63
    ; .byte tHLine,$27,$00,100,63
    ; .byte tHLine,$27,$80,100,63
    ; .byte tHLine,$28,$00,100,63
    ; .byte tHLine,$28,$80,100,63
    ; .byte tHLine,$29,$00,100,63
    ; .byte tHLine,$29,$80,100,63
    ; .byte tHLine,$2A,$00,100,63
    ; .byte tHLine,$2A,$80,100,63
    ; .byte tHLine,$2B,$00,100,63
    ; .byte tHLine,$2B,$80,100,63
    ; .byte tHLine,$2C,$00,100,63
    ; .byte tHLine,$2C,$80,100,63
    ; .byte tHLine,$2D,$00,100,63
    ; .byte tHLine,$2D,$80,100,63
    ; .byte tHLine,$2E,$00,100,63
    ; .byte tHLine,$2E,$80,100,63
    ; .byte tHLine,$2F,$00,100,63
    ; .byte tHLine,$2F,$80,100,63
    ; .byte tHLine,$30,$00,100,63
    ; .byte tHLine,$30,$80,100,63
    ; .byte tHLine,$31,$00,100,63
    ; .byte tHLine,$31,$80,100,63
    ; .byte tHLine,$32,$00,100,63
    ; .byte tHLine,$32,$80,100,63
    ; .byte tHLine,$33,$00,100,63
    ; .byte tHLine,$33,$80,100,63
    ; .byte tHLine,$34,$00,100,63
    ; .byte tHLine,$34,$80,100,63
    ; .byte tHLine,$35,$00,100,63
    ; .byte tHLine,$35,$80,100,63
    ; .byte tHLine,$36,$00,100,63
    ; .byte tHLine,$36,$80,100,63
    ; .byte tHLine,$37,$00,100,63
    ; .byte tHLine,$37,$80,100,63
    ; .byte tHLine,$38,$00,100,63
    ; .byte tHLine,$38,$80,100,63
    ; .byte tHLine,$39,$00,100,63
    ; .byte tHLine,$39,$80,100,63
    ; .byte tHLine,$3A,$00,100,63
    ; .byte tHLine,$3A,$80,100,63
    ; .byte tHLine,$3B,$00,100,63
    ; .byte tHLine,$3B,$80,100,63
    ; .byte tHLine,$3C,$00,100,63
    ; .byte tHLine,$3C,$80,100,63
    ; .byte tHLine,$3D,$00,100,63
    ; .byte tHLine,$3D,$80,100,63
    ; .byte tHLine,$3E,$00,100,63
    ; .byte tHLine,$3E,$80,100,63
    ; .byte tHLine,$3F,$00,100,63
    ; .byte tHLine,$3F,$80,100,63

 ; .byte tDelay,200
 ;  .byte tRestart

; ;  BALL ANIMATION

  .byte tShrink,$8A,$00,$23,$17,60,58, 1,1,tDelay,2
  .byte tShrink,$8A,$3A,$23,$17,60,58, 1,1,tDelay,2
  .byte tShrink,$A4,$FF,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$A5,$39,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$C1,$FF,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$C2,$3B,$23,$17,55,58, 1,1,tDelay,2

  .byte tShrink,$8A,$00,$23,$17,60,58, 1,1,tDelay,2
  .byte tShrink,$8A,$3A,$23,$17,60,58, 1,1,tDelay,2
  .byte tShrink,$A4,$FF,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$A5,$39,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$C1,$FF,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$C2,$3B,$23,$17,55,58, 1,1,tDelay,2

  .byte tShrink,$8A,$00,$23,$17,60,58, 1,1,tDelay,2
  .byte tShrink,$8A,$3A,$23,$17,60,58, 1,1,tDelay,2
  .byte tShrink,$A4,$FF,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$A5,$39,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$C1,$FF,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$C2,$3B,$23,$17,55,58, 1,1,tDelay,2
  
  .byte tShrink,$8A,$00,$23,$17,60,58, 1,1,tDelay,2
  .byte tShrink,$8A,$3A,$23,$17,60,58, 1,1,tDelay,2
  .byte tShrink,$A4,$FF,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$A5,$39,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$C1,$FF,$23,$17,55,58, 1,1,tDelay,2
  .byte tShrink,$C2,$3B,$23,$17,55,58, 1,1,tDelay,2
   
  
   .byte tShrink,$8A,$00,$23,$17,55,58, 1,1 ,tDelay,2
   .byte tShrink,$8A,$00,$23,$17,55,58, 2,2 ,tDelay,2
   .byte tShrink,$8A,$00,$23,$17,55,58, 3,3 ,tDelay,2
   .byte tShrink,$A5,$39,$23,$17,55,55, 7,4 ,tDelay,2
   .byte tShrink,$8A,$00,$23,$17,55,55, 9,5 ,tDelay,2
   .byte tShrink,$8A,$00,$23,$17,55,55, 11,6 ,tDelay,2
   .byte tShrink,$8A,$00,$23,$17,55,55, 12,7 ,tDelay,2
   .byte tZoom,$8A,$00,$23,$10,55,59,  100,51,tDelay,2
   .byte tZoom,$A5,$39,$23,$13,55,59,   30,16,tDelay,2
   .byte tZoom,$A5,$39,$22,$11,55,59,   11, 6,tDelay,2
    .byte tZoom,$A5,$39,$22,$09,55,59,   6,4,tDelay,2
   .byte tZoom,$A5,$39,$21,$8,55,59,   5,3,tDelay,2
    .byte tZoom,$A5,$39,$21,$7,55,59,   5,3,tDelay,1
    .byte tZoom,$A5,$39,$20,$4,55,59,   4,3,tDelay,1
  .byte tZoom,$A5,$39,$20,$3,55,59,   3,3,tDelay,1
  .byte tZoom,$A5,$39,$20,$2,55,59,   2,2,tDelay,1
  .byte tZoom,$A5,$39,$20,$0,55,59,   1,1,tDelay,1

   .byte tRestart 
  ; .byte  tRTS
; End Animation

NextHLineRH:
  CLC
  LDA RScreen
  ADC #$80
  ;STA Screen
  STA RScreen 
  LDA RScreenH
  ADC #$00
  STA RScreenH
  RTS

NextHLine:
  CLC
  LDA Screen
  ADC #$80
  STA Screen
  ;STA ScreenH ;?
  LDA ScreenH
  ADC #$00
  STA ScreenH
  RTS

LastHLine:
  SEC
  ;LDA Screen
  LDA RScreenUp
  SBC #$80
  STA Screen
  STA RScreenUp
  ;STA RScreenH
  ;LDA ScreenH
  LDA RScreenHUp
  SBC #$00
  STA ScreenH
  STA RScreenHUp
  RTS


; Unrolled and made seperate Up and Down routines.
; This saves 1 background color line draw on the leading edge.
; That is 819 cycles saved. This got rid of visable tearing when the 
; Raster was near the top of the screen. 
; I could save space and make this 1 routine and 
; shift where the colors are loaded. That probably makes sense?

HBarUp:
  LDA RScreenH
  STA ScreenH
  LDA RScreen
  STA Screen
HBarRenderUp:  
  ; LDA RColor5;#0 ;color
  ; LDY #99 ;$51 ;len 
  ; JSR HLine
  ;JSR NextHLine
  LDA $50 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $51 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $52 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $53 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $52 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $51 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $50 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine  
  LDA RColor5;#0 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
 RTS

HBarDown:
  LDA RScreenH
  STA ScreenH
  LDA RScreen
  STA Screen


HBarRenderDown:  
  LDA RColor5;#0 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $50 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $51 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $52 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $53 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $52 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $51 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine
  LDA $50 ;color
  LDY #99 ;$51 ;len 
  JSR HLine
  JSR NextHLine  
  ; LDA RColor5;#0 ;color
  ; LDY #99 ;$51 ;len 
  ; JSR HLine
  ;JSR NextHLine
 RTS



HLine: ;829 cycles for full line with bounds check
 LDY #$3F      ; This is the last line of screen RAM
 CPY ScreenH   ; If I check I can draw off the bottom of the screen
 BCS HLineInRam; Save a few cycles per line if needed? 
HLineRTS:
 ; Let's get fancy....
 ; When we draw off screen we will still take time
 ; That way we can have smooth movement without a 
 ; Vsync or other delay.
 LDY HBarOffScreenDelay;#163 matches the 829 cycles, but use
 JMP DelayTinY ;RTS from that
 ;RTS
HLineInRam:
 LDY ScreenH ; Now check that it is not below
 CPY #$20    ; The Screen area
 BCC HLineRTS; Dump out if it is.
HLineNoBounds: ; Don't check anything
 LDY #0
RLERender:  ; Fully unrolled Line draw/Run Length Routine. From the BenEaterBadApple decoder
; Yes, a Macro would be good here
; I'm keeping it 'raw' assembly for clarity.
; This is 8.2 cycles a pixel vrs 13.3 for a loop
; More than 60% faster. Nice!
; Jump to the len that you need, or do the whole screen width.
  sta (Screen),y; Draw it! 100
  iny ; Next pixel
  sta (Screen),y; Draw it! 99
  iny ; Next pixel
  sta (Screen),y; Draw it! 98
  iny ; Next pixel
  sta (Screen),y; Draw it! 97
  iny ; Next pixel
 sta (Screen),y; Draw it! 96
  iny ; Next pixel
  sta (Screen),y; Draw it! 95
  iny ; Next pixel
  sta (Screen),y; Draw it! 94
  iny ; Next pixel
  sta (Screen),y; Draw it! 93
  iny ; Next pixel
  sta (Screen),y; Draw it! 92
  iny ; Next pixel
  sta (Screen),y; Draw it! 91
  iny ; Next pixel
  sta (Screen),y; Draw it! 90
  iny ; Next pixel
  sta (Screen),y; Draw it! 89
  iny ; Next pixel
  sta (Screen),y; Draw it! 88
  iny ; Next pixel
  sta (Screen),y; Draw it! 87
  iny ; Next pixel
  sta (Screen),y; Draw it! 86
  iny ; Next pixel
  sta (Screen),y; Draw it! 85
  iny ; Next pixel
  sta (Screen),y; Draw it! 84
  iny ; Next pixel
  sta (Screen),y; Draw it! 83
  iny ; Next pixel
  sta (Screen),y; Draw it! 82
  iny ; Next pixel
  sta (Screen),y; Draw it! 81
  iny ; Next pixel
 
 sta (Screen),y; Draw it! 80
  iny ; Next pixel
  sta (Screen),y; Draw it! 79
  iny ; Next pixel
  sta (Screen),y; Draw it! 78
  iny ; Next pixel
  sta (Screen),y; Draw it! 77
  iny ; Next pixel
  sta (Screen),y; Draw it! 76
  iny ; Next pixel
  sta (Screen),y; Draw it! 75
  iny ; Next pixel
  sta (Screen),y; Draw it! 74
  iny ; Next pixel
  sta (Screen),y; Draw it! 73
  iny ; Next pixel
  sta (Screen),y; Draw it! 72
  iny ; Next pixel
  sta (Screen),y; Draw it! 71
  iny ; Next pixel
  sta (Screen),y; Draw it! 70
  iny ; Next pixel
  sta (Screen),y; Draw it! 69
  iny ; Next pixel
  sta (Screen),y; Draw it! 68
  iny ; Next pixel
  sta (Screen),y; Draw it! 67
  iny ; Next pixel
  sta (Screen),y; Draw it! 66
  iny ; Next pixel
  sta (Screen),y; Draw it! 65
  iny ; Next pixel
; 64
 sta (Screen),y; Draw it! 64
  iny ; Next pixel
 sta (Screen),y; Draw it! 63
  iny ; Next pixel
  sta (Screen),y; Draw it! 62
  iny ; Next pixel
  sta (Screen),y; Draw it! 61
  iny ; Next pixel
  sta (Screen),y; Draw it! 60
  iny ; Next pixel
  sta (Screen),y; Draw it! 59
  iny ; Next pixel 
  sta (Screen),y; Draw it! 58
  iny ; Next pixel
  sta (Screen),y; Draw it! 57
  iny ; Next pixel
  sta (Screen),y; Draw it! 56
  iny ; Next pixel
  sta (Screen),y; Draw it! 55
  iny ; Next pixel
  sta (Screen),y; Draw it! 54
  iny ; Next pixel
  sta (Screen),y; Draw it! 53
  iny ; Next pixel
  sta (Screen),y; Draw it! 52
  iny ; Next pixel
  sta (Screen),y; Draw it! 51
  iny ; Next pixel
  sta (Screen),y; Draw it! 50
  iny ; Next pixel
  sta (Screen),y; Draw it! 49
  iny ; Next pixel
 
 sta (Screen),y; Draw it! 48
  iny ; Next pixel
  sta (Screen),y; Draw it! 47
  iny ; Next pixel
  sta (Screen),y; Draw it! 46
  iny ; Next pixel
  sta (Screen),y; Draw it! 45
  iny ; Next pixel
  sta (Screen),y; Draw it! 44
  iny ; Next pixel
  sta (Screen),y; Draw it! 43
  iny ; Next pixel
  sta (Screen),y; Draw it! 42
  iny ; Next pixel
  sta (Screen),y; Draw it! 41
  iny ; Next pixel
  sta (Screen),y; Draw it! 40
  iny ; Next pixel
  sta (Screen),y; Draw it! 39
  iny ; Next pixel
  sta (Screen),y; Draw it! 38
  iny ; Next pixel
  sta (Screen),y; Draw it! 37
  iny ; Next pixel
  sta (Screen),y; Draw it! 36
  iny ; Next pixel
  sta (Screen),y; Draw it! 35
  iny ; Next pixel
  sta (Screen),y; Draw it! 34
  iny ; Next pixel
  sta (Screen),y; Draw it! 33
  iny ; Next pixel
  
 sta (Screen),y; Draw it! 32
  iny ; Next pixel
  sta (Screen),y; Draw it! 31
  iny ; Next pixel
  sta (Screen),y; Draw it! 30
  iny ; Next pixel
  sta (Screen),y; Draw it! 29
  iny ; Next pixel
  sta (Screen),y; Draw it! 28
  iny ; Next pixel
  sta (Screen),y; Draw it! 27
  iny ; Next pixel
  sta (Screen),y; Draw it! 26
  iny ; Next pixel
  sta (Screen),y; Draw it! 25
  iny ; Next pixel
  sta (Screen),y; Draw it! 24
  iny ; Next pixel
  sta (Screen),y; Draw it! 23
  iny ; Next pixel
  sta (Screen),y; Draw it! 22
  iny ; Next pixel
  sta (Screen),y; Draw it! 21
  iny ; Next pixel
  sta (Screen),y; Draw it! 20
  iny ; Next pixel
  sta (Screen),y; Draw it! 19
  iny ; Next pixel
  sta (Screen),y; Draw it! 18
  iny ; Next pixel
  sta (Screen),y; Draw it! 17
  iny ; Next pixel
 
 sta (Screen),y; Draw it! 16
  iny ; Next pixel
  sta (Screen),y; Draw it! 15
  iny ; Next pixel
  sta (Screen),y; Draw it! 14
  iny ; Next pixel
  sta (Screen),y; Draw it! 13
  iny ; Next pixel
  sta (Screen),y; Draw it! 12
  iny ; Next pixel
  sta (Screen),y; Draw it! 11
  iny ; Next pixel
  sta (Screen),y; Draw it! 10
  iny ; Next pixel
  sta (Screen),y; Draw it! 9
  iny ; Next pixel
  sta (Screen),y; Draw it! 8
  iny ; Next pixel
  sta (Screen),y; Draw it! 7
  iny ; Next pixel
  sta (Screen),y; Draw it! 6
  iny ; Next pixel
  sta (Screen),y; Draw it! 5
  iny ; Next pixel
  sta (Screen),y; Draw it! 4
  iny ; Next pixel
  sta (Screen),y; Draw it! 3
  iny ; Next pixel
  sta (Screen),y; Draw it! 2
  iny ; Next pixel
  sta (Screen),y; Draw it! 1
  iny ; Next pixel
HLineRTSEnd:  
  RTS

 ;jmp .FrameLoop ; Decode another byte

; ==
VStripDraw:
 ; Carry Bar up
 LDA Screen
 PHA 
 LDA ScreenH
 PHA
 PHX
 PHY
 PHP
   LDA DelayCount
   PHA ;DelayCount

   LDA #0 ;#30
   STA DelayCount
   
   jsr Delay

   lda VStripScreenH
   STA ScreenH
   lda VStripScreen
   STA Screen
   

   LDA ScreenH
   CLC
   ADC #4
   STA ScreenH
   CLC
   LDA Screen
   ADC #$80
   STA Screen
   LDA ScreenH
   ADC #$0
   STA ScreenH



  ;  LDA ScreenH
  ;  CLC
  ;  ADC #4
  ;  STA ScreenH
  ;  CLC
  ;  LDA Screen
  ;  ADC #$80
  ;  STA Screen
  ;  LDA ScreenH
  ;  ADC #$0
  ;  STA ScreenH
 jsr Delay
  ;OffScreen, don't draw? 
   ; Bar 1
    SEC
    LDA TmpV
    SBC #10
    STA RVScreen
    STA Screen
    ;LDA RVScreenH
    ;STA ScreenH
    LDY RasterTmpT
    jsr RasterLoad 
    JSR VStrip
     jsr Delay
; Bar 2
    SEC
    LDA RVScreenX
    SBC #10 ;Deal with offset later
    STA RVScreen
    STA Screen
    LDY RasterTmpV
    jsr RasterLoad
    JSR VStrip
  jsr Delay
 ; Bar 3
    LDY VSineX
    DEY ;Want Current position
    LDA Sine,Y
    CLC
    ADC #8;#17 ;Center it ;SEC #14 ;Deal with offset later
    STA RVScreen
    STA Screen
    LDY RasterTmpS
    jsr RasterLoad
    JSR VStrip
 jsr Delay
    CLC
    LDA #10
    ADC RVScreen
    STA RVScreen
    STA Screen
    JSR VStrip

  jsr Delay
   ;LDA #1
   ;LDA DelayCount
   PLA ;DelayCount
   STA DelayCount

 PLP
 PLY
 PLX   
 PLA 
 STA ScreenH
 PLA 
 STA Screen
 RTS

VStrip:
;VBarRender: 
 PHX  ;?? needed ??
 PHY
 LDX RColor5 ;1 Store edge in X

 LDY #$0 ; No y offset allowed with unrolled routine
;VBar64:
 TXA ;Edge Color
 CLC
 sta (Screen),y; Draw it! 64
 INY ; Move over pixel
 LDA RColor1 ;2
 sta (Screen),y; Draw it! 
 INY 
 LDA RColor2 ;3
 sta (Screen),y; Draw it! 
 INY 
 LDA RColor3 ;4
 sta (Screen),y; Draw it! 
 INY 
 LDA RColor4 ;5
 sta (Screen),y; Draw it! 
 INY 
 LDA RColor3 ;6
 sta (Screen),y; Draw it! 
 INY 
 LDA RColor2 ;7
 sta (Screen),y; Draw it! 
 INY 
 LDA RColor1 ; 8
 sta (Screen),y; Draw it! 
 INY 
 TXA ;LDA RColor5 ; 9 Use this color for next two pixels
 sta (Screen),y; Draw it! 
 
 
 DEC ScreenH
 ldy #$80 ;Move <UP> a row?
;  SEC
;  lda Screen
;  SBC #$80
;  STA Screen
;  LDA ScreenH
;  SBC #$0
;  STA ScreenH
;  CLC

 

;VBar63:
 sta (Screen),y; Draw it! Next Line Pixel 1
 ; Unrolled........... x 64 times total
  INY
  LDA RColor1 ;2
  sta (Screen),y; Draw it! 
  INY
  LDA RColor2 ;3
  sta (Screen),y; Draw it! 
  INY
  LDA RColor3 ;4
  sta (Screen),y; Draw it! 
  INY
  LDA RColor4;5
  sta (Screen),y; Draw it! 
  INY
  LDA RColor3;6
  sta (Screen),y; Draw it! 
  INY
  LDA RColor2;7
  sta (Screen),y; Draw it! 
  INY
  LDA RColor1;8
  sta (Screen),y; Draw it! 
  INY
  TXA ; LDA RColor5;9
  sta (Screen),y; Draw it! 
  
  inc ScreenH
 
 PLY
 PLX
 RTS



;Text Routines

DrawTxtLine:
RESET:
BigTop: 

; LDA #5
; JSR FillScreen

 ;LDA #$30
 LDA ScreenH
 STA TextLocH
 ;LDA #0
 LDA Screen
 STA TextLoc
 ;STA Screen
 STA TextScroll

 LDA #0
 LDY #0 
 LDA #0
 LDX #0

ScrollLoop:
 JSR DrawMSG
 
 LDA TextScroll
 DEA
 ;BNE ScrollDec ;Works but skips down a line
 ;LDA #128
 ;LDA Screen
 ;SBC #$80
 ;STA Screen
ScrollDec:
 STA TextScroll
 STA TextLoc
 STA Screen

 LDA #1
 STA DelayCount
 JSR Delay
 LDA #0
 
 
 ;jmp ScrollLoop
 RTS
 ;jmp BigTop
 

MyMSG:
; .byte "1111",0
;  .byte " TEST-$@%&",0
  ;.byte "- 1 2 3 4 5 6 7";,0
  ;.byte "1234567890!?*@#";,0
  .byte " HELLO RASTERS! " ,0
  ;.byte "JMP (TJMPTBL, X)",0
  
 ;
  ;.byte "NORMALLUSER'S PC",0
  ; .byte "RASTER LINE TEST",0
 
 ; .byte " NORMALLUSER'S PC " ,0
  ;.byte " -RASTER LINE TEST- ",0
  ;.byte " !#$%&;()*+-/.<>? ",0
  ;.byte "1234567890!%#$%(",0
  ;.byte " 123",0


DrawMSG:

 LDA TextLocH
 STA ScreenH; This starts at location $2000
 LDA TextLoc
 STA Screen
 STA TextLocTemp
 
 ;LDY #0
 STZ MyMsgY
DrawMSGNextChar: ;861-909 cycles a char. 1492 0rg. 17.93 to  18.93 cycles a pixel, 
 ;PLY ;17,013 full text, 26,201 org  for  .byte "RASTER LINE TEST- ",0
 ; 16958... 16,762.. 16,474!  16,385!!...... 16,330!! 
 ; OK, down to ///16,078\\\ .. \\\16,024/// .. 
 ; !!! 15,948 !!! 10k + less cycles! 14,094 if I dont do bottom row
 
 LDY MyMsgY
 LDA MyMSG,y ;  
 BEQ DrawMSGDone
 iny
 sty MyMsgY
 CLC ;Not needed?
 ROL
 TAY
 LDA ASCIITbl,y
 STA MsgPointer
 INY
 LDA ASCIITbl,y
 STA MsgPointerH

 LDY #0
 LDX #8 ; Change to 7 from 8 to skip bottom row
 STX DrawMSGLoopCount
DrawMSGLoop:  
 LDA (MsgPointer),y
 INY
 STY MsgPointerY
 TAX
 LDY #0
 jmp (TJmpTbl, x) ;  JSR DrawByteSix
TJmpTblReturn: 
 LDX DrawMSGLoopCount
 DEX
 BEQ DrawMSGLoopDone
 STX DrawMSGLoopCount
 CLC ;Not needed for blind 16 bit ADC?
 LDA Screen
 ADC #$80
 STA Screen
 LDA ScreenH
 ADC #$00
 STA ScreenH
 ;BCC NoHInc ;with CLC above slows it down
 ;inc ScreenH 
NoHInc: 
 LDY MsgPointerY
 JMP DrawMSGLoop
DrawMSGLoopDone:

 LDA TextLocH
 STA ScreenH; This starts at location $2000
 LDA TextLocTemp
 ADC #6;#8
 STA TextLocTemp;Screen
 STA Screen

 JMP DrawMSGNextChar
DrawMSGDone:
  ;BRK 
  RTS
 



; MyMSG:
;  ;.byte " TEST",0
;ASCIITblorg = $400+64 ; Use this for ASCII lookup so you don't have to add. Allows CAP LETTERS, numeric and ?<> etc.
;ASCIITbl = ASCIITblorg-64 ; This is a 64 byte offset. IE 32x2 for the tbl. 
;  .org ASCIITblorg        ; Now we can directly use the ASCII code doubled to lookup the char data location.
ASCIITblStart: ;.byte "start"
ASCIITbl = ASCIITblStart -64;.byte "start"-64 ; This is a 64 byte offset. IE 32x2 for the tbl. 
   ;Need to pad 64 bytes for the 32 ASCII control chars so I don't have to subtract 32 from everything?
   .word cSPACE,cEx,cQuote,cHash,cDollar,cPercent,cAnd,cApost,cLeftParen,cRightParen
   .word cStar,cPlus,cComma,cMin,cPeriod,cSlash,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9
   .word cColon,cSimi,cLess,cEqual,cMore,cQuest,cAt,cA,cB,cC,cD,cE,cF,cG,cH,cI
   .word cJ,cK,cL,cM,cN,cO,cP,cQ,cR,cS,cT,cU,cV,cW,cX,cY,cZ

 ;.org $500
 ;.byte "Chars"
 ; 472 bytes. Started as 59 8 byte char maps. 6 bits wide, 16 bits wasted per char.
 ; Bitpattern replaced with line routine jump calls.
 ; Orgional patterns and starting code from 
 ; https://github.com/rehsd/VGA-6502/blob/main/6502%20Assembly/vga-text-3.s
 ; That org version works well and uses little space.
 ; These Unrolled draw routines are 66% faster.
 ; Setup is meant to allow fast drawing for 1 pixel line of 17 chars
 ; to follow the scanline and allow for effects, as well as 1 single char
 ; Values chabged from bitmap to jmp routine call
 
; .org 9000

cSPACE:   ; ascii:0x20      charmap_location:0x00
          .byte 0
          .byte 0
          .byte 0
          .byte 0
          .byte 0
          .byte 0
          .byte 0
          .byte 0
cEx:   ;!     ascii:0x21      charmap_location:0x08 (increase by 8 bits/rows per char)
          .byte 8
          .byte 8
          .byte 8
          .byte 8
          .byte 8
          .byte 0
          .byte 8
          .byte 0
cQuote:   ;''     ascii:0x22      charmap_location:0x10
          .byte 20
          .byte 20
          .byte 20
          .byte 0
          .byte 0
          .byte 0
          .byte 0
          .byte 0
cHash:   ;#     ascii:0x23      charmap_location:0x18
          .byte 20
          .byte 20
          .byte 50
          .byte 20
          .byte 50
          .byte 20
          .byte 20
          .byte 0
cDollar:   ;$     ascii:0x24      charmap_location:0x20
          .byte 8
          .byte 28
          .byte 38
          .byte 26
          .byte 10
          .byte 48
          .byte 8
          .byte 0
cPercent:   ;%     ascii:0x25      charmap_location:0x28
          .byte 42
          .byte 44
          .byte 4
          .byte 8
          .byte 16
          .byte 36
          .byte 6
          .byte 0
cAnd:   ;&     ascii:0x26      charmap_location:0x30
          .byte 22
          .byte 34
          .byte 38
          .byte 16
          .byte 40
          .byte 34
          .byte 24
          .byte 0
cApost:   ;''     ascii:0x27      charmap_location:0x38
          .byte 8
          .byte 8
          .byte 0
          .byte 0
          .byte 0
          .byte 0
          .byte 0
          .byte 0
cLeftParen:   ;(     ascii:0x28      charmap_location:0x40
          .byte 4
          .byte 8
          .byte 16
          .byte 16
          .byte 16
          .byte 8
          .byte 4
          .byte 0
cRightParen:   ;)     ascii:0x29      charmap_location:0x48
          .byte 16
          .byte 8
          .byte 4
          .byte 4
          .byte 4
          .byte 8
          .byte 16
          .byte 0
cStar:   ;*     ascii:0x2A      charmap_location:0x50
          .byte 0
          .byte 8
          .byte 40
          .byte 26
          .byte 40
          .byte 8
          .byte 0
          .byte 0
cPlus:   ;+     ascii:0x2B      charmap_location:0x58
          .byte 0
          .byte 8
          .byte 8
          .byte 50
          .byte 8
          .byte 8
          .byte 0
          .byte 0
cComma:   ;,     ascii:0x2C      charmap_location:0x60
          .byte 0
          .byte 0
          .byte 0
          .byte 0
          .byte 12
          .byte 4
          .byte 8
          .byte 0
cMin:   ;-     ascii:0x2D      charmap_location:0x68
          .byte 0
          .byte 0
          .byte 0
          .byte 50
          .byte 0
          .byte 0
          .byte 0
          .byte 0
cPeriod:   ;.     ascii:0x2E      charmap_location:0x70
          .byte 0
          .byte 0
          .byte 0
          .byte 0
          .byte 0
          .byte 22
          .byte 22
          .byte 0
cSlash:   ;/     ascii:0x2F      charmap_location:0x78
          .byte 0
          .byte 2
          .byte 4
          .byte 8
          .byte 16
          .byte 30
          .byte 0
          .byte 0
c0:   ;     ascii:0x30      charmap_location:0x80
          .byte 26
          .byte 32
          .byte 36
          .byte 40
          .byte 44
          .byte 32
          .byte 26
          .byte 0
c1:   ;     ascii:0x31      charmap_location:0x88
          .byte 8
          .byte 22
          .byte 8
          .byte 8
          .byte 8
          .byte 8
          .byte 26
          .byte 0
c2:   ;     ascii:0x32      charmap_location:0x90
          .byte 26
          .byte 32
          .byte 2
          .byte 12
          .byte 16
          .byte 30
          .byte 50
          .byte 0
c3:   ;     ascii:0x33      charmap_location:0x98
          .byte 26
          .byte 32
          .byte 2
          .byte 12
          .byte 2
          .byte 32
          .byte 26
          .byte 0
c4:   ;     ascii:0x34      charmap_location:0xA0
          .byte 4
          .byte 12
          .byte 20
          .byte 34
          .byte 50
          .byte 4
          .byte 4
          .byte 0
c5:   ;     ascii:0x35      charmap_location:0xA8
          .byte 50
          .byte 30
          .byte 48
          .byte 2
          .byte 2
          .byte 32
          .byte 26
          .byte 0
c6:   ;     ascii:0x36      charmap_location:0xB0
          .byte 12
          .byte 16
          .byte 30
          .byte 48
          .byte 32
          .byte 32
          .byte 26
          .byte 0
c7:   ;     ascii:0x37      charmap_location:0xB8
          .byte 50
          .byte 2
          .byte 4
          .byte 8
          .byte 16
          .byte 16
          .byte 16
          .byte 0
c8:   ;     ascii:0x38      charmap_location:0xC0
         .byte 26
         .byte 32
         .byte 32
         .byte 26
         .byte 32
         .byte 32
         .byte 26
         .byte 0
c9:   ;     ascii:0x39      charmap_location:0xC8
          .byte 26
          .byte 32
          .byte 32
          .byte 28
          .byte 2
          .byte 4
          .byte 22
          .byte 0
cColon:   ;':'     ascii:0x3A      charmap_location:0xD0
          .byte 0
          .byte 22
          .byte 22
          .byte 0
          .byte 22
          .byte 22
          .byte 0
          .byte 0
cSimi:   ;;     ascii:0x3B      charmap_location:0xD8
          .byte 0
          .byte 22
          .byte 22
          .byte 0
          .byte 22
          .byte 8
          .byte 16
          .byte 0
cLess:   ;<     ascii:0x3C      charmap_location:0xE0
          .byte 4
          .byte 8
          .byte 16
          .byte 30
          .byte 16
          .byte 8
          .byte 4
          .byte 0
cEqual:   ;=     ascii:0x3D      charmap_location:0xE8
          .byte 0
          .byte 0
          .byte 50
          .byte 0
          .byte 50
          .byte 0
          .byte 0
          .byte 0
cMore:   ;>     ascii:0x3E      charmap_location:0xF0
          .byte 16
          .byte 8
          .byte 4
          .byte 2
          .byte 4
          .byte 8
          .byte 16
          .byte 0
cQuest:   ;?     ascii:0x3F      charmap_location:0xF8
          .byte 26
          .byte 32
          .byte 2
          .byte 4
          .byte 8
          .byte 0
          .byte 8
          .byte 0

;  .org $f200    ; 7200 in ROM binary file
; charmap2:   ;ASCII 0x40 to 0x5F
cAt:   ;'%'     ascii:0x40      charmap_location:0x00
      .byte 26
      .byte 32
      .byte 2
      .byte 24
      .byte 40
      .byte 40
      .byte 26
      .byte 0
cA:   ;     ascii:0x41      charmap_location:0x08
      .byte 8
      .byte 20
      .byte 32
      .byte 32
      .byte 50
      .byte 32
      .byte 32
      .byte 0
cB:   ;     ascii:0x42      charmap_location:0x10
      .byte 48
      .byte 18
      .byte 18
      .byte 26
      .byte 18
      .byte 18
      .byte 48
      .byte 0
cC:   ;     ascii:0x43      charmap_location:0x18
      .byte 26
      .byte 32
      .byte 30
      .byte 30
      .byte 30
      .byte 32
      .byte 26
      .byte 0
cD:   ;     ascii:0x44      charmap_location:0x20
      .byte 48
      .byte 18
      .byte 18
      .byte 18
      .byte 18
      .byte 18
      .byte 48
      .byte 0
cE:   ;     ascii:0x45      charmap_location:0x28
      .byte 50
      .byte 30
      .byte 30
      .byte 48
      .byte 30
      .byte 30
      .byte 50
      .byte 0
cF:   ;     ascii:0x46      charmap_location:0x30
      .byte 50
      .byte 30
      .byte 30
      .byte 48
      .byte 30
      .byte 30
      .byte 30
      .byte 0
cG:   ;     ascii:0x47      charmap_location:0x38
      .byte 26
      .byte 32
      .byte 30
      .byte 36
      .byte 32
      .byte 32
      .byte 28
      .byte 0
cH:   ;     ascii:0x48      charmap_location:0x40
      .byte 32
      .byte 32
      .byte 32
      .byte 50
      .byte 32
      .byte 32
      .byte 32
      .byte 0
cI:   ;     ascii:0x49      charmap_location:0x48
      .byte 26
      .byte 8
      .byte 8
      .byte 8
      .byte 8
      .byte 8
      .byte 26
      .byte 0
cJ:   ;     ascii:0x4A      charmap_location:0x50
      .byte 14
      .byte 4
      .byte 4
      .byte 4
      .byte 4
      .byte 34
      .byte 22
      .byte 0
cK:   ;     ascii:0x4B      charmap_location:0x58
      .byte 32
      .byte 34
      .byte 38
      .byte 42
      .byte 38
      .byte 34
      .byte 32
      .byte 0
cL:   ;     ascii:0x4C      charmap_location:0x60
      .byte 30
      .byte 30
      .byte 30
      .byte 30
      .byte 30
      .byte 30
      .byte 50
      .byte 0
cM:   ;     ascii:0x4D      charmap_location:0x68
      .byte 32
      .byte 46
      .byte 40
      .byte 40
      .byte 32
      .byte 32
      .byte 32
      .byte 0
cN:   ;     ascii:0x4E      charmap_location:0x70
      .byte 32
      .byte 32
      .byte 44
      .byte 40
      .byte 36
      .byte 32
      .byte 32
      .byte 0
cO:   ;     ascii:0x4F      charmap_location:0x78
      .byte 26
      .byte 32
      .byte 32
      .byte 32
      .byte 32
      .byte 32
      .byte 26
      .byte 0
cP:   ;     ascii:0x50      charmap_location:0x80
      .byte 48
      .byte 32
      .byte 32
      .byte 48
      .byte 30
      .byte 30
      .byte 30
      .byte 0
cQ:   ;     ascii:0x51      charmap_location:0x88
      .byte 26
      .byte 32
      .byte 32
      .byte 32
      .byte 40
      .byte 34
      .byte 24
      .byte 0
cR:   ;     ascii:0x52      charmap_location:0x90
      .byte 48
      .byte 32
      .byte 32
      .byte 48
      .byte 38
      .byte 34
      .byte 32
      .byte 0
cS:   ;     ascii:0x53     charmap_location:0x98
      .byte 26
      .byte 32
      .byte 30
      .byte 26
      .byte 2
      .byte 32
      .byte 26
      .byte 0
cT:   ;     ascii:0x54      charmap_location:0xA0
      .byte 50
      .byte 8
      .byte 8
      .byte 8
      .byte 8
      .byte 8
      .byte 8
      .byte 0
cU:   ;     ascii:0x55      charmap_location:0xA8
      .byte 32
      .byte 32
      .byte 32
      .byte 32
      .byte 32
      .byte 32
      .byte 26
      .byte 0
cV:   ;     ascii:0x56      charmap_location:0xB0
      .byte 32
      .byte 32
      .byte 32
      .byte 32
      .byte 32
      .byte 20
      .byte 8
      .byte 0
cW:   ;     ascii:0x57      charmap_location:0xB8
      .byte 32
      .byte 32
      .byte 32
      .byte 40
      .byte 40
      .byte 40
      .byte 20
      .byte 0
cX:   ;     ascii:0x58      charmap_location:0xC0
      .byte 32
      .byte 32
      .byte 20
      .byte 8
      .byte 20
      .byte 32
      .byte 32
      .byte 0
cY:   ;     ascii:0x59      charmap_location:0xC8
      .byte 32
      .byte 32
      .byte 20
      .byte 8
      .byte 8
      .byte 8
      .byte 8
      .byte 0
cZ:   ;     ascii:0x5A      charmap_location:0xD0
      .byte 50
      .byte 2
      .byte 4
      .byte 8
      .byte 16
      .byte 30
      .byte 50
      .byte 0


; .org $A000

; NormalLuser unRolled Char line draw routines.
; 26 line patterns used. A lot better 
; than 256!
; 825 bytes on top of the 472 byte charmap jump index tbl.
; 1,297 bytes of data for txt. 
TJmpTbl: ; 26 line draw routines for the 59 Chars included
 .word T00,T08,T10,T18,T20,T28,T30,T38,T40
 .word T48,T50,T60,T68,T70,T78,T80,T88,T90
 .word T98,TA0,TA8,TC0,TC8,TD8,TF0,TF8

T00: ; 00000000
  LDA #0
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 

T08: ; 00001000
 LDA #0
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
 lda #63
   STA (Screen),Y ; 5
   INY
 LDA #0
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 

T10:;   00010000
   LDA #0
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
 lda #63
   STA (Screen),Y ; 4
   INY
 LDA #0
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 

T18: ;	00011000
 LDA #0
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
 lda #63
   STA (Screen),Y ; 4
   INY
   STA (Screen),Y ; 5
   INY
 LDA #0
   STA (Screen),Y ; 6
   INY  
 JMP TJmpTblReturn 

T20: ;	00100000
 LDA #0
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
  lda #63
   STA (Screen),Y ; 3
   INY
 lda #0
   STA (Screen),Y ; 4
   INY
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
T28: ;	00101000
  LDA #0
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
 lda #63
   STA (Screen),Y ; 3
   INY
 LDA #0
   STA (Screen),Y ; 4
   INY
  lda #63
   STA (Screen),Y ; 5
   INY
 LDA #0
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 

T30: ;	00110000
 LDA #0
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
 lda #63
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
 LDA #0
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
T38: ;	00111000
 LDA #0
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
 lda #63
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
   STA (Screen),Y ; 5
   INY
 LDA #0  
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn  
T40: ;	01000000
 LDA #0
   STA (Screen),Y ; 1
   INY
  lda #63
   STA (Screen),Y ; 2
   INY
 LDA #0
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
T48: ;	01001000
  LDA #0
   STA (Screen),Y ; 1
   INY
 lda #63
   STA (Screen),Y ; 2
   INY
  lda #0
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   iny
 lda #63
   STA (Screen),Y ; 5
   INY
 LDA #0
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
T50: ;	01010000
  LDA #0
   STA (Screen),Y ; 1
   INY
 lda #63
   STA (Screen),Y ; 2
   INY
  lda #0
   STA (Screen),Y ; 3
   INY
 lda #63
   STA (Screen),Y ; 4
   iny
 LDA #0
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
T60: ;	01100000
 LDA #0
   STA (Screen),Y ; 1
   INY
  lda #63
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
 LDA #0
   STA (Screen),Y ; 4
   INY
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
T68: ;	01101000
  LDA #0
   STA (Screen),Y ; 1
   INY
 lda #63
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
 lda #0
   STA (Screen),Y ; 4
   iny
 lda #63
   STA (Screen),Y ; 5
   INY
 LDA #0
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
T70: ;	01110000
  LDA #0
   STA (Screen),Y ; 1
   INY
  lda #63
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
 LDA #0
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
T78: ;	01111000
  LDA #0
   STA (Screen),Y ; 1
   INY
  lda #63
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
   STA (Screen),Y ; 5
   INY
 LDA #0
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
T80: ;	10000000
 LDA #63
   STA (Screen),Y ; 1
   INY
  lda #0
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
T88: ;	10001000
  LDA #63
   STA (Screen),Y ; 1
   INY
 lda #0
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   iny
 lda #63
   STA (Screen),Y ; 5
   INY
 LDA #0
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 

T90: ;	10010000
  LDA #63
   STA (Screen),Y ; 1
   INY
 lda #0
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
 lda #63
   STA (Screen),Y ; 4
   iny
 LDA #0
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
T98: ;	10011000
  LDA #63
   STA (Screen),Y ; 1
   INY
 lda #0
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
 lda #63
   STA (Screen),Y ; 4
   iny
   STA (Screen),Y ; 5
   INY
 LDA #0
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
TA0: ;	10100000
  LDA #63
   STA (Screen),Y ; 1
   INY
 lda #0
   STA (Screen),Y ; 2
   INY
 lda #63
   STA (Screen),Y ; 3
   INY
 lda #0
   STA (Screen),Y ; 4
   iny
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
TA8: ;	10101000
  LDA #63
   STA (Screen),Y ; 1
   INY
 lda #0
   STA (Screen),Y ; 2
   INY
 lda #63
   STA (Screen),Y ; 3
   INY
 lda #0
   STA (Screen),Y ; 4
   iny
 lda #63   
   STA (Screen),Y ; 5
   INY
 lda #0
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
TC0: ;	11000000
 LDA #63
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
 lda #0
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 

TC8: ;	11001000
 LDA #63
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
 lda #0
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
 LDA #63
   STA (Screen),Y ; 5
   INY
 LDA #0
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 

TD8: ;	11011000
 LDA #63
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
 lda #0
   STA (Screen),Y ; 3
   INY
 LDA #63
   STA (Screen),Y ; 4
   INY
   STA (Screen),Y ; 5
   INY
 LDA #0
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 

TF0: ;	11110000
 LDA #63
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
 lda #0
   STA (Screen),Y ; 5
   INY
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 
TF8: ; 	11111000
 LDA #63
   STA (Screen),Y ; 1
   INY
   STA (Screen),Y ; 2
   INY
   STA (Screen),Y ; 3
   INY
   STA (Screen),Y ; 4
   INY
   STA (Screen),Y ; 5
   INY
 lda #0
   STA (Screen),Y ; 6
   ;INY
 JMP TJmpTblReturn 

;  Delay: ; NormalLuser VGA clock delay routine:
;   PHA           ; This results in 60 interrupts a second. IE on the V sync pulse.
;   ;LDA DelayCount; Replace with a couple of nested loops and some nop's if you don't have NMI vsync.
;   BEQ NoDelay   ; 0, No delay
;   STA VGAClock  ; Store the number of cycles we want to wait.
; DelayTop:    
;   LDA VGAClock  ; See if the Vsync NMI has counted down to 0.
;   BNE DelayTop  ; Keep waiting until 0/Vsync NMI triggered.
; NoDelay:
;   PLA
;  RTS            ; Finished countdown.

; DelaySmall: ; Delay in X, trashes Y
;   ;LDX #255
;   rts
;   LDY #255
; DelaySmallY:
;  rts
;   DEY
;   BNE DelaySmallY
;   DEX 
;   BNE DelaySmallY

;   RTS

; DelayTinY:
;  rts
;   DEY
;   BNE DelayTinY
;   RTS

; Delay: ; NormalLuser VGA clock delay routine:
;  rts
;   PHA           ; This results in 60 interrupts a second. IE on the V sync pulse.
;   PHY ; 7730 cycles delay instead of vsync.
;   PHX ; Much smoother/faster with just the 1 vysnc at the end
;   LDA DelayCount; Replace with a couple of nested loops and some nop's if you don't have NMI vsync.
;   BEQ NoDelay   ; 0, No delay
;   STA VGAClock  ; Store the number of cycles we want to wait.
; DelayTop:    
;     LDY #255
;     LDX #200
;     ;JSR DelayTinY
;     JSR DelaySmallY
;     CLC ; Could do something else here like txt or music?
;    DEC VGAClock 
;    LDA VGAClock  ; See if the Vsync NMI has counted down to 0.
;    BNE DelayTop  ; Keep waiting until 0/Vsync NMI triggered.

; NoDelay:
;     PLX
;     PLY
;   PLA
;  RTS            ; Finished countdown.





 ; .align 8 
RasterColors:
DBlue: 
 .byte $01,$02,$03,$0B,$00 ;0
Yellow: ; Washed out, reverse inside 2 colors
 ;.byte $28,$3C,$3E,$3F,$00
  .byte $28,$3C,$3F,$3E,$00 ;5
LBlue: ; Washed out, reverse inside 2 colors
 ;.byte $16,$17,$1F,$2F,$00
 .byte $16,$17,$2F,$1F,$00 ;10
Orange: 
 .byte $24,$34,$38,$3F,$00 ;15
Silver: ; Washed out, reverse inside 2 colors
 .byte $15,$2A,$3F,$3E,$00 ;20
Red:
 .byte $10,$20,$30,$3F,$00 ;25
Green: ; Use light yellow/grey for inside color instead of light Green.
 ;.byte $04,$08,$0C,$0D,$00
 .byte $04,$08,$0C,$3E,$00 ;30
 ;.byte $04,$08,$0C,$1D,$00
Blank:
 .byte 0,0,0,0,0 ;6
 ; .align 8 
Sine:
Sine_64:
 .byte 32,33,34,34,35,36,37,37,38,39,40,40,41,42,43,43,44,45,46,46,47,48,48,49,50,50,51,52,52,53,53,54,54,55,56,56,57,57,58,58,58,59,59,60,60,60,61,61,61,62,62,62,62,63,63,63,63,63,63,64,64,64,64,64,64,64,64,64,64,64,63,63,63,63,63,63,62,62,62,62,61,61,61,60,60,60,59,59,58,58,58,57,57,56,56,55,54,54,53,53,52,52,51,50,50,49,48,48,47,46,46,45,44,43,43,42,41,40,40,39,38,37,37,36,35,34,34,33,32,31,30,30,29,28,27,27,26,25,24,24,23,22,21,21,20,19,18,18,17,16,16,15,14,14,13,12,12,11,11,10,10,9,8,8,7,7,6,6,6,5,5,4,4,4,3,3,3,2,2,2,2,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,3,3,3,4,4,4,5,5,6,6,6,7,7,8,8,9,10,10,11,11,12,12,13,14,14,15,16,16,17,18,18,19,20,21,21,22,23,24,24,25,26,27,27,28,29,30,30,31
     
  ;.org $1000
  ; - Fast VLine routine -
  ; Fast, but not fast enough for a raster bar with 9 lines
  ; 691 cycles 10.79 cycles per pixel, 64 pixel tall screen
  ; For 9 lines that would be a bit over 6,219 cycles with jmp and rts.
  ; While we do have 23,333 cycles a frame, a large portion of the 
  ; processing is on the end of each raster. There are only
  ; 7,000 cycles in each frame during Vsync, and our Vync IRQ does
  ; not trigger at exactly the start of vsync, but a little after.
  ; This means that we have less than the 6,219 cycles it takes
  ; to draw 9 lines before the top row of pixels is displayed from
  ; RAM by the video card.
  ; In the real world that means the the first several pixels on the
  ; right side of each raster bar would be glitched while moving/changing color.
  ; I could use less lines in the bars, but instead I wrote a unrolled routine
  ; that draws with the VGA scanlines. Problem solved!
  ; VLine: ;Color A, RVScreen location, y offset
  
  ;  ;STA TmpA
  ;  LDY RVScreenH
  ;  STY ScreenH
  ;  LDY RVScreen
  ;  STY Screen
  ;  LDY #0
  ; VLineRender: ;
  ;  sta (Screen),y; Draw it! 64
  ;  ldy #$80
  ;  sta (Screen),y; Draw it! 63
    
  ;  inc ScreenH
  ;  ldy #$00
  ;  sta (Screen),y; Draw it! 62
  ;  ldy #$80
  ;  sta (Screen),y; Draw it! 61
  ;  ; Unrolled x64....... 
  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 60
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 59

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 58
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 57

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 56
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 55

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 54
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 53

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 52
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 51

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 50
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 49

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 48
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 47
    
  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 46
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 45
    
  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 44
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 43
    
  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 42
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 41
    
  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 40
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 39

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 38
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 37


  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 36
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 35

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 34
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 33

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 32
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 31

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 30
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 29

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 28
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 27

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 26
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 25
  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 24
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 23
  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 22
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 21
  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 20
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 19
  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 18
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 17

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 16
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 15

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 14
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 13

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 12
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 11

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 10
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 9

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 8
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 7

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 6
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 5

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 4
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 3

  ;   inc ScreenH
  ;   ldy #$00
  ;   sta (Screen),y; Draw it! 2
  ;   ldy #$80
  ;   sta (Screen),y; Draw it! 1
  ;  RTS

    ;.org $2000
 



; 2,828 byte fully unrolled vertical 'raster bar' routine
; 576 pixels drawn, following scanline
; 6,271 cycles now with txa, 55 cycles saved per bar vrs LDA RColor5. 
; 6,259 whole function, 10.86 a pixel
; Every cycle counts!
; Now only 58 cycles total/0.1 cycles a pixel slower while following scanline.
; cmp to the partal rolled VLine based version.
; But.... It is HUGE at over 2.5 KB!
; It sure is smooth though! Can sweep 3 bars!
VBar: ;Color A, RScreen location, y offset
 ; All the exta loads you would think would slow it down
 ; and while it is more cycles, it draws top to bottom
 ; Meaning that it follows the VGA scan line.
 ; Normal fast line draw routine shows tearing.
 ; IE the last several bars we clipped at the top of the screen 
 ; because they had not been drawn yet.
 
;  LDY RVScreenH
;  STY ScreenH
;  LDY RVScreen
;  STY Screen
; 67% faster.
VBarRenderFast: ;2,323 bytes, 505 less bytes. 3,815 cycles, 2,444 less. 6.6 cycles a pixel, 67% faster!
  RDisplay = Display - 9
  PHA
  PHX
  PHY


 LDY RVScreenH
 STY ScreenH
 LDY RVScreen
 STY Screen

  LDX Screen

  ;RDisplay location = $2000
  LDA RColor5
  TAY

  ;TYA ;Edge/Background Not needed for first row 1
  STA RDisplay+0, x          ; Line 1
  STA RDisplay+8, x          ; Line 9
  LDA RColor1
  STA RDisplay+1, x          ; Line 2
  STA RDisplay+7, x          ; Line 8
  LDA RColor2
  STA RDisplay+2, x          ; Line 3
  STA RDisplay+6, x          ; Line 7
  LDA RColor3
  STA RDisplay+3, x          ; Line 4
  STA RDisplay+5, x          ; Line 6
  LDA RColor4
  STA RDisplay+4, x          ; Line 5
  

  TYA ;Edge/Background Not needed for first row 2
  STA RDisplay+$80, x          ; Line 1
  STA RDisplay+$88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$81, x          ; Line 2
  STA RDisplay+$87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$82, x          ; Line 3
  STA RDisplay+$86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$83, x          ; Line 4
  STA RDisplay+$85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$84, x          ; Line 5

  
  TYA ;Edge/Background 3
  STA RDisplay+$100, x          ; Line 1
  STA RDisplay+$108, x          ; Line 9
  LDA RColor1
  STA RDisplay+$101, x          ; Line 2
  STA RDisplay+$107, x          ; Line 8
  LDA RColor2
  STA RDisplay+$102, x          ; Line 3
  STA RDisplay+$106, x          ; Line 7
  LDA RColor3
  STA RDisplay+$103, x          ; Line 4
  STA RDisplay+$105, x          ; Line 6
  LDA RColor4
  STA RDisplay+$104, x          ; Line 5
  


    TYA ;Edge/Background 4
  STA RDisplay+$180, x          ; Line 1
  STA RDisplay+$188, x          ; Line 9
  LDA RColor1
  STA RDisplay+$181, x          ; Line 2
  STA RDisplay+$187, x          ; Line 8
  LDA RColor2
  STA RDisplay+$182, x          ; Line 3
  STA RDisplay+$186, x          ; Line 7
  LDA RColor3
  STA RDisplay+$183, x          ; Line 4
  STA RDisplay+$185, x          ; Line 6
  LDA RColor4
  STA RDisplay+$184, x          ; Line 5

	

    TYA ;Edge/Background 5
  STA RDisplay+$200, x          ; Line 1
  STA RDisplay+$208, x          ; Line 9
  LDA RColor1
  STA RDisplay+$201, x          ; Line 2
  STA RDisplay+$207, x          ; Line 8
  LDA RColor2
  STA RDisplay+$202, x          ; Line 3
  STA RDisplay+$206, x          ; Line 7
  LDA RColor3
  STA RDisplay+$203, x          ; Line 4
  STA RDisplay+$205, x          ; Line 6
  LDA RColor4
  STA RDisplay+$204, x          ; Line 5

	

  TYA ;Edge/Background 6
  STA RDisplay+$280, x          ; Line 1
  STA RDisplay+$288, x          ; Line 9
  LDA RColor1
  STA RDisplay+$281, x          ; Line 2
  STA RDisplay+$287, x          ; Line 8
  LDA RColor2
  STA RDisplay+$282, x          ; Line 3
  STA RDisplay+$286, x          ; Line 7
  LDA RColor3
  STA RDisplay+$283, x          ; Line 4
  STA RDisplay+$285, x          ; Line 6
  LDA RColor4
  STA RDisplay+$284, x          ; Line 5


  TYA ;Edge/Background 7
  STA RDisplay+$300, x          ; Line 1
  STA RDisplay+$308, x          ; Line 9
  LDA RColor1
  STA RDisplay+$301, x          ; Line 2
  STA RDisplay+$307, x          ; Line 8
  LDA RColor2
  STA RDisplay+$302, x          ; Line 3
  STA RDisplay+$306, x          ; Line 7
  LDA RColor3
  STA RDisplay+$303, x          ; Line 4
  STA RDisplay+$305, x          ; Line 6
  LDA RColor4
  STA RDisplay+$304, x          ; Line 5

	

    TYA ;Edge/Background 8
  STA RDisplay+$380, x          ; Line 1
  STA RDisplay+$388, x          ; Line 9
  LDA RColor1
  STA RDisplay+$381, x          ; Line 2
  STA RDisplay+$387, x          ; Line 8
  LDA RColor2
  STA RDisplay+$382, x          ; Line 3
  STA RDisplay+$386, x          ; Line 7
  LDA RColor3
  STA RDisplay+$383, x          ; Line 4
  STA RDisplay+$385, x          ; Line 6
  LDA RColor4
  STA RDisplay+$384, x          ; Line 5

	

    TYA ;Edge/Background 9
  STA RDisplay+$400, x          ; Line 1
  STA RDisplay+$408, x          ; Line 9
  LDA RColor1
  STA RDisplay+$401, x          ; Line 2
  STA RDisplay+$407, x          ; Line 8
  LDA RColor2
  STA RDisplay+$402, x          ; Line 3
  STA RDisplay+$406, x          ; Line 7
  LDA RColor3
  STA RDisplay+$403, x          ; Line 4
  STA RDisplay+$405, x          ; Line 6
  LDA RColor4
  STA RDisplay+$404, x          ; Line 5

	

    TYA ;Edge/Background 10
  STA RDisplay+$480, x          ; Line 1
  STA RDisplay+$488, x          ; Line 9
  LDA RColor1
  STA RDisplay+$481, x          ; Line 2
  STA RDisplay+$487, x          ; Line 8
  LDA RColor2
  STA RDisplay+$482, x          ; Line 3
  STA RDisplay+$486, x          ; Line 7
  LDA RColor3
  STA RDisplay+$483, x          ; Line 4
  STA RDisplay+$485, x          ; Line 6
  LDA RColor4
  STA RDisplay+$484, x          ; Line 5

	

   TYA ;Edge/Background 11
  STA RDisplay+$500, x          ; Line 1
  STA RDisplay+$508, x          ; Line 9
  LDA RColor1
  STA RDisplay+$501, x          ; Line 2
  STA RDisplay+$507, x          ; Line 8
  LDA RColor2
  STA RDisplay+$502, x          ; Line 3
  STA RDisplay+$506, x          ; Line 7
  LDA RColor3
  STA RDisplay+$503, x          ; Line 4
  STA RDisplay+$505, x          ; Line 6
  LDA RColor4
  STA RDisplay+$504, x          ; Line 5

	

  TYA ;Edge/Background 12
  STA RDisplay+$580, x          ; Line 1
  STA RDisplay+$588, x          ; Line 9
  LDA RColor1
  STA RDisplay+$581, x          ; Line 2
  STA RDisplay+$587, x          ; Line 8
  LDA RColor2
  STA RDisplay+$582, x          ; Line 3
  STA RDisplay+$586, x          ; Line 7
  LDA RColor3
  STA RDisplay+$583, x          ; Line 4
  STA RDisplay+$585, x          ; Line 6
  LDA RColor4
  STA RDisplay+$584, x          ; Line 5




  TYA ;Edge/Background 13
  STA RDisplay+$600, x          ; Line 1
  STA RDisplay+$608, x          ; Line 9
  LDA RColor1
  STA RDisplay+$601, x          ; Line 2
  STA RDisplay+$607, x          ; Line 8
  LDA RColor2
  STA RDisplay+$602, x          ; Line 3
  STA RDisplay+$606, x          ; Line 7
  LDA RColor3
  STA RDisplay+$603, x          ; Line 4
  STA RDisplay+$605, x          ; Line 6
  LDA RColor4
  STA RDisplay+$604, x          ; Line 5


  TYA ;Edge/Background 14
  STA RDisplay+$680, x          ; Line 1
  STA RDisplay+$688, x          ; Line 9
  LDA RColor1
  STA RDisplay+$681, x          ; Line 2
  STA RDisplay+$687, x          ; Line 8
  LDA RColor2
  STA RDisplay+$682, x          ; Line 3
  STA RDisplay+$686, x          ; Line 7
  LDA RColor3
  STA RDisplay+$683, x          ; Line 4
  STA RDisplay+$685, x          ; Line 6
  LDA RColor4
  STA RDisplay+$684, x          ; Line 5

	

  TYA ;Edge/Background 15
  STA RDisplay+$700, x          ; Line 1
  STA RDisplay+$708, x          ; Line 9
  LDA RColor1
  STA RDisplay+$701, x          ; Line 2
  STA RDisplay+$707, x          ; Line 8
  LDA RColor2
  STA RDisplay+$702, x          ; Line 3
  STA RDisplay+$706, x          ; Line 7
  LDA RColor3
  STA RDisplay+$703, x          ; Line 4
  STA RDisplay+$705, x          ; Line 6
  LDA RColor4
  STA RDisplay+$704, x          ; Line 5

	

  TYA ;Edge/Background 16
  STA RDisplay+$780, x          ; Line 1
  STA RDisplay+$788, x          ; Line 9
  LDA RColor1
  STA RDisplay+$781, x          ; Line 2
  STA RDisplay+$787, x          ; Line 8
  LDA RColor2
  STA RDisplay+$782, x          ; Line 3
  STA RDisplay+$786, x          ; Line 7
  LDA RColor3
  STA RDisplay+$783, x          ; Line 4
  STA RDisplay+$785, x          ; Line 6
  LDA RColor4
  STA RDisplay+$784, x          ; Line 5



  TYA ;Edge/Background 17
  STA RDisplay+$800, x          ; Line 1
  STA RDisplay+$808, x          ; Line 9
  LDA RColor1
  STA RDisplay+$801, x          ; Line 2
  STA RDisplay+$807, x          ; Line 8
  LDA RColor2
  STA RDisplay+$802, x          ; Line 3
  STA RDisplay+$806, x          ; Line 7
  LDA RColor3
  STA RDisplay+$803, x          ; Line 4
  STA RDisplay+$805, x          ; Line 6
  LDA RColor4
  STA RDisplay+$804, x          ; Line 5

	

  TYA ;Edge/Background 18
  STA RDisplay+$880, x          ; Line 1
  STA RDisplay+$888, x          ; Line 9
  LDA RColor1
  STA RDisplay+$881, x          ; Line 2
  STA RDisplay+$887, x          ; Line 8
  LDA RColor2
  STA RDisplay+$882, x          ; Line 3
  STA RDisplay+$886, x          ; Line 7
  LDA RColor3
  STA RDisplay+$883, x          ; Line 4
  STA RDisplay+$885, x          ; Line 6
  LDA RColor4
  STA RDisplay+$884, x          ; Line 5

;STA RDisplay +$90$880,x
  
  TYA ;Edge/Background 19
  STA RDisplay+$900, x          ; Line 1
  STA RDisplay+$908, x          ; Line 9
  LDA RColor1
  STA RDisplay+$901, x          ; Line 2
  STA RDisplay+$907, x          ; Line 8
  LDA RColor2
  STA RDisplay+$902, x          ; Line 3
  STA RDisplay+$906, x          ; Line 7
  LDA RColor3
  STA RDisplay+$903, x          ; Line 4
  STA RDisplay+$905, x          ; Line 6
  LDA RColor4
  STA RDisplay+$904, x          ; Line 5
	;STA RDisplay +$98$900,x
  
  TYA ;Edge/Background 20
  STA RDisplay+$980, x          ; Line 1
  STA RDisplay+$988, x          ; Line 9
  LDA RColor1
  STA RDisplay+$981, x          ; Line 2
  STA RDisplay+$987, x          ; Line 8
  LDA RColor2
  STA RDisplay+$982, x          ; Line 3
  STA RDisplay+$986, x          ; Line 7
  LDA RColor3
  STA RDisplay+$983, x          ; Line 4
  STA RDisplay+$985, x          ; Line 6
  LDA RColor4
  STA RDisplay+$984, x          ; Line 5
	;STA RDisplay +$A0$980,x
  
  TYA ;Edge/Background 21
  STA RDisplay+$A00, x          ; Line 1
  STA RDisplay+$A08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$A01, x          ; Line 2
  STA RDisplay+$A07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$A02, x          ; Line 3
  STA RDisplay+$A06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$A03, x          ; Line 4
  STA RDisplay+$A05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$A04, x          ; Line 5
	;STA RDisplay +$A8$A00,x
  
  TYA ;Edge/Background 22
  STA RDisplay+$A80, x          ; Line 1
  STA RDisplay+$A88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$A81, x          ; Line 2
  STA RDisplay+$A87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$A82, x          ; Line 3
  STA RDisplay+$A86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$A83, x          ; Line 4
  STA RDisplay+$A85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$A84, x          ; Line 5

  
  TYA ;Edge/Background 23
  STA RDisplay+$B00, x          ; Line 1
  STA RDisplay+$B08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$B01, x          ; Line 2
  STA RDisplay+$B07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$B02, x          ; Line 3
  STA RDisplay+$B06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$B03, x          ; Line 4
  STA RDisplay+$B05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$B04, x          ; Line 5
	
  
  TYA ;Edge/Background 24
  STA RDisplay+$B80, x          ; Line 1
  STA RDisplay+$B88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$B81, x          ; Line 2
  STA RDisplay+$B87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$B82, x          ; Line 3
  STA RDisplay+$B86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$B83, x          ; Line 4
  STA RDisplay+$B85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$B84, x          ; Line 5
	
  
  TYA ;Edge/Background 25
  STA RDisplay+$C00, x          ; Line 1
  STA RDisplay+$C08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$C01, x          ; Line 2
  STA RDisplay+$C07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$C02, x          ; Line 3
  STA RDisplay+$C06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$C03, x          ; Line 4
  STA RDisplay+$C05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$C04, x          ; Line 5

  
  TYA ;Edge/Background 26
  STA RDisplay+$C80, x          ; Line 1
  STA RDisplay+$C88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$C81, x          ; Line 2
  STA RDisplay+$C87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$C82, x          ; Line 3
  STA RDisplay+$C86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$C83, x          ; Line 4
  STA RDisplay+$C85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$C84, x          ; Line 5
	
  
  TYA ;Edge/Background 27
  STA RDisplay+$D00, x          ; Line 1
  STA RDisplay+$D08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$D01, x          ; Line 2
  STA RDisplay+$D07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$D02, x          ; Line 3
  STA RDisplay+$D06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$D03, x          ; Line 4
  STA RDisplay+$D05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$D04, x          ; Line 5

  
  TYA ;Edge/Background 28
  STA RDisplay+$D80, x          ; Line 1
  STA RDisplay+$D88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$D81, x          ; Line 2
  STA RDisplay+$D87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$D82, x          ; Line 3
  STA RDisplay+$D86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$D83, x          ; Line 4
  STA RDisplay+$D85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$D84, x          ; Line 5

  
  TYA ;Edge/Background 29
  STA RDisplay+$E00, x          ; Line 1
  STA RDisplay+$E08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$E01, x          ; Line 2
  STA RDisplay+$E07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$E02, x          ; Line 3
  STA RDisplay+$E06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$E03, x          ; Line 4
  STA RDisplay+$E05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$E04, x          ; Line 5

  
  TYA ;Edge/Background 30
  STA RDisplay+$E80, x          ; Line 1
  STA RDisplay+$E88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$E81, x          ; Line 2
  STA RDisplay+$E87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$E82, x          ; Line 3
  STA RDisplay+$E86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$E83, x          ; Line 4
  STA RDisplay+$E85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$E84, x          ; Line 5

  
  TYA ;Edge/Background 31
  STA RDisplay+$F00, x          ; Line 1
  STA RDisplay+$F08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$F01, x          ; Line 2
  STA RDisplay+$F07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$F02, x          ; Line 3
  STA RDisplay+$F06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$F03, x          ; Line 4
  STA RDisplay+$F05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$F04, x          ; Line 5

  
  TYA ;Edge/Background 32
  STA RDisplay+$F80, x          ; Line 1
  STA RDisplay+$F88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$F81, x          ; Line 2
  STA RDisplay+$F87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$F82, x          ; Line 3
  STA RDisplay+$F86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$F83, x          ; Line 4
  STA RDisplay+$F85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$F84, x          ; Line 5

  
  TYA ;Edge/Background 33
  STA RDisplay+$1000, x          ; Line 1
  STA RDisplay+$1008, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1001, x          ; Line 2
  STA RDisplay+$1007, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1002, x          ; Line 3
  STA RDisplay+$1006, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1003, x          ; Line 4
  STA RDisplay+$1005, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1004, x          ; Line 5
	
  ;MIDDLE ROW 31          ; Line 31
	
  
  TYA ;Edge/Background 34
  STA RDisplay+$1080, x          ; Line 1
  STA RDisplay+$1088, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1081, x          ; Line 2
  STA RDisplay+$1087, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1082, x          ; Line 3
  STA RDisplay+$1086, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1083, x          ; Line 4
  STA RDisplay+$1085, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1084, x          ; Line 5

  
  TYA ;Edge/Background 35
  STA RDisplay+$1100, x          ; Line 1
  STA RDisplay+$1108, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1101, x          ; Line 2
  STA RDisplay+$1107, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1102, x          ; Line 3
  STA RDisplay+$1106, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1103, x          ; Line 4
  STA RDisplay+$1105, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1104, x          ; Line 5

  
  TYA ;Edge/Background 36
  STA RDisplay+$1180, x          ; Line 1
  STA RDisplay+$1188, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1181, x          ; Line 2
  STA RDisplay+$1187, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1182, x          ; Line 3
  STA RDisplay+$1186, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1183, x          ; Line 4
  STA RDisplay+$1185, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1184, x          ; Line 5

  
  TYA ;Edge/Background 37
  STA RDisplay+$1200, x          ; Line 1
  STA RDisplay+$1208, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1201, x          ; Line 2
  STA RDisplay+$1207, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1202, x          ; Line 3
  STA RDisplay+$1206, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1203, x          ; Line 4
  STA RDisplay+$1205, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1204, x          ; Line 5

  
  TYA ;Edge/Background 38
  STA RDisplay+$1280, x          ; Line 1
  STA RDisplay+$1288, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1281, x          ; Line 2
  STA RDisplay+$1287, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1282, x          ; Line 3
  STA RDisplay+$1286, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1283, x          ; Line 4
  STA RDisplay+$1285, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1284, x          ; Line 5
	
  
  TYA ;Edge/Background 39
  STA RDisplay+$1300, x          ; Line 1
  STA RDisplay+$1308, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1301, x          ; Line 2
  STA RDisplay+$1307, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1302, x          ; Line 3
  STA RDisplay+$1306, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1303, x          ; Line 4
  STA RDisplay+$1305, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1304, x          ; Line 5
	
  
  TYA ;Edge/Background 40
  STA RDisplay+$1380, x          ; Line 1
  STA RDisplay+$1388, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1381, x          ; Line 2
  STA RDisplay+$1387, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1382, x          ; Line 3
  STA RDisplay+$1386, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1383, x          ; Line 4
  STA RDisplay+$1385, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1384, x          ; Line 5
	
  
  TYA ;Edge/Background 41
  STA RDisplay+$1400, x          ; Line 1
  STA RDisplay+$1408, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1401, x          ; Line 2
  STA RDisplay+$1407, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1402, x          ; Line 3
  STA RDisplay+$1406, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1403, x          ; Line 4
  STA RDisplay+$1405, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1404, x          ; Line 5
	
  
  TYA ;Edge/Background 42
  STA RDisplay+$1480, x          ; Line 1
  STA RDisplay+$1488, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1481, x          ; Line 2
  STA RDisplay+$1487, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1482, x          ; Line 3
  STA RDisplay+$1486, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1483, x          ; Line 4
  STA RDisplay+$1485, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1484, x          ; Line 5
	
  
  TYA ;Edge/Background 43
  STA RDisplay+$1500, x          ; Line 1
  STA RDisplay+$1508, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1501, x          ; Line 2
  STA RDisplay+$1507, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1502, x          ; Line 3
  STA RDisplay+$1506, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1503, x          ; Line 4
  STA RDisplay+$1505, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1504, x          ; Line 5
	
  
  TYA ;Edge/Background 44
  STA RDisplay+$1580, x          ; Line 1
  STA RDisplay+$1588, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1581, x          ; Line 2
  STA RDisplay+$1587, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1582, x          ; Line 3
  STA RDisplay+$1586, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1583, x          ; Line 4
  STA RDisplay+$1585, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1584, x          ; Line 5
	
  
  TYA ;Edge/Background 45
  STA RDisplay+$1600, x          ; Line 1
  STA RDisplay+$1608, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1601, x          ; Line 2
  STA RDisplay+$1607, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1602, x          ; Line 3
  STA RDisplay+$1606, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1603, x          ; Line 4
  STA RDisplay+$1605, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1604, x          ; Line 5
	
  
  TYA ;Edge/Background 46
  STA RDisplay+$1680, x          ; Line 1
  STA RDisplay+$1688, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1681, x          ; Line 2
  STA RDisplay+$1687, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1682, x          ; Line 3
  STA RDisplay+$1686, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1683, x          ; Line 4
  STA RDisplay+$1685, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1684, x          ; Line 5
	
  
  TYA ;Edge/Background 47
  STA RDisplay+$1700, x          ; Line 1
  STA RDisplay+$1708, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1701, x          ; Line 2
  STA RDisplay+$1707, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1702, x          ; Line 3
  STA RDisplay+$1706, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1703, x          ; Line 4
  STA RDisplay+$1705, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1704, x          ; Line 5
	
  
  TYA ;Edge/Background 48
  STA RDisplay+$1780, x          ; Line 1
  STA RDisplay+$1788, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1781, x          ; Line 2
  STA RDisplay+$1787, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1782, x          ; Line 3
  STA RDisplay+$1786, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1783, x          ; Line 4
  STA RDisplay+$1785, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1784, x          ; Line 5
	
  
  TYA ;Edge/Background 49
  STA RDisplay+$1800, x          ; Line 1
  STA RDisplay+$1808, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1801, x          ; Line 2
  STA RDisplay+$1807, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1802, x          ; Line 3
  STA RDisplay+$1806, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1803, x          ; Line 4
  STA RDisplay+$1805, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1804, x          ; Line 5
	
  
  TYA ;Edge/Background 50
  STA RDisplay+$1880, x          ; Line 1
  STA RDisplay+$1888, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1881, x          ; Line 2
  STA RDisplay+$1887, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1882, x          ; Line 3
  STA RDisplay+$1886, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1883, x          ; Line 4
  STA RDisplay+$1885, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1884, x          ; Line 5
	
  
  TYA ;Edge/Background 51
  STA RDisplay+$1900, x          ; Line 1
  STA RDisplay+$1908, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1901, x          ; Line 2
  STA RDisplay+$1907, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1902, x          ; Line 3
  STA RDisplay+$1906, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1903, x          ; Line 4
  STA RDisplay+$1905, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1904, x          ; Line 5
	
  
  TYA ;Edge/Background 52
  STA RDisplay+$1980, x          ; Line 1
  STA RDisplay+$1988, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1981, x          ; Line 2
  STA RDisplay+$1987, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1982, x          ; Line 3
  STA RDisplay+$1986, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1983, x          ; Line 4
  STA RDisplay+$1985, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1984, x          ; Line 5
	
  
  TYA ;Edge/Background 53
  STA RDisplay+$1A00, x          ; Line 1
  STA RDisplay+$1A08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1A01, x          ; Line 2
  STA RDisplay+$1A07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1A02, x          ; Line 3
  STA RDisplay+$1A06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1A03, x          ; Line 4
  STA RDisplay+$1A05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1A04, x          ; Line 5
	
  
  TYA ;Edge/Background 54
  STA RDisplay+$1A80, x          ; Line 1
  STA RDisplay+$1A88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1A81, x          ; Line 2
  STA RDisplay+$1A87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1A82, x          ; Line 3
  STA RDisplay+$1A86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1A83, x          ; Line 4
  STA RDisplay+$1A85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1A84, x          ; Line 5
	
  
  TYA ;Edge/Background 55
  STA RDisplay+$1B00, x          ; Line 1
  STA RDisplay+$1B08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1B01, x          ; Line 2
  STA RDisplay+$1B07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1B02, x          ; Line 3
  STA RDisplay+$1B06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1B03, x          ; Line 4
  STA RDisplay+$1B05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1B04, x          ; Line 5
	

  
  TYA ;Edge/Background 56
  STA RDisplay+$1B80, x          ; Line 1
  STA RDisplay+$1B88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1B81, x          ; Line 2
  STA RDisplay+$1B87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1B82, x          ; Line 3
  STA RDisplay+$1B86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1B83, x          ; Line 4
  STA RDisplay+$1B85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1B84, x          ; Line 5
	
  
  TYA ;Edge/Background 57
  STA RDisplay+$1C00, x          ; Line 1
  STA RDisplay+$1C08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1C01, x          ; Line 2
  STA RDisplay+$1C07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1C02, x          ; Line 3
  STA RDisplay+$1C06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1C03, x          ; Line 4
  STA RDisplay+$1C05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1C04, x          ; Line 5
	
  
  TYA ;Edge/Background 58
  STA RDisplay+$1C80, x          ; Line 1
  STA RDisplay+$1C88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1C81, x          ; Line 2
  STA RDisplay+$1C87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1C82, x          ; Line 3
  STA RDisplay+$1C86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1C83, x          ; Line 4
  STA RDisplay+$1C85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1C84, x          ; Line 5
	
  
  TYA ;Edge/Background 59
  STA RDisplay+$1D00, x          ; Line 1
  STA RDisplay+$1D08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1D01, x          ; Line 2
  STA RDisplay+$1D07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1D02, x          ; Line 3
  STA RDisplay+$1D06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1D03, x          ; Line 4
  STA RDisplay+$1D05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1D04, x          ; Line 5
	
  
  TYA ;Edge/Background 60
  STA RDisplay+$1D80, x          ; Line 1
  STA RDisplay+$1D88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1D81, x          ; Line 2
  STA RDisplay+$1D87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1D82, x          ; Line 3
  STA RDisplay+$1D86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1D83, x          ; Line 4
  STA RDisplay+$1D85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1D84, x          ; Line 5
	
  
  TYA ;Edge/Background 61
  STA RDisplay+$1E00, x          ; Line 1
  STA RDisplay+$1E08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1E01, x          ; Line 2
  STA RDisplay+$1E07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1E02, x          ; Line 3
  STA RDisplay+$1E06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1E03, x          ; Line 4
  STA RDisplay+$1E05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1E04, x          ; Line 5
	
  
  TYA ;Edge/Background 62
  STA RDisplay+$1E80, x          ; Line 1
  STA RDisplay+$1E88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1E81, x          ; Line 2
  STA RDisplay+$1E87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1E82, x          ; Line 3
  STA RDisplay+$1E86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1E83, x          ; Line 4
  STA RDisplay+$1E85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1E84, x          ; Line 5
	
  
  TYA ;Edge/Background 63
  STA RDisplay+$1F00, x          ; Line 1
  STA RDisplay+$1F08, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1F01, x          ; Line 2
  STA RDisplay+$1F07, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1F02, x          ; Line 3
  STA RDisplay+$1F06, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1F03, x          ; Line 4
  STA RDisplay+$1F05, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1F04, x          ; Line 5
	
  
  TYA ;Edge/Background 64
  STA RDisplay+$1F80, x          ; Line 1
  STA RDisplay+$1F88, x          ; Line 9
  LDA RColor1
  STA RDisplay+$1F81, x          ; Line 2
  STA RDisplay+$1F87, x          ; Line 8
  LDA RColor2
  STA RDisplay+$1F82, x          ; Line 3
  STA RDisplay+$1F86, x          ; Line 7
  LDA RColor3
  STA RDisplay+$1F83, x          ; Line 4
  STA RDisplay+$1F85, x          ; Line 6
  LDA RColor4
  STA RDisplay+$1F84, x          ; Line 5
	   
  
  PLY
  PLX
  PLA
 RTS

 

; VBarRender: 
;  PHX  ;?? needed ??
;  LDX RColor5 ;1 Store edge in X

;  LDY #0 ; No y offset allowed with unrolled routine
; VBar64:
;  TXA ;Edge Color
;  sta (Screen),y; Draw it! 64
;  INY ; Move over pixel
;  LDA RColor1 ;2
;  sta (Screen),y; Draw it! 
;  INY 
;  LDA RColor2 ;3
;  sta (Screen),y; Draw it! 
;  INY 
;  LDA RColor3 ;4
;  sta (Screen),y; Draw it! 
;  INY 
;  LDA RColor4 ;5
;  sta (Screen),y; Draw it! 
;  INY 
;  LDA RColor3 ;6
;  sta (Screen),y; Draw it! 
;  INY 
;  LDA RColor2 ;7
;  sta (Screen),y; Draw it! 
;  INY 
;  LDA RColor1 ; 8
;  sta (Screen),y; Draw it! 
;  INY 
;  TXA ;LDA RColor5 ; 9 Use this color for next two pixels
;  sta (Screen),y; Draw it! 
;  ldy #$80 ;Move down a row
; VBar63:
;  sta (Screen),y; Draw it! Next Line Pixel 1
;  ; Unrolled........... x 64 times total
;   INY
;   LDA RColor1 ;2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2 ;3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3 ;4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4;5
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3;6
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2;7
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1;8
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ; LDA RColor5;9
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
; VBar62:
;   sta (Screen),y; Draw it! 62 ;1
;   INY
;   LDA RColor1 ;2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
; VBar61:
;   sta (Screen),y; Draw it! 61
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
; VBar60:
;   sta (Screen),y; Draw it! 60
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
; VBar59:
;   sta (Screen),y; Draw it! 59
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 58
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 57
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 56
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 55
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 54
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 53
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 52
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 51
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 50
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 49
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 48
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 47
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 46
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 45
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 44
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 43
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 42
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 41
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 40
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 39
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 38
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 37
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 36
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 35
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 34
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 33
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 32
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 31
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 30
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 29
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 28
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 27
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 26
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 25
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 24
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 23
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 22
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 21
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 20
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 19
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 18
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 17
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 16
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 15
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 14
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 13
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 12
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 11
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 10
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 9
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 8
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 7
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 6
;     INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 5
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 4
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 3
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   inc ScreenH
;   ldy #$00
;   sta (Screen),y; Draw it! 2
;     INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
;   ldy #$80
;   sta (Screen),y; Draw it! 1
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor4
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor3
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor2
;   sta (Screen),y; Draw it! 
;   INY
;   LDA RColor1
;   sta (Screen),y; Draw it! 
;   INY
;   TXA ;LDA RColor5
;   sta (Screen),y; Draw it! 
 
;  PLX
;  RTS

