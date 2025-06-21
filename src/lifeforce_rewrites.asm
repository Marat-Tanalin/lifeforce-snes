



; rewrite de33
queue_fade_of_boss_music:
  LDA #$01
  STA $06DA
  LDA #$3A
  jslb queue_fade_to_next_track, $b2
  STA $06DE
  RTL

; rewrite of eeea - reseting starting variables
reset_starting_vars:
  LDX #$30
  JSR $E8C3
  : STA $00,X
  INX
  CPX #$F0
  BNE :-

  LDA OPTIONS_DIFFICULTY
  STA $31

  rtl

; rewrite of logic from C053
:
    LDA #$FF
:
    STA ($00), Y
    INC $00

handle_palette_x_entries_from_0700:
    LDA $0700, X
    INX
    CMP #$FF
    BNE :-

    LDA $0700,X
    CMP #$08
    BCS :--

    LDA #$01
    STA PALETTE_NEEDS_UPDATING

    PLA
    STA $01
    PLA
    STA $00
    TXY
    PLX

    CLC
    RTL



write_vram_data_copy_x_entries_from_0700:
    LDA $06FE, Y
    CMP #$3F
    BCC non_palette_entries
    PHX

    TYX
    LDA $06FF, Y
    TAY

    LDA $00
    PHA
    LDA $01
    PHA
    LDA #<PALETTE_UPDATE_START
    STA $00
    LDA #>PALETTE_UPDATE_START
    STA $01    
    BRA handle_palette_x_entries_from_0700
    
non_palette_entries:
    CMP #$20
    BCC tile_edit_entries
    BRA bg_vram_entries

:
    LDA #$FF
:
    STA VMDATAL
bg_vram_entries:
    LDA $0700, Y
    INY
    CMP #$FF
    BNE :-

    LDA $0700, Y
    CMP #$08
    BCS :--

    CLC
    RTL


tile_edit_entries:
  ; editing tiles in vram.  
  ; tiles in NES are of the format
  ; 0 1 2 3 4 5 6 7 8 9 A B C D E F
  ;
  ; in SNES 4bpp format tiles are
  ; 0 8 1 9 2 A 3 B 4 C 5 D 6 E 7 F
  LDA VMAIN_STATE
  ORA #$80
  STA VMAIN

  PHX
  LDX #00
  BRA :++
  
: STA VMDATAL 
  LDA $0708, Y
  STA VMDATAH
  INY
  INX
  CPX #$08
  BNE :+
    TYA
    CLC
    ADC #$08
    TAY
    LDX #$00
: LDA $0700, Y
  CMP #$FF
  BNE :--

  INY
  PLX
  LDA VMAIN_STATE
  STA VMAIN

  CLC
  RTL



write_vram_data_run_of_x_entries_from_0700:
  ; we need to check and see if we're writing to CGRAM or not
  LDA $06FE, Y
  CMP #$3F
  BCS handle_palette_from_0700

  CMP #$20
  BCC handle_tiles_from_0700

  LDX $0700,Y
  INY
  LDA $0700,Y
  INY

:
  STA VMDATAL ; PpuData_2007
  DEX
  BNE :-
  rtl


handle_palette_from_0700:
  LDX $0700, Y  
  INY
  LDA $0700, Y
  INY
  PHA
  LDA $06FD, Y  ; contains the current VMADDL
                ; also determines which palette we want to write
  TAY
  PLA

: STA PALETTE_UPDATE_START, Y
  DEX
  BNE :-

  LDA #$01 
  STA PALETTE_NEEDS_UPDATING
  LDA #$00
  rtl

handle_tiles_from_0700:
  LDX $0700, Y
  INY
  LDA $0700, Y
  INY
  :
  STA VMDATAH ; PpuData_2007
  STA VMDATAL ; PpuData_2007
  DEX
  BNE :-
  rtl


c074_tile_and_attribute_rewrite:
  ; original code:
  LDA $06FE, Y
  CMP #$20
  BCC c074_tile

  LDA $0700,Y
  INY
  STA $00
  LDA VMDATALREAD ; PpuData_2007
  ; LDA VMDATALREAD ; PpuData_2007
  AND $00
  ORA $0700,Y
  LDX $06FD,Y
  STX VMADDH ; PpuAddr_2006
  STX ATTR_NES_VM_ADDR_HB

  LDX $06FE,Y
  STX VMADDL ; PpuAddr_2006
  STX ATTR_NES_VM_ADDR_LB

  STA VMDATAL ; PpuData_2007
  STA ATTR_NES_VM_ATTR_START
  LDA #$01
  STA ATTR_NES_VM_COUNT
  STA ATTR_NES_HAS_VALUES
  STZ ATTR_NES_VM_ATTR_START + 1

  jslb convert_nes_attributes_and_immediately_dma_them, $a0

  INY

  rtl

c074_attrributes:
  LDA $0700,Y
  INY
  STA $00
  LDA VMDATALREAD ; PpuData_2007
  AND $00
  ORA $0700,Y

  LDX $06FD,Y  
  STX ATTR_NES_VM_ADDR_HB
  
  LDX $06FE,Y
  STX ATTR_NES_VM_ADDR_LB
  
  STA ATTR_NES_VM_ATTR_START
  LDA #$01
  STA ATTR_NES_VM_COUNT
  ; STA ATTR_NES_HAS_VALUES
  STZ ATTR_NES_VM_ATTR_START + 1
  ; jslb convert_nes_attributes_and_immediately_dma_them, $a0
  jslb write_single_attribute, $a0
  INY
  rtl

c074_tile:
  PHB
  PHK
  PLB

  STA VMADDH
  LDA $06FF, Y
  AND #$F0
  STA $00
  LDA $06FF, Y
  AND #$08

  BNE handle_hi_byte
  LDA $06FF, Y
  AND #$07
  ORA $00
  PHA
  STA VMADDL

  LDA $0700,Y
  INY
  STA $00
  LDA VMDATALREAD ; PpuData_2007
  AND $00
  ORA $0700,Y

  LDX $06FD,Y
  STX VMADDH ; PpuAddr_2006

  PLX
  STX VMADDL ; PpuAddr_2006

  STA VMDATAL ; PpuData_2007
  INY

  PLB
  rtl


handle_hi_byte:
  LDA $06FF, Y
  AND #$07
  ORA $00
  PHA
  STA VMADDL

  LDA $0700,Y
  INY
  STA $00
  LDA VMDATAHREAD ; PpuData_2007
  AND $00
  ORA $0700,Y

  LDX $06FD,Y
  STX VMADDH ; PpuAddr_2006

  PLX
  STX VMADDL ; PpuAddr_2006

  STA VMDATAH ; PpuData_2007
  INY

  PLB
  rtl


nes_c0a3_rewrite:
  LDA $04
  PHA
  LDA $05
  PHA

  LDA #<ATTR_NES_VM_ATTR_START
  STA $04
  LDA #>ATTR_NES_VM_ATTR_START
  STA $05

  DEY 
  DEY

c0a3_start:
  LDA $0700, Y
  STA VMADDH
  ; STA ATTR_NES_VM_ADDR_HB
  INY

  CMP #$20
  BCS :+
   jmp c0a3_tiles
  :

  AND #$03
  CMP #$03
  BNE :+


  LDA $0700,Y
  STA VMADDL
  AND #$C0
  CMP #$C0
  BNE :+

    ; attributes
    jmp c0a3_attr
: 
  LDA $0700,Y
  INY
  STA VMADDL
  ; STA ATTR_NES_VM_ADDR_LB

;   AND #$C0
;   CMP #$C0
;   BNE bg_c0a3
;   BRA attr_c0a3 

; : LDA $0700,Y
;   INY
;   STA VMADDL
;   BRA bg_c0a3

; bg_C098:
;   INY
;   STA VMADDH ; $2117
;   LDA $0700,Y
;   STA VMADDL ; $2116
;   INY
bg_c0a3:
  LDX $0700,Y
  ; STX ATTR_NES_VM_COUNT

  INY
bg_C0A7:
  LDA $0700,Y
  STA VMDATAL
  ; STA ($04)
  ; INC $04

  ; LDA #$00
  ; STA ($04)

  INY
  DEX
  BNE bg_C0A7

  ; LDA #<ATTR_NES_VM_ATTR_START
  ; STA $04

  ; LDA #$01
  ; STA ATTR_NES_HAS_VALUES
  ; jslb convert_nes_attributes_and_immediately_dma_them, $a0

  LDA $0700,Y
  BPL c0a3_start

done_with_c0a7:
  PLA
  STA $05
  PLA
  STA $04
  
  LDA $0700,Y
  INY
  RTL

f094_rle_rewrite:
; This section writes a different set of mostly full screen data depending on what X is
; x = 0 - Zero out all VM and attributes
; x = 2 - Title screen
; x = 4 - ???  A boss?  maybe lvl 2?
; x = 6 - 2 rows of D0 tiles, not sure what it's for
; x = 8 - Konami logo
PHX
jsr F094
PLX
jsr load_attributes_for_x
rtl

c0a3_attr:
  LDA $06ff, Y  
  STA ATTR_NES_VM_ADDR_HB
  LDA $0700,Y
  STA ATTR_NES_VM_ADDR_LB
  INY

attr_c0a3:
  LDX $0700,Y
  STX ATTR_NES_VM_COUNT
  INY

attr_C0A7:
  LDA $0700,Y
  STA VMDATAL
  STA ($04)
  INC $04

  LDA #$00
  STA ($04)

  INY
  DEX
  BNE attr_C0A7

  LDA #<ATTR_NES_VM_ATTR_START
  STA $04

  LDA #$01
  STA ATTR_NES_HAS_VALUES
  jslb convert_nes_attributes_and_immediately_dma_them, $a0

  LDA $0700,Y
  BMI :+
  JMP c0a3_start
: JMP done_with_c0a7



c0a3_tiles:

  LDA $0700,Y
  STA VMADDL
  INY

  LDX $0700,Y
  CPX #$09
  BCC only_low_tiles

  LDA VMAIN_STATE
  ORA #$80
  STA VMAIN

  INY
  STX $04
  LDX #$00

: LDA $0700, Y
  STA VMDATAL
  LDA $0708, Y
  STA VMDATAH
  INY

  INX
  CPX #$08
  BNE :+
    TYA
    CLC
    ADC #$08
    TAY
    LDX #$00
    STZ VMDATAH
    STZ VMDATAH
    STZ VMDATAH
    STZ VMDATAH
    STZ VMDATAH
    STZ VMDATAH
    STZ VMDATAH
    STZ VMDATAH
    DEC $04
    DEC $04
    DEC $04
    DEC $04
    DEC $04
    DEC $04
    DEC $04
    DEC $04
: 
  DEC $04
  LDA $04
  BNE :--

  LDA VMAIN_STATE
  STA VMAIN

  LDA $0700, Y
  BMI :+
  JMP c0a3_start
: JMP done_with_c0a7

only_low_tiles:

  INY
: LDA $0700, Y
  STA VMDATAL
  INY
  DEX
  BNE :-
  

  LDA $0700, Y
  BMI :+
  JMP c0a3_start
: JMP done_with_c0a7

F094:
  LDA $F107,X
  STA $00
  LDA $F108,X
  STA $01
  JSR update_control_status_and_reset_addr_and_mask
  STA $21
  STA $FC
  STA $FD

F0A7:
  LDA RDNMI ; PpuStatus_2002
  LDY #$01
  LDA ($00),Y
  STA VMADDH ; PpuAddr_2006
  DEY
  LDA ($00),Y
  STA VMADDL ; PpuAddr_2006
  LDX #$00
  LDA #$02
  JSR EF37
F0BE:
  LDY #$00
  LDA ($00),Y
  CMP #$FF
  BEQ F104 ; done
  CMP #$7F    
  BEQ F0FC ; done with this write, move to next one 
  TAY
  BPL F0EA ; write same value X times

  AND #$7F    ; write X values sequentially
  STA $02
  LDY #$01
F0D3:
  LDA ($00),Y
  STA VMDATAL ; PpuData_2007
  CPY $02
  BEQ F0DF
  INY
  BNE F0D3
F0DF:
  LDA #$01
  CLC
  ADC $02
F0E4:
  JSR EF37
  JMP F0BE

F0EA:
  LDY #$01
  STA $02
  LDA ($00),Y
  LDY $02
F0F2:
  STA VMDATAL ; PpuData_2007
  DEY
  BNE F0F2
  LDA #$02
  BNE F0E4
F0FC:
  LDA #$01
  JSR EF37
  JMP F0A7

F104:
  RTS ; JMP $E893


update_control_status_and_reset_addr_and_mask:
  LDA NMITIMEN_STATE ; PPU_CONTROL_STATE
  AND #$7F
  STA NMITIMEN ; PpuControl_2000

  LDA RDNMI ; PpuStatus_2002
  jslb set_ppu_mask_to_00, $a0  
  ; move LDA #$00 to the end instead
  LDA #$00

  RTS

EF37:
  CLC
  ADC $00,X
  STA $00,X
  BCC EF40
  INC $01,X
EF40:
  RTS

; pointers to the attribute values give values of X
load_attributes_for_x:
  PHB
  PHK
  PLB

  CPX #$00
  BNE :+
    ; zero
    jslb zero_all_attributes, $a0
    BRA done_loading_attributes
: CPX #$02
  BNE :+
    jsr load_title_screen_attributes
    BRA done_loading_attributes
: CPX #$04
  BNE :+
    jsr load_mystery_1
    bra done_loading_attributes
: CPX #$06
  BNE :+
    ; zero
    jslb zero_all_attributes, $a0
    BRA done_loading_attributes
: CPX #$08
  BNE done_loading_attributes
  jsr load_konami_logo
done_loading_attributes:
  PLB
  rts

load_mystery_1:
  LDA #$23
  STA ATTR_NES_VM_ADDR_HB
  LDA #$C0
  STA ATTR_NES_VM_ADDR_LB
  LDA #$20
  STA ATTR_NES_VM_COUNT

  LDY #$1F
: LDA mystery_1, Y
  STA ATTR_NES_VM_ATTR_START, Y
  DEY
  BPL :-

  LDA #$01
  STA ATTR_NES_HAS_VALUES
  jslb convert_nes_attributes_and_immediately_dma_them, $a0


  LDA #$23
  STA ATTR_NES_VM_ADDR_HB
  LDA #$E0
  STA ATTR_NES_VM_ADDR_LB
  LDA #$20
  STA ATTR_NES_VM_COUNT

  LDY #$1F

: LDA mystery_1 + $20, Y
  STA ATTR_NES_VM_ATTR_START, Y
  DEY
  BPL :-

  LDA #$01
  STA ATTR_NES_HAS_VALUES
  jslb convert_nes_attributes_and_immediately_dma_them, $a0
  
  rts

load_konami_logo:
  jslb zero_all_attributes, $a0
  ; only sets 4 values 23DA - 23DD
  LDA #$23
  STA ATTR_NES_VM_ADDR_HB
  LDA #$DA
  STA ATTR_NES_VM_ADDR_LB
  LDA #$04
  STA ATTR_NES_VM_COUNT

  TAY
  DEY
: LDA konami_logo, Y
  STA ATTR_NES_VM_ATTR_START,Y
  DEY
  BPL :-

  LDA #$01
  STA ATTR_NES_HAS_VALUES
  jslb convert_nes_attributes_and_immediately_dma_them, $a0
  RTS

load_title_screen_attributes:
  LDA #$23
  STA ATTR_NES_VM_ADDR_HB
  LDA #$C0
  STA ATTR_NES_VM_ADDR_LB
  LDA #$20
  STA ATTR_NES_VM_COUNT

  LDY #$1F
: LDA title_screen, Y
  STA ATTR_NES_VM_ATTR_START, Y
  DEY
  BPL :-

  LDA #$01
  STA ATTR_NES_HAS_VALUES
  jslb convert_nes_attributes_and_immediately_dma_them, $a0


  LDA #$23
  STA ATTR_NES_VM_ADDR_HB
  LDA #$E0
  STA ATTR_NES_VM_ADDR_LB
  LDA #$20
  STA ATTR_NES_VM_COUNT

  LDY #$1F

: LDA title_screen + $20, Y
  STA ATTR_NES_VM_ATTR_START, Y
  DEY
  BPL :-

  LDA #$01
  STA ATTR_NES_HAS_VALUES
  jslb convert_nes_attributes_and_immediately_dma_them, $a0
  
  rts

set_pause:
  LDA #$01
  STA $24
  jslb pause_msu_only, $b2
  rtl

un_pause:
  LDA #$00
  STA $24
  jslb resume_msu_only, $b2
  rtl

attribute_values:
.byte <(clear_screen), >(clear_screen)
.byte <(title_screen), >(title_screen)
.byte <(mystery_1)   , >(mystery_1)
.byte <(clear_screen), >(clear_screen)
.byte <(konami_logo) , >(konami_logo)

clear_screen:
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

title_screen:
.byte $00, $00, $F0, $A0, $A0, $E0, $F0, $00, $00, $00, $0F, $00, $F0, $FF, $FF, $00
.byte $00, $50, $50, $50, $50, $50, $50, $10, $00, $0A, $3A, $FA, $FA, $0A, $8A, $22
.byte $00, $00, $CC, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; maybe w2 boss?
mystery_1:
.byte $00, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00, $00, $40
.byte $00, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $50, $55, $00, $00, $00
.byte $10, $00, $00, $05, $01, $01, $00, $00, $00, $00, $04, $00, $00, $00, $00, $00
.byte $01, $40, $00, $00, $40, $00, $01, $40, $00, $00, $00, $00, $00, $00, $00, $00

; only sets 4 values 23DA - 23DD
konami_logo:
.byte $CC, $3B, $0A, $0A
