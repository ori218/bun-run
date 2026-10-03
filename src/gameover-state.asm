INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "GameOverScreen", ROM0

InitGameOverState::
    ld de, GameOverScreenTiles
    ld hl, BG_TILES
    ld bc, GameOverScreenTilesEnd - GameOverScreenTiles
    call MemCopy

    ld de, GameOverScreenTilemap
    ld hl, TILEMAP0
    ld bc, GameOverScreenTilemapEnd - GameOverScreenTilemap
    call MemCopy

    ld hl, GAMEOVER_SCORE_POS
    ld d, GAMEOVER_DIGIT_TILE
    call UpdateScoreBoard

    call UpdateHighScore

    ld a, DEFAULT_PALETTE
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
    cp BLINK_FRAMES
    jr nz, UpdateGameOverState
    ld hl, GAMEOVER_BLINK_TEXT_POS
    ld de, GameOverScreenTilemap + GAMEOVER_BLINK_TEXT_POS - TILEMAP0
    call BlinkText
    jr UpdateGameOverState

.changeToTitleState:
    xor a ; STATE_TITLE
    ld [wGameState], a
    jp NextGameState