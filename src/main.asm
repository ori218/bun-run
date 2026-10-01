INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0 

EntryPoint:
	
WaitVBlank:
    ld a, [rLY]
    cp 144
    jp c, WaitVBlank

LoadGame:
    ld a, 0
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

	ld a, 0
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
    ld a, 0
    ld [hli], a
    ld [hli], a

    call InitializeSpikes

ScreenOn:
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_OBJ_ON
    ld [rLCDC], a

    ld a, %11100100
    ld [rBGP], a
    ld [rOBP0], a

    ld a, 0
	ld [wCurKeys], a
    ld [wNewKeys], a
    ld a, 90
    ld [wSpawnTimer], a

Main:
    ld a, [rLY]
	cp 144
	jp nc, Main
WaitVBlank2:
	ld a, [rLY]
	cp 144
	jp c, WaitVBlank2

    call UpdateSpikes
    call SpawnSpikes

    call UpdateKeys

CheckLeft:
    ld a, [wCurKeys]
    and a, PAD_LEFT
    jp z, ChackRight
Left:
    ld a, [startof(OAM) + 1]
    dec a
    cp a, 76 + 8 - 30
    jp z, Main
    ld [startof(OAM) + 1], a
    jp Main

ChackRight:
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