extends Node

# Group names for different groups of nodes.
const GROUP_MENUS := "menus"
const GROUP_SIDESCROLLERS := "sidescrollers"
const GROUP_ENEMIES := "enemies"

# State IDs of our state machine states
const STATE_EXIT := ""
const STATE_MENU_MAIN := "menu_main"
const STATE_MENU_SETTINGS := "menu_settings"
const STATE_MENU_PAUSE := "menu_pause"
const STATE_GAME_INTRO := "game_intro"
const STATE_GAME := "game"
const STATE_GAME_OVER := "game_over"

# Names of audio busses
const MUSIC_BUS := "Music"
const SOUND_BUS := "Sounds"

# Base speed of EndlessSidescrollers while in the menu.
const BASE_SPEED_MENU := 15
# Base speed of EndlessSidescrollers while in the game.
const BASE_SPEED_GAME := 50

# The maximum width of our enemies. Used to compute the width of enemy spawn zones.
const MAX_ENEMY_WIDTH := 10
