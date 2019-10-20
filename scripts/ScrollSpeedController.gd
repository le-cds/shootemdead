extends Node
# Provides centralized access to the scrolling speed of our endless sidescrollers.

# The base speed for all of our EndlessSidescroller instances.
var _base_speed := 0 setget set_base_speed, get_base_speed

# Returns the current base speed.
func get_base_speed() -> int:
	return _base_speed

# Sets the base speed to a new value and updates all EndlessSidescrollers in the
# "sidescrollers" group.
func set_base_speed(new_base_speed: int) -> void:
	if new_base_speed > 0:
		_base_speed = new_base_speed
		
		# Update our sidescrollers
		for scroller in get_tree().get_nodes_in_group(Constants.GROUP_SIDESCROLLERS):
			(scroller as EndlessSidescroller).base_speed = _base_speed
