tool
extends Node2D

# A state that can be used in a StateMachine. States can be active or inactive,
# and running or not running. As they enter the state machine's stack of states,
# they are activated. The topmost state on the stack is running.
#
# A state which is not currently active has its processing disabled. This class
# takes care of enabling processing again as soon as the state is activated
# (even if it's not running).
# 
# States may wish to play animations as they are started or paused. If the latter
# is the case, the state machine may need to wait for the animation to finish
# before enabling the next state. To indicate that this should be done, call
# set_yield_on_pause(true) and yield in your pause method. The state machine will
# then wait for the pause method to finish before enabling the next state.
# 
# A state does not have a built-in reference to the state machine it appears in
# since that would introduce a cyclic dependency. Instead, a state can instruct
# its state machine to push and pop states by calling the appropriate methods in
# this class, which communicate with the state machine via signals.
class_name State


####################################################################################
# Signals

# Signals which correspond to the methods in StateMachine
signal transition_push(state_id, params)
signal transition_replace_single(state_id, params)
signal transition_replace_all(state_id, params)
signal transition_pop(params)
signal transition_pop_to_root(params)


####################################################################################
# Configuration Options

# ID of this state.
export (String) var state_id: String setget , get_state_id


####################################################################################
# State

# Whether the state machine should yield on state_paused(...) to wait for fade out
# animations to finish.
var _yield_on_pause := false setget set_yield_on_pause, get_yield_on_pause

# Whether the state is currently on the state machine's stack of states.
var _active := false setget , is_active

# Whether the state is currently running. Only one state can be running at any
# point in time.
var _running := false setget , is_running


####################################################################################
# Scene Lifecycle

func _init() -> void:
	if not Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)


####################################################################################
# State Lifecycle

# Called by the state machine when this state enters the stack of states. The
# superclass implementation must be called from subclasses in order for activity
# management to work correctly.
func state_activated() -> void:
	_active = true
	
	self.visible = true
	set_process(true)
	set_physics_process(true)


# Called when this state becomes the running state. The superclass implementation
# must be called from subclasses in ordner for activity management to work
# correctly. The parameters are a non-null dictionary of parameters passed to
# this state by whoever caused it to be started again.
func state_started(prev_state: State, params: Dictionary) -> void:
	_running = true


# Called when this state ceases to be the running state. The superclass
# implementation must be called from subclasses in ordner for activity management
# to work correctly.
func state_paused(next_state: State) -> void:
	_running = false


# Called by the state machine when this state leaves the stack of states. The
# superclass implementation must be called from subclasses in order for activity
# management to work correctly.
func state_deactivated() -> void:
	_active = false
	
	self.visible = false
	set_process(false)
	set_physics_process(false)


####################################################################################
# State Machine Signalling

# Transitions to the given state and pushes it on our state stack.
func transition_push(state_id: String, params: Dictionary = {}) -> void:
	emit_signal("transition_push", state_id, params)


# Transitions to the given state, replacing the newest stack state only.
func transition_replace_single(state_id: String, params: Dictionary = {}) -> void:
	emit_signal("transition_replace_single", state_id, params)


# Transitions to the given state, replacing all states on the stack. Calling
# transition_back(...) from that state won't make sense.
func transition_replace_all(state_id: String, params: Dictionary = {}) -> void:
	emit_signal("transition_replace_all", state_id, params)


# Removes the current state from the stack and transitions back to the state that
# preceded it.
func transition_pop(params: Dictionary = {}) -> void:
	emit_signal("transition_pop", params)


# Removes all but the lowermost states and transitions back to that state.
func transition_pop_to_root(params: Dictionary = {}) -> void:
	emit_signal("transition_pop_to_root", params)


####################################################################################
# Getters and Setters

# Returns this state's ID.
func get_state_id() -> String:
	return state_id


# Returns whether the state machine should yield on pause. See class docs for
# details.
func get_yield_on_pause() -> bool:
	return _yield_on_pause


# Sets whether the state machine should yield on pause. See class docs for
# details.
func set_yield_on_pause(yop: bool) -> void:
	_yield_on_pause = yop


# Returns whether the state is currently active or not.
func is_active() -> bool:
	return _active


# Returns whether the state is currently running or not.
func is_running() -> bool:
	return _running


####################################################################################
# Editor Support

func _get_configuration_warning():
	if state_id == null or state_id.length() == 0:
		return "You must configure a non-empty state ID."
	
	return ""
