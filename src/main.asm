INCLUDE "hardware.inc"

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
    ld sp, $FFFE
    call WaitForOneVBlank

    xor a
	ld [rLCDC], a
    ld [wBlinkTimer], a

    ld a, [wGameState]
	cp 2 ; 2 = GameOver
	call z, InitGameOverState
	ld a, [wGameState]
	cp 1 ; 1 = Gameplay
	call z, InitGameplayState
	ld a, [wGameState]
	and a ; 0 = Title
	call z, InitTitleScreenState

	; Update the next state
	ld a, [wGameState]
	cp 2 ; 2 = GameOver
	jp z, UpdateGameOverState
	cp 1 ; 1 = Gameplay
	jp z, UpdateGameplayState
	jp UpdateTitleScreenState