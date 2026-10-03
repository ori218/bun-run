INCLUDE "hardware.inc"

DEF DIGIT_START EQU $9828
DEF DIGIT_OFFSET EQU $16


SECTION "Counter", WRAM0
wScoreLow:: db
wScoreHigh:: db

SECTION "Score", ROM0

UpdateScoreBoard::
    ld a, [wScoreHigh]
    and %11110000
    swap a
    add a, d 
    ld [hli], a

    ld a, [wScoreHigh]
    and %00001111
    add a, d
    ld [hli], a

    ld a, [wScoreLow]
    and %11110000
    swap a
    add a, d 
    ld [hli], a

    ld a, [wScoreLow]
    and %00001111
    add a, d
    ld [hl], a

    ret

IncreaseScorePackedBCD::
    ld hl, wScoreLow
    ld a, [hl]
    add 1
    daa
    ld [hl], a
    ld hl, wScoreHigh
    ld a, [hl]
    adc a, 0
    daa
    ld [hl], a
    ret

LoadHighScore::
    ld a, RAMG_SRAM_ENABLE
    ld [rRAMG], a

    ld a, [sHighScoreHigh]
    ld [wScoreHigh], a
    ld a, [sHighScoreLow]
    ld [wScoreLow], a

    ld a, RAMG_SRAM_DISABLE
    ld [rRAMG], a
    ret

UpdateHighScore::
    ld a, RAMG_SRAM_ENABLE
    ld [rRAMG], a

    ld a, [sHighScoreHigh]
    ld b, a
    ld a, [wScoreHigh]
    cp b
    jr c, .notHigher
    jr nz, .newHighScore

    ld a, [sHighScoreLow]
    ld b, a
    ld a, [wScoreLow]
    cp b
    jr c, .notHigher
    jr z, .notHigher 

.newHighScore:
    ld a, [wScoreHigh]
    ld [sHighScoreHigh], a

    ld a, [wScoreLow]
    ld [sHighScoreLow], a

.notHigher:
    ld a, RAMG_SRAM_DISABLE
    ld [rRAMG], a
    ret
