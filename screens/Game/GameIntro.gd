extends State


####################################################################################
# Scene Objects

onready var animator: AnimationPlayer = $AnimationPlayer


####################################################################################
# State Lifecycle

func state_started(prev_state: State, params: Dictionary) -> void:
	.state_started(prev_state, params)
	
	# Set music to silence
	MusicPlayer.play(MusicPlayer.Music.SILENCE)
	
	# Start our animation player, which will cause our speed modification
	# methods to be called
	animator.play("Intro")


####################################################################################
# Game Manipulation

# Slows the background down to 0. Called by AnimationPlayer.
func _slow_down() -> void:
	ScrollSpeedController.interpolate_base_speed(0, 1)


# Speeds up the background to game speed. Called by AnimationPlayer.
func _speed_up() -> void:
	ScrollSpeedController.interpolate_base_speed(Constants.BASE_SPEED_GAME, 1)


# Starts the actual game. Called by AnimationPlayer.
func _start_game() -> void:
	transition_replace_single(Constants.STATE_GAME)
