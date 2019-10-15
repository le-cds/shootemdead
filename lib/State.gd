extends Node2D

# A state that can be used in a StateMachine. States can be active or inactive,
# and running or not running. As they enter the state machine's stack of states,
# they are active. The topmost state on the stack is running. This base class
# manages activity state. A state should only do stuff in its process methods if
# it is currently running.
#
# A state which is not currently active has its processing disabled. This class
# takes care of enabling processing again as soon as the state is activated
# (even if it's not running).
# 
# A state does not have a built-in reference to the state machine it appears in
# since that would introduce a cyclic dependency. Instead, a state can instruct
# its state machine to push and pop states by calling the appropriate methods in
# this class, which communicate with the state machine via signals.
class_name State


####################################################################################
# Signals

# Signals which correspond to the methods in StateMachine
signal transition_push(state)
signal transition_replace_single(state)
signal transition_replace_all(state)
signal transition_pop()
signal transition_pop_to_root()


####################################################################################
# State

# Whether the state is currently on the state machine's stack of states.
var _active := false setget , is_active

# Whether the state is currently running. Only one state can be running at any
# point in time.
var _running := false setget , is_running


####################################################################################
# Scene Lifecycle

func _init() -> void:
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
	
	set_process(false)
	set_physics_process(false)
	self.visible = false


####################################################################################
# State Machine Signalling

# Transitions to the given state and pushes it on our state stack.
func transition_push(state: State) -> void:
	emit_signal("transition_push", state)


# Transitions to the given state, replacing the newest stack state only.
func transition_replace_single(state: State) -> void:
	emit_signal("transition_replace_single", state)


# Transitions to the given state, replacing all states on the stack. Calling
# transition_back(...) from that state won't make sense.
func transition_replace_all(state: State) -> void:
	emit_signal("transition_replace_all", state)


# Removes the current state from the stack and transitions back to the state that
# preceded it.
func transition_pop() -> void:
	emit_signal("transition_pop")


# Removes all but the lowermost states and transitions back to that state.
func transition_pop_to_root() -> void:
	emit_signal("transition_pop_to_root")


####################################################################################
# Getters and Setters

# Returns whether the state is currently active or not.
func is_active() -> bool:
	return _active

# Returns whether the state is currently running or not.
func is_running() -> bool:
	return _running
