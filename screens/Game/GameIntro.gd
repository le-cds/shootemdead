extends State


####################################################################################
# Scene Objects

onready var animator: AnimationPlayer = $AnimationPlayer

var _intro_woosh = preload("res://assets/Sounds/intro_woosh.ogg")


####################################################################################
# State Lifecycle

func state_started(prev_state: State, params: Dictionary) -> void:
	.state_started(prev_state, params)
	
	# Set music to silence
	MusicPlayer.play(MusicPlayer.NONE, 3)
	
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


func _woosh_sound() -> void:
	SoundPlayer.play_sound(self, _intro_woosh, Constants.SOUND_BUS)


# Starts the actual game. Called by AnimationPlayer.
func _start_game() -> void:
	transition_replace_single(Constants.STATE_GAME)
