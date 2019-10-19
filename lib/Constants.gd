extends Node

# The group all menu scenes are in.
const GROUP_MENUS := "menus"

# State IDs of our state machine states
const STATE_EXIT := ""
const STATE_MENU_MAIN := "menu_main"
const STATE_MENU_SETTINGS := "menu_settings"
const STATE_MENU_PAUSE := "menu_pause"
const STATE_GAME_INTRO := "game_intro"
const STATE_GAME := "game"

# Names of audio busses
const MUSIC_BUS := "Music"
const SOUND_BUS := "Sounds"

# Base speed of EndlessSidescrollers while in the menu.
const BASE_SPEED_MENU := 15
# Base speed of EndlessSidescrollers while in the game.
const BASE_SPEED_GAME := 30
