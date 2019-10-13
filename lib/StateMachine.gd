extends Node2D

# Provides a generic state machine that can work as a pushdown automaton. Thus,
# transitioning to a new state does not have to entail replacing the current state,
# but can also mean pushing the new state onto a state stack, just to return to
# the previous state later when leaving the new state.
# 
# States managed by a state machine must be defined and implemented as directed
# children in the scene. This also establishes a clear and easy convention for how
# states can access their state machine to cause transitions.
class_name StateMachine


####################################################################################
# State

# Our stack of states. Index 0 holds the oldest state.
var _state_stack = []


####################################################################################
# State Access

# Returns the currently running state.
func get_running_state() -> State:
	if _state_stack.empty():
		return null
	else:
		return _state_stack.back()


####################################################################################
# State Manipulation

# Transitions to the given state, replacing the newest stack state only.
func transition_replace_single(state: State) -> void:
	_pop()
	_push(state)


# Transitions to the given state, replacing all states on the stack. Calling
# transition_back(...) from that state won't make sense.
func transition_replace_all(state: State) -> void:
	while not _state_stack.empty():
		_pop()
	
	_push(state)


# Transitions to the given state and pushes it on our state stack.
func transition_push(state: State) -> void:
	# Tell the currently running state that is must pause
	var running_state := get_running_state()
	if running_state != null:
		running_state.state_paused()
	
	# Activate and start the new state
	_push(state)


# Removes the current state from the stack and transitions back to the state that
# preceded it.
func transition_pop() -> void:
	_pop()
	
	# Check if we have a new running state
	var new_running_state := get_running_state()
	if new_running_state != null:
		new_running_state.state_started()


# If we have a running state, pauses, deactivates and removes it
func _pop() -> void:
	# If we have a running state, pause and deactivate it
	var running_state := get_running_state()
	if running_state != null:
		running_state.state_paused()
		_state_stack.pop_back()
		running_state.state_deactivated()


# Pushes, activates and starts the given state. Does not pause the previously
# running state, if any
func _push(state: State) -> void:
	# Activate and start the new state
	_state_stack.append(state)
	state.state_activated()
	state.state_started()
