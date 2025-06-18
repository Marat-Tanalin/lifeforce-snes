NUM_OPTIONS = 6


; Toggle current option
toggle_current_option:
    LDA #$01
    sta NEEDS_OAM_DMA
    LDA CURR_OPTION
    CMP #0
    BNE :+
    JMP update_palette
:
    CMP #1
    BNE :+
    JMP update_lives
:
    CMP #2
    BNE :+
    JMP update_upgrades
:
    CMP #3
    BNE :+
    JMP update_level
:
    CMP #4
    BNE :+
    JMP update_msu1
:
    CMP #5
    BNE :+
    JMP update_playlist
:
RTS


; Decrement current option
decrement_current_option:
    LDA #$01
    sta NEEDS_OAM_DMA
    LDA CURR_OPTION
    CMP #0
    BNE :+
    JMP decrement_palette
:
    CMP #1
    BNE :+
    JMP decrement_lives
:
    CMP #2
    BNE :+
    JMP decrement_upgrades
:
    CMP #3
    BNE :+
    JMP decrement_level
:
    CMP #4
    BNE :+
    JMP decrement_msu1
:
    CMP #5
    BNE :+
    JMP decrement_playlist
:
RTS
option_offsets_0:
	.byte $58, $68, $78, $88, $98, $A8, $B8, $C8

decrement_palette:
	dec $0860
	BPL :+
		LDA #8
		DEC A
		STA $0860
	:
	LDA $0860
	TAY	
	LDA option_offsets_0, Y
	sta SNES_OAM_START + (0 * 4 + 4)	
	jsr option_0_side_effects
	rts

update_palette:
	inc $0860
	lda $0860
 	CMP #8
	BNE :+	
		LDA #$00
	:
	sta $0860
	TAY	
	LDA option_offsets_0, Y
	sta SNES_OAM_START + (0 * 4 + 4)	
	jsr option_0_side_effects
	rts
option_offsets_1:
	.byte $58, $80, $A8, $D0

decrement_lives:
	dec $0861
	BPL :+
		LDA #4
		DEC A
		STA $0861
	:
	LDA $0861
	TAY	
	LDA option_offsets_1, Y
	sta SNES_OAM_START + (1 * 4 + 4)	
	jsr option_1_side_effects
	rts

update_lives:
	inc $0861
	lda $0861
 	CMP #4
	BNE :+	
		LDA #$00
	:
	sta $0861
	TAY	
	LDA option_offsets_1, Y
	sta SNES_OAM_START + (1 * 4 + 4)	
	jsr option_1_side_effects
	rts
option_offsets_2:
	.byte $58, $A8

decrement_upgrades:
	dec $0862
	BPL :+
		LDA #2
		DEC A
		STA $0862
	:
	LDA $0862
	TAY	
	LDA option_offsets_2, Y
	sta SNES_OAM_START + (2 * 4 + 4)	
	jsr option_2_side_effects
	rts

update_upgrades:
	inc $0862
	lda $0862
 	CMP #2
	BNE :+	
		LDA #$00
	:
	sta $0862
	TAY	
	LDA option_offsets_2, Y
	sta SNES_OAM_START + (2 * 4 + 4)	
	jsr option_2_side_effects
	rts
option_offsets_3:
	.byte $58, $70, $88, $A0, $B8, $D0

decrement_level:
	dec $0863
	BPL :+
		LDA #6
		DEC A
		STA $0863
	:
	LDA $0863
	TAY	
	LDA option_offsets_3, Y
	sta SNES_OAM_START + (3 * 4 + 4)	
	jsr option_3_side_effects
	rts

update_level:
	inc $0863
	lda $0863
 	CMP #6
	BNE :+	
		LDA #$00
	:
	sta $0863
	TAY	
	LDA option_offsets_3, Y
	sta SNES_OAM_START + (3 * 4 + 4)	
	jsr option_3_side_effects
	rts
option_offsets_4:
	.byte $58, $A8

decrement_msu1:
	dec $0864
	BPL :+
		LDA #2
		DEC A
		STA $0864
	:
	LDA $0864
	TAY	
	LDA option_offsets_4, Y
	sta SNES_OAM_START + (4 * 4 + 4)	
	jsr option_4_side_effects
	rts

update_msu1:
	inc $0864
	lda $0864
 	CMP #2
	BNE :+	
		LDA #$00
	:
	sta $0864
	TAY	
	LDA option_offsets_4, Y
	sta SNES_OAM_START + (4 * 4 + 4)	
	jsr option_4_side_effects
	rts
option_offsets_5:
	.byte $58, $78, $98, $B8, $D8

decrement_playlist:
	dec $0865
	BPL :+
		LDA #5
		DEC A
		STA $0865
	:
	LDA $0865
	TAY	
	LDA option_offsets_5, Y
	sta SNES_OAM_START + (5 * 4 + 4)	
	jsr option_5_side_effects
	rts

update_playlist:
	inc $0865
	lda $0865
 	CMP #5
	BNE :+	
		LDA #$00
	:
	sta $0865
	TAY	
	LDA option_offsets_5, Y
	sta SNES_OAM_START + (5 * 4 + 4)	
	jsr option_5_side_effects
	rts


; Which Option are we on sprites
option_sprite_y_pos:
.byte $17
.byte $1F
.byte $27
.byte $2F
.byte $37
.byte $3F
; X, Y, Tile, attributes
options_sprites:
.byte  $04, $17, $3B, $42   ; Option Selection
.byte $58, $17, $3B, $42
.byte $58, $1F, $3B, $42
.byte $58, $27, $3B, $42
.byte $58, $2F, $3B, $42
.byte $58, $37, $3B, $42
.byte $58, $3F, $3B, $42

	.byte 120, 184, $B0, $40 ; tank sprite 1/6
	.byte 128, 184, $A0, $40 ; tank sprite 2/6
	.byte 136, 184, $A5, $20 ; tank sprite 3/6
	.byte 120, 192, $C0, $20 ; tank sprite 4/6
	.byte 128, 192, $E0, $20 ; tank sprite 5/6
	.byte 136, 192, $D0, $20 ; tank sprite 6/6

	.byte 104, 184, $e2, $22 ; Enemy Sprite x/4
	.byte  96, 184, $e1, $22 ; Enemy Sprite x/4
	.byte 104, 192, $e4, $22 ; Enemy Sprite x/4
	.byte  96, 192, $e3, $22 ; Enemy Sprite x/4
	.byte $FF
	