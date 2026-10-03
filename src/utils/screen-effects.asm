INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "Screen Effects", ROM0

FadePalettes:
    db DEFAULT_PALETTE
    db (DEFAULT_PALETTE << 2) & $FF
    db (DEFAULT_PALETTE << 4) & $FF
    db WHITE_PALETTE
FadePalettesEnd:

; Fades in from WHITE_PALETTE to DEFAULT_PALETTE
; @destroys a, b, hl
FadeIn::
    ld hl, FadePalettesEnd - 2
    xor a ; sets current color to white
    ld [rBGP], a
    ld [rOBP0], a
.fadeLoop:
    ld b, FADE_STEP_FRAMES
.wait: ; waits FADE_STEP_FRAMES frames before moveing on to the next fade step
    call WaitForOneVBlank
    dec b
    jr nz, .wait
.switch:
    ld a, [hld]
    ld [rBGP], a
    ld [rOBP0], a
    cp DEFAULT_PALETTE
    jp z, .end
    jr .fadeLoop
.end:
    ret

; Fades out from DEFAULT_PALETTE to WHITE_PALETTE
; @destroys a, b, hl
FadeOut::
    ld hl, FadePalettes + 1
    ld a, DEFAULT_PALETTE ; sets current color to DEFAULT_PALETTE
    ld [rBGP], a
    ld [rOBP0], a
.fadeLoop:
    ld b, FADE_STEP_FRAMES
.wait:; waits FADE_STEP_FRAMES frames before moveing on to the next fade step
    call WaitForOneVBlank
    dec b
    jr nz, .wait
.switch:
    ld a, [hli]
    ld [rBGP], a
    ld [rOBP0], a
    and a ; compers a to WHITE_PALETTE
    jp z, .end
    jr .fadeLoop
.end:
    ret