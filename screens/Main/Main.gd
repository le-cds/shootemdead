extends Node2D


####################################################################################
# State

# The base speed for all of our EndlessSidescroller instances.
var _base_speed := Constants.BASE_SPEED_MENU setget set_base_speed, get_base_speed


####################################################################################
# Scene Objects

onready var _state_machine: StateMachine = $StateMachine
onready var _state_menu_main: State = $StateMachine/MenuMain
onready var _state_game_intro: State = $StateMachine/GameIntro


####################################################################################
# Lifecycle

func _ready() -> void:
	# Register event listeners
	_state_machine.connect("state_changed", self, "_state_changed")
	_state_menu_main.connect("play", self, "_new_game")
	
	# Ensure that all EndlessSidescrollers have the correct base speed
	set_base_speed(_base_speed)
	
	# Display the menu
	_state_machine.transition_push(_state_menu_main)


####################################################################################
# Getters / Setters

func get_base_speed() -> int:
	return _base_speed

# Sets the base speed to a new value and updates all EndlessSidescrollers in the
# "sidescrollers" group.
func set_base_speed(new_base_speed: int) -> void:
	if new_base_speed > 0:
		_base_speed = new_base_speed
		
		# Update our sidescrollers
		for scroller in get_tree().get_nodes_in_group("sidescrollers"):
			(scroller as EndlessSidescroller).base_speed = _base_speed


####################################################################################
# Event Handling

func _new_game() -> void:
	_state_machine.transition_push(_state_game_intro)


func _state_changed(new_state: State) -> void:
	if new_state == null:
		# No active state anymore, quit the game
		get_tree().quit()
