extends State


####################################################################################
# Scene Objects, State

onready var _score_label: Label = $CenterContainer/VBoxContainer/ScoreLabel
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _tween: Tween = $Tween

# The score to be displayed
var score: int = 0


####################################################################################
# Scene Lifecycle

func _ready():
	# We want to play animations when pausing
	set_yield_on_pause(true)


####################################################################################
# State Lifecycle

func state_started(prev_state: State) -> void:
	.state_started(prev_state)
	
	_animation_player.play("Fade")
	
	_tween.interpolate_method(
		self,
		"_update_score_label",
		0,
		score,
		1.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT)
	_tween.start()


func state_paused(next_state: State) -> void:
	.state_paused(next_state)
	
	# Animate animations!
	_animation_player.play_backwards("Fade")
	yield(_animation_player, "animation_finished")


####################################################################################
# Behaviour

func _update_score_label(val: float) -> void:
	var score_str: String = str(int(round(val)))
	
	# We want to insert a space as thousands separator
	var insert_index: int = score_str.length() - 3
	while insert_index > 0:
		score_str = score_str.insert(insert_index, ".")
		insert_index -= 3
	
	_score_label.text = score_str


# Returns to the main menu
func _main_menu():
	# This assumes that the main menu state is the topmost state
	transition_pop_to_root()
