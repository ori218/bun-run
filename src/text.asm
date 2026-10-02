INCLUDE "hardware.inc"

SECTION "Blink Counter", WRAM0
wBlinkTimer:: db

SECTION "Text", ROM0

BlinkText::
    ld hl, $9945
    ld a, [hl]
    and a
    jr z, ReDrawText

CleanText:
    xor a
    ld b, 10
CleanLoop:
    ld [hli], a
    dec b
    jr nz, CleanLoop
    ld [wBlinkTimer], a
    ret

ReDrawText:
    ld de, TitleScreenTilemap + 10 * 32 + 5
    ld b, 10
DrawLoop:
    ld a, [de]
    ld [hli], a
    inc de
    dec b
    jr nz, DrawLoop
    xor a
    ld [wBlinkTimer], a
    ret