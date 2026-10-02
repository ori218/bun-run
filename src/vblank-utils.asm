INCLUDE "hardware.inc"
SECTION "VBlankFunctions", ROM0

WaitForOneVBlank::
.waitEnd:
    ld a, [rLY]
    cp 144
    jr nc, .waitEnd
.waitStart:
    ld a, [rLY]
    cp 144
    jr c, .waitStart
    ret