INCLUDE "hardware.inc"

DEF SPIKE_COUNT EQU 10

SECTION "Timer", WRAM0
wSpawnTimer:: db

SECTION "Spike", ROM0

InitializeSpikes::
    ld b, SPIKE_COUNT
    ld hl, STARTOF(OAM) + 4
InitializationLoop:
    ld a, 0
    ld [hli], a
    ld [hli], a
    ld a, 1
    ld [hli], a
    ld a, 0
    ld [hli], a
    dec b
    jp nz, InitializationLoop
    ret

SpawnSpikes::
    ld a, [wSpawnTimer]
    dec a
    ld [wSpawnTimer], a
    and a
    jr nz, SpawnEnd
    
    ld b, SPIKE_COUNT + 1
    ld de, 4
    ld hl, STARTOF(OAM)
FindInactive:
    add hl, de
    ld a, [hl]
    dec b
    jp z, SpawnEnd
    and a
    jp nz, FindInactive

    push hl
RandX:
    call rand
    and %00111111
    cp 61
    jr nc, RandX
    add a, 54
    ld d, a
    pop hl
    
    ld a, 1
    ld [hli], a
    ld [hl], d

    call rand
    and %00001111
    add a, 10
    ld [wSpawnTimer], a
SpawnEnd:
    ret

UpdateSpikes::
    ld b, SPIKE_COUNT
    ld de, 4
    ld hl, startof(OAM) + 4
UpdateSpikesLoop:
    ld a, [hl]
    and a 
    jr z, NextSpike ; inactive
    inc a
    cp a, 117 + 16
    jr c, NextSpike
    ld a, 0
NextSpike:
    ld [hl], a
    add hl, de
    dec b
    jp nz, UpdateSpikesLoop
    ret