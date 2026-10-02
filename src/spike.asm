INCLUDE "hardware.inc"

DEF SPIKE_COUNT EQU 10

SECTION "Timer", WRAM0
wSpawnTimer:: db

SECTION "Spike", ROM0

InitializeSpikes::
    ld de, 4
    ld b, SPIKE_COUNT
    ld hl, STARTOF(OAM) + 2
InitializationLoop:
    add hl, de
    ld [hl], 1
    dec b
    jr nz, InitializationLoop
    ret

SpawnSpikes::
    ld a, [wSpawnTimer]
    dec a
    ld [wSpawnTimer], a
    jr nz, SpawnEnd
    
    ld b, SPIKE_COUNT + 1
    ld de, 4
    ld hl, STARTOF(OAM)
FindInactive:
    add hl, de
    ld a, [hl]
    dec b
    jr z, SpawnEnd
    and a
    jr nz, FindInactive

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
    ld a, [wSpawnTimer]
    and a
    ret nz
    inc a
    ld [wSpawnTimer], a
    ret

UpdateSpikes::
    ld b, SPIKE_COUNT
    ld de, 4
    ld hl, startof(OAM) + 4
UpdateSpikesLoop:
    ld a, [hl]
    and a
    jr z, NextSpike ; inactive

    push hl
    call CollisionCheck
    pop hl

    ld a, [hl] 
    inc a
    cp a, 117 + 16
    jr c, NextSpike
    push hl
    call IncreaseScorePackedBCD
    pop hl
    xor a

NextSpike:
    ld [hl], a
    add hl, de
    dec b
    jr nz, UpdateSpikesLoop
    ret

CollisionCheck:
    ld a, [STARTOF(OAM)]
    sub [hl]
    add 6
    cp 13
    ret nc

    inc hl
    ld a, [STARTOF(OAM) + 1]
    sub a, [hl]
    add 6
    cp 12
    jr c, DeathLoop
    ret

DeathLoop:
    jr DeathLoop