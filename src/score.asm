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