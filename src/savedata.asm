INCLUDE "hardware.inc"

SECTION "SaveVariables", SRAM

sHighScoreLow:: db
sHighScoreHigh:: db
sCheckSum1:: db
sCheckSum2:: db
sCheckSum3:: db


SECTION "SaveData", ROM0

CheckAndInitSaveData::
    ld a, RAMG_SRAM_ENABLE
    ld [rRAMG], a

    ld a, [sCheckSum1]
    cp 100
    jr nz, .init

    ld a, [sCheckSum2]
    cp 150
    jr nz, .init

    ld a, [sCheckSum3]
    cp 200
    jr nz, .init

    jr .end

.init:
    ld a, 100
    ld [sCheckSum1], a

    ld a, 150
    ld [sCheckSum2], a

    ld a, 200
    ld [sCheckSum3], a

    xor a
    ld [sHighScoreLow], a
    ld [sHighScoreHigh], a

.end:
    ld a, RAMG_SRAM_DISABLE
    ld [rRAMG], a

    ret