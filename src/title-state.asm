INCLUDE "hardware.inc"

SECTION "TitleScreen", ROM0

InitTitleScreenState::
    xor a
    ld [wBlinkTimer], a
    
    ld de, TitleScreenTiles
    ld hl, $9000
    ld bc, TitleScreenTilesEnd - TitleScreenTiles
    call MemCopy

    ld de, TitleScreenTilemap
    ld hl, $9800
    ld bc, TitleScreenTilemapEnd - TitleScreenTilemap
    call MemCopy

    ld a, %11100100
    ld [rBGP], a

    ld a, LCDC_ON | LCDC_BG_ON
    ld [rLCDC], a
    ret

UpdateTitleScreenState::

    call WaitForOneVBlank

    call UpdateKeys
    ld a, [wNewKeys]
    and PAD_START
    jr nz, .changeToGameplayState

    ld a, [wBlinkTimer]
    inc a
    ld [wBlinkTimer], a
    cp 65
    jp nz, UpdateTitleScreenState
    ld hl, $9945
    ld de, TitleScreenTilemap + 10 * 32 + 5
    call BlinkText
    jp UpdateTitleScreenState

.changeToGameplayState:
    ld a, 1
    ld [wGameState], a
    jp NextGameState