INCLUDE "hardware.inc"

SECTION "GameOverScreen", ROM0

InitGameOverState::
    ld de, GameOverScreenTiles
    ld hl, $9000
    ld bc, GameOverScreenTilesEnd - GameOverScreenTiles
    call MemCopy

    ld de, GameOverScreenTilemap
    ld hl, $9800
    ld bc, GameOverScreenTilemapEnd - GameOverScreenTilemap
    call MemCopy

    ld hl, $996B
    ld d, $09
    call UpdateScoreBoard

    ld a, %11100100
    ld [rBGP], a

    ld a, LCDC_ON | LCDC_BG_ON
    ld [rLCDC], a
    ret

UpdateGameOverState::
    call WaitForOneVBlank

    call UpdateKeys
    ld a, [wNewKeys]
    and PAD_START
    jr nz, .changeToTitleState
    ld a, [wBlinkTimer]
    inc a
    ld [wBlinkTimer], a
    cp 65
    jr nz, UpdateGameOverState
    ld hl, $99A5
    ld de, GameOverScreenTilemap + 13 * 32 + 5
    call BlinkText
    jr UpdateGameOverState

.changeToTitleState:
    xor a
    ld [wGameState], a
    jp NextGameState