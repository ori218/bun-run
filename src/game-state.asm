INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "Frame Counter", WRAM0
wFrameCounter:: db

SECTION "GameScreen", ROM0

InitGameplayState::
    ld a, [rDIV]
    ld [randstate], a
    xor a
    ld [randstate + 1], a
    ld [randstate + 2], a
    ld [randstate + 3], a
    
    ld de, Tiles
    ld hl, BG_TILES
    ld bc, TilesEnd - Tiles
    call MemCopy

    ld de, Tilemap
    ld hl, TILEMAP0
    ld bc, TilemapEnd - Tilemap
    call MemCopy
    
    ld de, BunnySprite
    ld hl, OBJ_TILES
    ld bc, BunnySpriteEnd - BunnySprite
	call MemCopy

    ld de, HazardSprite
    ld hl, OBJ_TILES + SPIKE_TILE * TILE_SIZE
    ld bc, HazardSpriteEnd - HazardSprite
    call MemCopy

    ld de, Coin
    ld hl, OBJ_TILES + COIN_TILE * TILE_SIZE
    ld bc, CoinEnd - Coin
    call MemCopy

	xor a
    ld b, OAM_SIZE
    ld hl, STARTOF(OAM)
.clearOAM:
    ld [hli], a
    dec b
    jp nz, .clearOAM

    ld hl, STARTOF(OAM)
    ld a, PLAYER_START_Y + OAM_Y_OFS
    ld [hli], a
    ld a, PLAYER_START_X + OAM_X_OFS
    ld [hli], a
    xor a
    ld [hli], a
    ld [hli], a

    ld hl, STARTOF(OAM) + OBJ_SIZE * SPIKE_FIRST_SLOT + OAMA_TILEID
    ld b, SPIKE_COUNT
    ld c, SPIKE_TILE
    call InitializeObjects

    ld hl, STARTOF(OAM) + OBJ_SIZE * COIN_FIRST_SLOT + OAMA_TILEID
    ld b, COIN_COUNT
    ld c, COIN_TILE
    call InitializeObjects

.screenOn:
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_OBJ_ON
    ld [rLCDC], a

    xor a
    ld [wScoreHigh], a
    ld [wScoreLow], a
    ld a, FIRST_SPIKE_DELAY
    ld [wSpikeSpawnTimer], a
    ld a, FIRST_COIN_DELAY
    ld [wCoinSpawnTimer], a
    
    ret

UpdateGameplayState::
    call WaitForOneVBlank

    ld hl, wFrameCounter
    inc [hl]
    ld a, [hl]
    cp 60
    jr nz, .update
    ld b, POINTS_PER_SECOND
    call AddScoreBCD
    xor a
    ld [wFrameCounter], a

.update:
    call UpdateSpikes
    call UpdateCoins
    ld hl, GAME_SCORE_POS
    ld d, GAME_DIGIT_TILE
    call UpdateScoreBoard
    
    ld hl, wSpikeSpawnTimer
    ld b, SPIKE_COUNT
    ld c, LOW(STARTOF(OAM) + OBJ_SIZE * (SPIKE_FIRST_SLOT - 1))
    ld d, SPIKE_DELAY_MASK
    ld e, SPIKE_DELAY_MIN
    call SpawnObjects

    ld hl, wCoinSpawnTimer
    ld b, COIN_COUNT
    ld c, LOW(STARTOF(OAM) + OBJ_SIZE * (COIN_FIRST_SLOT - 1))
    ld d, COIN_DELAY_MASK
    ld e, COIN_DELAY_MIN
    call SpawnObjects

    call UpdateKeys

.checkLeft:
    ld a, [wCurKeys]
    and a, PAD_LEFT
    jr z, .checkRight
.left:
    ld a, [STARTOF(OAM) + OAMA_X]
    dec a
    cp a, PLAYER_MIN_X + OAM_X_OFS
    jp z, UpdateGameplayState
    ld [STARTOF(OAM) + OAMA_X], a
    jp UpdateGameplayState

.checkRight:
    ld a, [wCurKeys]
    and a, PAD_RIGHT  
    jp z, UpdateGameplayState
.right:
    ld a, [STARTOF(OAM) + OAMA_X]
    inc a
    cp a, PLAYER_MAX_X + OAM_X_OFS
    jp z, UpdateGameplayState
    ld [STARTOF(OAM) + OAMA_X], a
    jp UpdateGameplayState