INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "Blink Counter", WRAM0
wBlinkTimer:: db

SECTION "Text", ROM0

BlinkText::
    ld a, [hl]
    and a
    jr z, ReDrawText

CleanText:
    xor a
    ld b, BLINK_TEXT_LEN
CleanLoop:
    ld [hli], a
    dec b
    jr nz, CleanLoop
    ld [wBlinkTimer], a
    ret

ReDrawText:
    ld b, BLINK_TEXT_LEN
DrawLoop:
    ld a, [de]
    ld [hli], a
    inc de
    dec b
    jr nz, DrawLoop
    xor a
    ld [wBlinkTimer], a
    ret