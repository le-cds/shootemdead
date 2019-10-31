extends Node
# Provides centralized access to the scrolling speed of our endless sidescrollers.


####################################################################################
# State

# We need a tween to interprolate our base speed properly.
var _tween: Tween
# The base speed for all of our EndlessSidescroller instances.
var _base_speed := 0 setget set_base_speed, get_base_speed


####################################################################################
# Object Lifecycle

func _init() -> void:
	_tween = Tween.new()
	add_child(_tween)


####################################################################################
# Getters / Setters

# Returns the current base speed.
func get_base_speed() -> int:
	return _base_speed


# Sets the base speed to a new value and updates all EndlessSidescrollers in the
# "sidescrollers" group.
func set_base_speed(new_base_speed: int) -> void:
	if new_base_speed >= 0:
		_stop_tweens()
		_apply_base_speed(new_base_speed)


# Animates the base speed to a new value over a given time. Can be called even
# while an interpolation is currently in progress.
func interpolate_base_speed(new_base_speed: int, duration: float) -> void:
	if new_base_speed >= 0:
		_stop_tweens()
		_tween.interpolate_method(
			self,
			"_apply_base_speed",
			_base_speed,
			new_base_speed,
			duration,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT)
		_tween.start()


####################################################################################
# Utility Methods

# Applies the given base speed and updates our sidescrollers.
func _apply_base_speed(new_base_speed: int) -> void:
	_base_speed = new_base_speed
	
	for scroller in get_tree().get_nodes_in_group(Constants.GROUP_SIDESCROLLERS):
		(scroller as EndlessSidescroller).base_speed = _base_speed


# If a tween is currently running, stop it.
func _stop_tweens() -> void:
	if _tween.is_active():
		_tween.remove_all()
