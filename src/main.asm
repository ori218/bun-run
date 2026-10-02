INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
    jr EntryPoint
    ds $150 - @, 0 

EntryPoint:
	
WaitVBlank:
    ld a, [rLY]
    cp 144
    jr c, WaitVBlank

LoadTitleScreen:
    xor a
    ld [rLCDC], a

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

    xor a
    ld [wCurKeys], a
    ld [wNewKeys], a
    ld [wBlinkTimer], a

TitleLoop:
    ld a, [rLY]
	cp 144
	jr nc, TitleLoop
WaitVBlank2:
	ld a, [rLY]
	cp 144
	jr c, WaitVBlank2

    call UpdateKeys
    ld a, [wNewKeys]
    and PAD_START
    jr nz, LoadGameScreen
    ld a, [wBlinkTimer]
    inc a
    ld [wBlinkTimer], a
    cp 90
    jp nz, TitleLoop
    ld hl, $9945
    ld de, TitleScreenTilemap + 10 * 32 + 5
    call BlinkText
    jp TitleLoop


LoadGameScreen:
    ld a, [rDIV]
    ld [randstate], a

    xor a
    ld [rLCDC], a

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
ClearOam:
    ld [hli], a
    dec b
    jp nz, ClearOam

    ld hl, STARTOF(OAM)
    ld a, 116 + 16
    ld [hli], a
    ld a, 76 + 8
    ld [hli], a
    xor a
    ld [hli], a
    ld [hli], a

    call InitializeSpikes

ScreenOn:
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_OBJ_ON
    ld [rLCDC], a

    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a

    xor a
	ld [wCurKeys], a
    ld [wNewKeys], a
    ld [wScoreHigh], a
    ld [wScoreLow], a
    ld a, 90
    ld [wSpawnTimer], a

Main:
    ld a, [rLY]
	cp 144
	jr nc, Main
WaitVBlank3:
	ld a, [rLY]
	cp 144
	jr c, WaitVBlank3

    call UpdateSpikes
    call UpdateScoreBoard
    call SpawnSpikes

    call UpdateKeys

CheckLeft:
    ld a, [wCurKeys]
    and a, PAD_LEFT
    jr z, CheckRight
Left:
    ld a, [startof(OAM) + 1]
    dec a
    cp a, 76 + 8 - 30
    jp z, Main
    ld [startof(OAM) + 1], a
    jp Main

CheckRight:
    ld a, [wCurKeys]
    and a, PAD_RIGHT  
    jp z, Main
Right:
    ld a, [startof(OAM) + 1]
    inc a
    cp a, 76 + 8 + 30
    jp z, Main
    ld [startof(OAM) + 1], a
    jp Main

LoadGameOverScreen::
    xor a
    ld [rLCDC], a

    ld de, GameOverScreenTiles
    ld hl, $9000
    ld bc, GameOverScreenTilesEnd - GameOverScreenTiles
    call MemCopy

    ld de, GameOverScreenTilemap
    ld hl, $9800
    ld bc, GameOverScreenTilemapEnd - GameOverScreenTilemap
    call MemCopy

    ld a, %11100100
    ld [rBGP], a

    ld a, LCDC_ON | LCDC_BG_ON
    ld [rLCDC], a
GameOverLoop:
    ld a, [rLY]
	cp 144
	jr nc, GameOverLoop
WaitVBlank4:
	ld a, [rLY]
	cp 144
	jr c, WaitVBlank4

    call UpdateKeys
    ld a, [wNewKeys]
    and PAD_START
    jp nz, LoadTitleScreen
    ld a, [wBlinkTimer]
    inc a
    ld [wBlinkTimer], a
    cp 90
    jp nz, GameOverLoop
    ld hl, $9985
    ld de, GameOverScreenTilemap + 12 * 32 + 5
    call BlinkText
    jp GameOverLoop