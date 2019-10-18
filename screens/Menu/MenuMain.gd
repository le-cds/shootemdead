extends State


####################################################################################
# CONSTANTS

const ANIMATION_BUTTONS := "fade_buttons"
const ANIMATION_REST := "fade_misc"


####################################################################################
# Scene Objects

onready var animator: AnimationPlayer = $AnimationPlayer
onready var version_label: Label = $MiscContainer/Label


####################################################################################
# Scene Lifecycle

func _ready():
	# We need to fill in the version number
	version_label.text = tr("VERSION_LABEL") % \
		ProjectSettings.get("application/config/version")


####################################################################################
# State Lifecycle

func state_started(prev_state: State) -> void:
	.state_started(prev_state)
	animator.play(ANIMATION_BUTTONS)
	
	# Only animate the rest back in if we don't come from a menu
	if prev_state == null or not prev_state.is_in_group(Constants.GROUP_MENUS):
		animator.play(ANIMATION_REST)


func state_paused(next_state: State) -> void:
	.state_paused(next_state)
	animator.play_backwards(ANIMATION_BUTTONS)
	
	# Only animate the rest out if we don't go to a menu
	if next_state == null or not next_state.is_in_group(Constants.GROUP_MENUS):
		animator.play_backwards(ANIMATION_REST)


####################################################################################
# Event Handling

func _on_ButtonPlay_pressed():
	# TODO Replace this by a signal
	transition_push($"/root/Main/StateMachine/GameIntro")


func _on_ButtonSettings_pressed():
	# TODO Replace this by a signal
	transition_push($"/root/Main/StateMachine/MenuSettings")
	

func _on_ButtonExit_pressed():
	# Fade out the menu before quitting
	animator.play_backwards("fade")
	yield(animator, "animation_finished")
	
	# Removing all states tells our main controller to quit the game
	transition_replace_all(null)
