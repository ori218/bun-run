INCLUDE "hardware.inc"
SECTION "VBlankFunctions", ROM0

; Waits for a new VBlank
; @destroys a
WaitForOneVBlank::
.waitEnd: ; wait for the current VBlank to end
    ld a, [rLY]
    cp LY_VBLANK
    jr nc, .waitEnd
.waitStart: ; wait for the next VBlank to begin
    ld a, [rLY]
    cp LY_VBLANK
    jr c, .waitStart
    ret