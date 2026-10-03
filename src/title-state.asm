INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "TitleScreen", ROM0

InitTitleScreenState::
    xor a
    ld [wBlinkTimer], a
    
    ld de, TitleScreenTiles
    ld hl, BG_TILES
    ld bc, TitleScreenTilesEnd - TitleScreenTiles
    call MemCopy

    ld de, TitleScreenTilemap
    ld hl, TILEMAP0
    ld bc, TitleScreenTilemapEnd - TitleScreenTilemap
    call MemCopy

    call LoadHighScore

    ld hl, TITLE_HIGH_SCORE_POS
    ld d, TITLE_DIGIT_TILE
    call UpdateScoreBoard

    ld a, DEFAULT_PALETTE
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
    cp BLINK_FRAMES
    jp nz, UpdateTitleScreenState
    ld hl, TITLE_BLINK_TEXT_POS
    ld de, TitleScreenTilemap + TITLE_BLINK_TEXT_POS - TILEMAP0
    call BlinkText
    jp UpdateTitleScreenState

.changeToGameplayState:
    ld a, STATE_GAMEPLAY
    ld [wGameState], a
    jp NextGameState