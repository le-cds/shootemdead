extends Node2D


####################################################################################
# State

# The base speed for all of our EndlessSidescroller instances.
var _base_speed := Constants.BASE_SPEED_MENU setget set_base_speed, get_base_speed


####################################################################################
# Scene Objects

onready var state_machine: StateMachine = $StateMachine
onready var state_menu_main: State = $StateMachine/MenuMain


####################################################################################
# Lifecycle

func _ready() -> void:
	# Ensure that all EndlessSidescrollers have the correct base speed
	set_base_speed(_base_speed)
	
	# Display the menu
	state_machine.transition_push(state_menu_main)


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
