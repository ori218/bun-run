INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "Timer", WRAM0
wSpawnTimer:: db

SECTION "Spike", ROM0

InitializeSpikes::
    ld de, OBJ_SIZE
    ld b, SPIKE_COUNT
    ld hl, STARTOF(OAM) + OAMA_TILEID
.initializationLoop:
    add hl, de
    ld [hl], SPIKE_TILE
    dec b
    jr nz, .initializationLoop
    ret

SpawnSpikes::
    ld a, [wSpawnTimer]
    dec a
    ld [wSpawnTimer], a
    jr nz, .spawnEnd
    
    ld b, SPIKE_COUNT + 1
    ld de, OBJ_SIZE
    ld hl, STARTOF(OAM)
.findInactive:
    add hl, de
    ld a, [hl]
    dec b
    jr z, .spawnEnd
    and a
    jr nz, .findInactive

    push hl
.randX:
    call rand
    and SPIKE_X_MASK
    cp SPIKE_X_RANGE
    jr nc, .randX
    add a, SPIKE_MIN_X + OAM_X_OFS
    ld d, a
    pop hl
    
    ld a, SPIKE_SPAWN_Y
    ld [hli], a
    ld [hl], d

    call rand
    and SPAWN_DELAY_MASK
    add a, SPAWN_DELAY_MIN
    ld [wSpawnTimer], a
.spawnEnd:
    ld a, [wSpawnTimer]
    and a
    ret nz
    inc a
    ld [wSpawnTimer], a
    ret

UpdateSpikes::
    ld b, SPIKE_COUNT
    ld de, OBJ_SIZE
    ld hl, STARTOF(OAM) + OBJ_SIZE
.updateSpikesLoop:
    ld a, [hl]
    and a
    jr z, .nextSpike ; inactive

    push hl
    call CollisionCheck
    pop hl

    ld a, [hl] 
    add a, SPIKE_SPEED
    cp a, SPIKE_FLOOR_Y + OAM_Y_OFS
    jr c, .nextSpike
    push hl
    call IncreaseScorePackedBCD
    pop hl
    xor a

.nextSpike:
    ld [hl], a
    add hl, de
    dec b
    jr nz, .updateSpikesLoop
    ret

CollisionCheck:
    ld a, [STARTOF(OAM)]
    sub [hl]
    add HITBOX_OFFSET
    cp HITBOX_HEIGHT
    ret nc

    inc hl
    ld a, [STARTOF(OAM) + OAMA_X]
    sub a, [hl]
    add HITBOX_OFFSET
    cp HITBOX_WIDTH
    jp c, .changeToGameOverState
    ret
.changeToGameOverState:
    ld a, STATE_GAMEOVER
    ld [wGameState], a
    jp NextGameState