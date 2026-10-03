IF !DEF(CONSTANTS_INC)
DEF CONSTANTS_INC EQU 1

; VRAM
DEF OBJ_TILES EQU $8000 ; sprite tile data
DEF BG_TILES  EQU $9000 ; background tile data

DEF STACK_TOP EQU $FFFE

; Screen positions (TILEMAP0 + row * TILEMAP_WIDTH + column)
DEF GAME_SCORE_POS          EQU TILEMAP0 +  1 * TILEMAP_WIDTH +  8
DEF TITLE_HIGH_SCORE_POS    EQU TILEMAP0 + 10 * TILEMAP_WIDTH + 12
DEF TITLE_BLINK_TEXT_POS    EQU TILEMAP0 + 12 * TILEMAP_WIDTH +  5
DEF GAMEOVER_SCORE_POS      EQU TILEMAP0 + 11 * TILEMAP_WIDTH + 11
DEF GAMEOVER_BLINK_TEXT_POS EQU TILEMAP0 + 13 * TILEMAP_WIDTH +  5

; Tile ID of the "0" digit in each screen's tileset
DEF GAME_DIGIT_TILE     EQU $16
DEF TITLE_DIGIT_TILE    EQU $32
DEF GAMEOVER_DIGIT_TILE EQU $09

; Shared screen values
DEF DEFAULT_PALETTE EQU %11_10_01_00 ; black, dark, light, white
DEF BLINK_FRAMES    EQU 65 ; frames between blink text toggles
DEF BLINK_TEXT_LEN  EQU 10 ; tiles in the blinking text

; Player (screen pixels, without the OAM offsets)
DEF PLAYER_START_Y    EQU 116
DEF PLAYER_START_X    EQU 76
DEF PLAYER_MOVE_RANGE EQU 30 ; how far the player can move left/right from the start
DEF PLAYER_MIN_X      EQU PLAYER_START_X - PLAYER_MOVE_RANGE
DEF PLAYER_MAX_X      EQU PLAYER_START_X + PLAYER_MOVE_RANGE

; Spikes
DEF SPIKE_COUNT   EQU 7
DEF SPIKE_TILE    EQU 1   ; tile ID of the spike sprite
DEF SPIKE_SPAWN_Y EQU 1   ; Y = 0 marks a spike as inactive, so spawn just below it
DEF SPIKE_FLOOR_Y EQU 117 ; spike scores and despawns when it falls past this
DEF SPIKE_SPEED   EQU 2   ; pixels per frame

; Spikes spawn anywhere the player can move
DEF SPIKE_MIN_X   EQU PLAYER_MIN_X
DEF SPIKE_X_RANGE EQU PLAYER_MAX_X - PLAYER_MIN_X + 1
DEF SPIKE_X_MASK  EQU %00111111 ; random number mask, must cover SPIKE_X_RANGE
ASSERT SPIKE_X_MASK >= SPIKE_X_RANGE - 1

; Spawn timer (in frames)
DEF FIRST_SPAWN_DELAY EQU 90
DEF SPAWN_DELAY_MIN   EQU 10
DEF SPAWN_DELAY_MASK  EQU %00011111 ; random extra delay between spikes, 0-31

; Collision between player and spike
DEF HITBOX_OFFSET EQU 6
DEF HITBOX_HEIGHT EQU 13
DEF HITBOX_WIDTH  EQU 13

; BCD digit masks
DEF HIGH_NIBBLE EQU %11110000
DEF LOW_NIBBLE  EQU %00001111

; Save data validation checksum
DEF SAVE_CHECKSUM_1 EQU 100
DEF SAVE_CHECKSUM_2 EQU 150
DEF SAVE_CHECKSUM_3 EQU 200

; Game states
DEF STATE_TITLE    EQU 0 
DEF STATE_GAMEPLAY EQU 1
DEF STATE_GAMEOVER EQU 2
ASSERT STATE_TITLE == 0

ENDC
