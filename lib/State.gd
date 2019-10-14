extends Node2D

# A state that can be used in a StateMachine. States can be active or inactive,
# and running or not running. As they enter the state machine's stack of states,
# they are active. The topmost state on the stack is running. This base class
# manages activity state. A state should only do stuff in its update() method if
# it is currently running.
class_name State


####################################################################################
# State

# Whether the state is currently on the state machine's stack of states.
var _active := false setget , is_active

# Whether the state is currently running. Only one state can be running at any
# point in time.
var _running := false setget , is_running


####################################################################################
# State Lifecycle

# Called by the state machine when this state enters the stack of states. The
# superclass implementation must be called from subclasses in order for activity
# management to work correctly.
func state_activated() -> void:
	_active = true

# Called when this state becomes the running state. The superclass implementation
# must be called from subclasses in ordner for activity management to work
# correctly.
func state_started() -> void:
	_running = true

# Called when this state ceases to be the running state. The superclass
# implementation must be called from subclasses in ordner for activity management
# to work correctly.
func state_paused() -> void:
	_running = false

# Called by the state machine when this state leaves the stack of states. The
# superclass implementation must be called from subclasses in order for activity
# management to work correctly.
func state_deactivated() -> void:
	_active = false


####################################################################################
# Getters and Setters

# Returns whether the state is currently active or not.
func is_active() -> bool:
	return _active

# Returns whether the state is currently running or not.
func is_running() -> bool:
	return _running
