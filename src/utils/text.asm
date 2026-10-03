INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "Blink Counter", WRAM0
wBlinkTimer:: db

SECTION "Text", ROM0


; Alternates between drawing and clearing a line of text for a blinking effect.
; Resets wBlinkTimer. Must be called during VBlank. The first tile of the text must not be blank (tile 0).
; @param hl: tilemap address of the text (BLINK_TEXT_LEN tiles)
; @param de: ROM address of the text's original tile IDs
; @destroys a, b, de(when redrawing), hl
BlinkText::
    ld a, [hl]
    and a ; check first tile is 0 (blank) while the text is hidden.
    jr z, .reDrawText ; if hidden redraw it.

.clearText:
    xor a
    ld b, BLINK_TEXT_LEN
.clearLoop: ; loops over the text and clears it.
    ld [hli], a
    dec b
    jr nz, .clearLoop
    jr .return

.reDrawText:
    ld b, BLINK_TEXT_LEN
.drawLoop: ; loads the correct tile and redraws the text.
    ld a, [de]
    ld [hli], a
    inc de
    dec b
    jr nz, .drawLoop
    xor a

.return: ; reset blink timer
    ld [wBlinkTimer], a
    ret