INCLUDE "hardware.inc"
INCLUDE "constants.inc"

SECTION "GameVariables", WRAM0
wGameState::db

SECTION "Header", ROM0[$100]
    jp EntryPoint
    ds $150 - @, 0 

EntryPoint:
    xor a
	ld [rNR52], a
    ld [wGameState], a
    ld [wCurKeys], a
    ld [wNewKeys], a

	call CheckAndInitSaveData

NextGameState::
    ld sp, STACK_TOP
    call WaitForOneVBlank

    xor a
	ld [rLCDC], a
    ld [wBlinkTimer], a

    ld a, [wGameState]
	cp STATE_GAMEOVER
	call z, InitGameOverState
	ld a, [wGameState]
	cp STATE_GAMEPLAY
	call z, InitGameplayState
	ld a, [wGameState]
	and a ; STATE_TITLE
	call z, InitTitleScreenState

	; Update the next state
	ld a, [wGameState]
	cp STATE_GAMEOVER
	jp z, UpdateGameOverState
	cp STATE_GAMEPLAY
	jp z, UpdateGameplayState
	jp UpdateTitleScreenState