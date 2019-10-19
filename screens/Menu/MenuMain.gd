extends State


####################################################################################
# Constants

const FADE_ANIMATION := "fade"
const SHORT_FADE_ANIMATION := "fade_short"


####################################################################################
# Signals

signal play()


####################################################################################
# Scene Objects

onready var _button_animator: AnimationPlayer = $ButtonAnimator
onready var _misc_animator: AnimationPlayer = $MiscAnimator
onready var _version_label: Label = $MiscContainer/Label


####################################################################################
# Scene Lifecycle

func _ready():
	# We need to fill in the version number
	_version_label.text = tr("VERSION_LABEL") % \
		ProjectSettings.get("application/config/version")


####################################################################################
# State Lifecycle

func state_started(prev_state: State) -> void:
	.state_started(prev_state)
	
	# Only animate the rest back in if we don't come from a menu.
	if prev_state == null or not prev_state.is_in_group(Constants.GROUP_MENUS):
		_button_animator.play(FADE_ANIMATION)
		_misc_animator.play(FADE_ANIMATION)
	else:
		# If we come from a menu, there's no need for that initial pause in the
		# animation
		_button_animator.play(SHORT_FADE_ANIMATION)


func state_paused(next_state: State) -> void:
	.state_paused(next_state)
	_button_animator.play_backwards(FADE_ANIMATION)
	
	# Only animate the rest out if we don't go to a menu
	if next_state == null or not next_state.is_in_group(Constants.GROUP_MENUS):
		_misc_animator.play_backwards(FADE_ANIMATION)


####################################################################################
# Event Handling

func _on_ButtonPlay_pressed():
	emit_signal("play")


func _on_ButtonSettings_pressed():
	transition_push(Constants.STATE_MENU_SETTINGS)
	

func _on_ButtonExit_pressed():
	# Removing all states tells our main controller to quit the game
	transition_replace_all(Constants.STATE_EXIT)
