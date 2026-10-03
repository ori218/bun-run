INCLUDE "hardware.inc"
SECTION "VBlankFunctions", ROM0

WaitForOneVBlank::
.waitEnd:
    ld a, [rLY]
    cp LY_VBLANK
    jr nc, .waitEnd
.waitStart:
    ld a, [rLY]
    cp LY_VBLANK
    jr c, .waitStart
    ret