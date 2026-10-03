INCLUDE "hardware.inc"

SECTION "GameScreen", ROM0

InitGameplayState::
    ld a, [rDIV]
    ld [randstate], a
    xor a
    ld [randstate + 1], a
    ld [randstate + 2], a
    ld [randstate + 3], a
    
    ld de, Tiles
    ld hl, $9000
    ld bc, TilesEnd - Tiles
    call MemCopy

    ld de, Tilemap
    ld hl, $9800
    ld bc, TilemapEnd - Tilemap
    call MemCopy
    
    ld de, BunnySprite
    ld hl, $8000
    ld bc, BunnySpriteEnd - BunnySprite
	call MemCopy

    ld de, HazardSprite
    ld hl, $8010
    ld bc, HazardSpriteEnd - HazardSprite
    call MemCopy

	xor a
    ld b, 160
    ld hl, STARTOF(OAM)
.clearOAM:
    ld [hli], a
    dec b
    jp nz, .clearOAM

    ld hl, STARTOF(OAM)
    ld a, 116 + 16
    ld [hli], a
    ld a, 76 + 8
    ld [hli], a
    xor a
    ld [hli], a
    ld [hli], a

    call InitializeSpikes

.screenOn:
    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a

    ld a, LCDC_ON | LCDC_BG_ON | LCDC_OBJ_ON
    ld [rLCDC], a

    xor a
    ld [wScoreHigh], a
    ld [wScoreLow], a
    ld a, 90
    ld [wSpawnTimer], a
    
    ret

UpdateGameplayState::
    call WaitForOneVBlank

    call UpdateSpikes
    ld hl, $9828
    ld d, $16
    call UpdateScoreBoard
    call SpawnSpikes

    call UpdateKeys

.checkLeft:
    ld a, [wCurKeys]
    and a, PAD_LEFT
    jr z, .checkRight
.left:
    ld a, [startof(OAM) + 1]
    dec a
    cp a, 76 + 8 - 30
    jp z, UpdateGameplayState
    ld [startof(OAM) + 1], a
    jp UpdateGameplayState

.checkRight:
    ld a, [wCurKeys]
    and a, PAD_RIGHT  
    jp z, UpdateGameplayState
.right:
    ld a, [startof(OAM) + 1]
    inc a
    cp a, 76 + 8 + 30
    jp z, UpdateGameplayState
    ld [startof(OAM) + 1], a
    jp UpdateGameplayState