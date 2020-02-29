extends State


####################################################################################
# Constants

const FADE_ANIMATION := "fade"


####################################################################################
# Signals

# Emitted when the player wants to start a new game.
signal start_new_game()


####################################################################################
# Scene Objects

onready var _title_animator: AnimationPlayer = $TitleAnimator
onready var _button_animator: AnimationPlayer = $ButtonAnimator
onready var _misc_animator: AnimationPlayer = $MiscAnimator
onready var _version_label: Label = $Statics/Label


####################################################################################
# Scene Lifecycle

func _ready():
	# We want to play animations when pausing
	set_yield_on_pause(true)
	
	MusicPlayer.add_stream(Constants.MUSIC_ID_MENU, preload("res://assets/Music/false_awakenings.ogg"))
	
	# We need to fill in the version number
	_version_label.text = tr("VERSION_LABEL") % \
		ProjectSettings.get("application/config/version")


####################################################################################
# State Lifecycle

func state_started(prev_state: State, params: Dictionary) -> void:
	.state_started(prev_state, params)
	
	ScrollSpeedController.interpolate_base_speed(Constants.BASE_SPEED_MENU, 1)
	MusicPlayer.play(Constants.MUSIC_ID_MENU)
	
	_button_animator.play(FADE_ANIMATION)
	
	# Only animate the rest back in if we don't come from a menu.
	if prev_state == null or not prev_state.is_in_group(Constants.GROUP_MENUS):
		_misc_animator.play(FADE_ANIMATION)


func state_paused(next_state: State) -> void:
	.state_paused(next_state)
	_button_animator.play_backwards(FADE_ANIMATION)
	
	# Only animate the rest out if we don't go to a menu
	if next_state == null or not next_state.is_in_group(Constants.GROUP_MENUS):
		_misc_animator.play_backwards(FADE_ANIMATION)
	
	yield(_button_animator, "animation_finished")


####################################################################################
# Event Handling

func _on_ButtonPlay_pressed():
	emit_signal("start_new_game")


func _on_ButtonSettings_pressed():
	transition_push(Constants.STATE_MENU_SETTINGS)


func _on_ButtonExit_pressed():
	# Removing all states tells our main controller to quit the game
	transition_replace_all(Constants.STATE_EXIT)
