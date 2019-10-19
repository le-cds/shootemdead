extends State


####################################################################################
# Scene Objects

onready var animator: AnimationPlayer = $AnimationPlayer
onready var tween: Tween = $Tween


####################################################################################
# State Lifecycle

func state_started(prev_state: State) -> void:
	.state_started(prev_state)
	
	# Start our animation player, which will cause our speed modification
	# methods to be called
	animator.play("Intro")


####################################################################################
# Game Manipulation

# Slows the background down to 0. Called by AnimationPlayer.
func _slow_down() -> void:
	tween.interpolate_method(
		$"/root/Main",
		"set_base_speed",
		Constants.BASE_SPEED_MENU,
		0,
		1,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN)
	tween.start()


# Speeds up the background to game speed. Called by AnimationPlayer.
func _speed_up() -> void:
	tween.interpolate_method(
		$"/root/Main",
		"set_base_speed",
		0,
		Constants.BASE_SPEED_GAME,
		1,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN)
	tween.start()


# Starts the actual game. Called by AnimationPlayer.
func _start_game() -> void:
	transition_replace_single(Constants.STATE_GAME)
