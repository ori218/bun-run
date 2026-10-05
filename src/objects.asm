INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "Timers", WRAM0
wSpikeSpawnTimer:: db
wCoinSpawnTimer:: db

SECTION "Spike", ROM0

; Initialize a set of objects into OAM.
; @param hl: OAM address of the first slot.
; @param b: number of slots.
; @param c: tile ID to give every slot.
; @destroys  b, de, hl
InitializeObjects::
    ld de, OBJ_SIZE
.initializationLoop:
    ld [hl], c
    add hl, de
    dec b
    jr nz, .initializationLoop
    ret

; Spawn first inactive object in OAM
; @param hl: Spawn Timer for object
; @param b: number of object to spawn
; @param c: the OAM object before the first object to spawn
; @param d: spawn delay range mask
; @param e: min spawn delay
; @destroys  a, b, c, de, hl
SpawnObjects::
    dec [hl]
    jr nz, .spawnEnd

    push hl ; timer pointer
    push de ; delay mask / min

    inc b
    ld de, OBJ_SIZE
    ld h, HIGH(STARTOF(OAM))
    ld l, c
.findInactive:
    add hl, de
    ld a, [hl]
    dec b
    jr z, .noSlot
    and a
    jr nz, .findInactive

    push hl ; free slot
.randX:
    call rand
    and OBJ_X_MASK
    cp OBJ_X_RANGE
    jr nc, .randX
    add a, OBJ_MIN_X + OAM_X_OFS
    ld d, a
    pop hl  ; free slot
    ld a, ACTIVE_SPAWN_Y
    ld [hli], a
    ld [hl], d

    call rand
    pop de ; delay mask / min
    pop hl ; timer pointer
    and d
    add a, e
    ld [hl], a
.spawnEnd:
    ret

.noSlot:
    pop de
    pop hl ; timer pointer
    ld [hl], 1 ; try again next frame
    ret


UpdateSpikes::
    ld b, SPIKE_COUNT
    ld de, OBJ_SIZE
    ld hl, STARTOF(OAM) + OBJ_SIZE * SPIKE_FIRST_SLOT
.updateSpikesLoop:
    ld a, [hl]
    and a
    jr z, .nextSpike ; inactive

    push hl
    call CollisionCheck
    jp c, .changeToGameOverState
    pop hl

    ld a, [hl] 
    add a, SPIKE_SPEED
    cp a, FLOOR_Y + OAM_Y_OFS
    jr c, .nextSpike
    push bc
    push hl
    ld b, SPIKE_POINTS
    call AddScoreBCD
    pop hl
    pop bc
    xor a

.nextSpike:
    ld [hl], a
    add hl, de
    dec b
    jr nz, .updateSpikesLoop
    ret

.changeToGameOverState:
    ld a, STATE_GAMEOVER
    ld [wGameState], a
    jp NextGameState

UpdateCoins::
    ld b, COIN_COUNT
    ld de, OBJ_SIZE
    ld hl, STARTOF(OAM) + OBJ_SIZE  * COIN_FIRST_SLOT
.updateCoinsLoop:
    ld a, [hl]
    and a
    jr z, .nextCoin ; inactive

    push hl
    call CollisionCheck
    pop hl
    jr c, .collected

    ld a, [hl] 
    add a, COIN_SPEED
    cp a, FLOOR_Y + OAM_Y_OFS
    jr c, .nextCoin
    xor a

.nextCoin:
    ld [hl], a
    add hl, de
    dec b
    jr nz, .updateCoinsLoop
    ret

.collected:
    push bc
    push hl
    ld b, COIN_POINTS
    call AddScoreBCD
    pop hl
    pop bc
    xor a ; despawn the collected coin
    jr .nextCoin

CollisionCheck:
    ld a, [STARTOF(OAM)]
    sub [hl]
    add HITBOX_OFFSET
    cp HITBOX_HEIGHT
    ret nc
    inc hl
    ld a, [STARTOF(OAM) + OAMA_X]
    sub [hl]
    add HITBOX_OFFSET
    cp HITBOX_WIDTH
    ret