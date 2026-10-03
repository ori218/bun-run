INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "SaveVariables", SRAM

sHighScoreLow:: db
sHighScoreHigh:: db
sCheckSum1:: db
sCheckSum2:: db
sCheckSum3:: db

SECTION "SaveData", ROM0

; Checks the 3 magic bytes to determine if the save file is valid or if it needs to be reset.
; Call once at startup.
; @destroys a
CheckAndInitSaveData::
    ld a, RAMG_SRAM_ENABLE
    ld [rRAMG], a

    ld a, [sCheckSum1]
    cp SAVE_CHECKSUM_1
    jr nz, .init

    ld a, [sCheckSum2]
    cp SAVE_CHECKSUM_2
    jr nz, .init

    ld a, [sCheckSum3]
    cp SAVE_CHECKSUM_3
    jr nz, .init

    jr .end

.init: ; loads all magic bytes values and resets score
    ld a, SAVE_CHECKSUM_1
    ld [sCheckSum1], a

    ld a, SAVE_CHECKSUM_2
    ld [sCheckSum2], a

    xor a
    ld [sHighScoreLow], a
    ld [sHighScoreHigh], a

    ld a, SAVE_CHECKSUM_3
    ld [sCheckSum3], a

.end:
    ld a, RAMG_SRAM_DISABLE
    ld [rRAMG], a

    ret