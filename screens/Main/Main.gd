extends Node2D


####################################################################################
# Scene Objects

onready var _state_machine: StateMachine = $StateMachine
onready var _state_menu_main: State = $StateMachine/MenuMain


####################################################################################
# Lifecycle

func _ready() -> void:
	# Register event listeners
	_state_machine.connect("state_changed", self, "_state_changed")
	_state_menu_main.connect("start_new_game", self, "_start_new_game")
	
	# Ensure that all EndlessSidescrollers have the correct base speed
	ScrollSpeedController.set_base_speed(Constants.BASE_SPEED_MENU)
	
	# Display the menu after half a second
	yield(get_tree().create_timer(0.5), "timeout")
	_state_machine.transition_push(Constants.STATE_MENU_MAIN)


####################################################################################
# Event Handling

func _start_new_game() -> void:
	_state_machine.transition_push(Constants.STATE_GAME_INTRO)


func _state_changed(new_state: State) -> void:
	if new_state == null:
		# No active state anymore, quit the game
		get_tree().quit()
