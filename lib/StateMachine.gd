extends Node2D

# Provides a generic state machine that can work as a pushdown automaton. Thus,
# transitioning to a new state does not have to entail replacing the current state,
# but can also mean pushing the new state onto a state stack, just to return to
# the previous state later when leaving the new state.
# 
# States managed by a state machine must be defined and implemented as direct
# children in the scene for the state machine to find them. Future implementations
# could loosen this requirement such that each state machine has the name of a
# group where its states are to be found.
#
# Use the transition_*(...) methods to do stuff.
class_name StateMachine


####################################################################################
# Constants

# State ID representing no state.
const NO_STATE := ""


####################################################################################
# Signals

# Triggered whenever the state is changed. The given state was already started. If
# no state is on the stack anymore, state will be null.
signal state_changed(state)


####################################################################################
# State

# Dictionary of states and state IDs.
var _states = {}

# Our stack of states. Index 0 holds the oldest state.
var _state_stack = []

# The most recently active state.
var _last_active_state: State = null


####################################################################################
# Scene Lifecycle

func _ready() -> void:
	# Collect our child states
	for child in get_children():
		if child is State:
			var state := child as State
			var state_id: String = state.get_state_id()
			if state_id != null and state_id.length() > 0:
				_states[state_id] = state


####################################################################################
# State Access

# Returns the currently active state. This may not be accurate during transitions.
func get_active_state() -> State:
	return _last_active_state


####################################################################################
# State Manipulation

# Beware of trickery: _pause_topmost_state(...) yields only if the state to be
# paused wants it to. That means that we need to check its result (even though it
# is a void function...) to see whether we need to yield to, thus waiting for the
# state to finish pausing before we resume.

# Transitions to the given state and pushes it on our state stack. The state must
# exist.
func transition_push(state_id: String) -> void:
	var new_state: State = _state_by_id(state_id)
	if new_state != null:
		var pause_result = _pause_topmost_state(new_state)
		if pause_result is GDScriptFunctionState:
			yield(pause_result, "completed")
		
		_activate_state(new_state)
		_start_topmost_state(_last_active_state)
		
		_update_active_state(new_state)


# Transitions to the given state, replacing the newest stack state only. The
# state must exist.
func transition_replace_single(state_id: String) -> void:
	var new_state: State = _state_by_id(state_id)
	if new_state != null:
		var pause_result = _pause_topmost_state(new_state)
		if pause_result is GDScriptFunctionState:
			yield(pause_result, "completed")
		
		_deactivate_topmost_state()
		_activate_state(new_state)
		_start_topmost_state(_last_active_state)
		
		_update_active_state(new_state)


# Transitions to the given state, replacing all states on the stack. Transitioning
# to NO_STATE will remove all states.
func transition_replace_all(state_id: String) -> void:
	var new_state: State = _state_by_id(state_id)
	
	# Only the topmost state may need to be paused
	var pause_result = _pause_topmost_state(new_state)
	if pause_result is GDScriptFunctionState:
		yield(pause_result, "completed")
	
	# Deactivate all states
	while not _state_stack.empty():
		_deactivate_topmost_state()
	
	# Activate and start the new state, if any
	if new_state != null:
		_activate_state(new_state)
		_start_topmost_state(_last_active_state)
	
	_update_active_state(new_state)


# Removes the current state from the stack and transitions back to the state that
# preceded it.
func transition_pop() -> void:
	# Find out which state will be next
	var new_state: State = null
	if _state_stack.size() > 1:
		new_state = _state_stack[_state_stack.size() - 2]
	
	var pause_result = _pause_topmost_state(new_state)
	if pause_result is GDScriptFunctionState:
		yield(pause_result, "completed")
	
	_deactivate_topmost_state()
	_start_topmost_state(_last_active_state)
	
	_update_active_state(new_state)


# Removes all but the lowermost states and transitions back to that state.
func transition_pop_to_root() -> void:
	# This only makes sense if there is more than the root
	if _state_stack.size() > 1:
		var new_state: State = _state_stack[0]
		
		# Only the topmost state may need to be paused
		var pause_result = _pause_topmost_state(new_state)
		if pause_result is GDScriptFunctionState:
			yield(pause_result, "completed")
		
		# Deactivate all states but the root
		while _state_stack.size() > 1:
			_deactivate_topmost_state()
		
		# Start root
		_start_topmost_state(_last_active_state)
		
		_update_active_state(new_state)


####################################################################################
# Low-Level State Manipulation

# Tries to find a state with the given ID. The returned state may be null
# if the state doesn't exist or the ID is equal to NO_STATE.
func _state_by_id(state_id: String) -> State:
	if state_id == NO_STATE:
		return null
	elif state_id in _states:
		return _states[state_id]
	else:
		push_error("No state with ID " + state_id + " found")
		return null


# Pushes the given state onto the state stack and activates it.
func _activate_state(new_state: State) -> void:
	_state_stack.append(new_state)
	new_state.state_activated()


# Starts the topmost state if there is one and it is not running already. This will
# also install signal handlers to allow the state to tell us to transition to other
# states.
func _start_topmost_state(prev_state: State) -> void:
	if not _state_stack.empty():
		var top_state: State = _state_stack.back()
		if top_state != null and not top_state.is_running():
			_install_signal_handlers(top_state)
			top_state.state_started(prev_state)


# Pauses the topmost state if there is one and it is running. This will also remove
# our signal handlers from the state. If the state plays animations as part of its
# pause actions and wants us to wait for them, this method yields.
func _pause_topmost_state(next_state: State) -> void:
	if not _state_stack.empty():
		var top_state: State = _state_stack.back()
		if top_state != null and top_state.is_running():
			if top_state.get_yield_on_pause():
				# The state obviously has animations to finish before we can continue
				yield(top_state.state_paused(next_state), "completed")
			else:
				top_state.state_paused(next_state)
			_uninstall_signal_handlers(top_state)


# Removes the topmost state from the state stack and deactivates it. The state is
# assumed to have been paused already.
func _deactivate_topmost_state() -> void:
	if not _state_stack.empty():
		var top_state:State = _state_stack.pop_back()
		top_state.state_deactivated()


# Updates the _last_active_state variable and emits our state_changed signal.
func _update_active_state(state: State) -> void:
	_last_active_state = state
	emit_signal("state_changed", state)
	

# Registers us to handle signals emitted from the given state.
func _install_signal_handlers(state: State) -> void:
	state.connect("transition_push", self, "transition_push")
	state.connect("transition_replace_single", self, "transition_replace_single")
	state.connect("transition_replace_all", self, "transition_replace_all")
	state.connect("transition_pop", self, "transition_pop")
	state.connect("transition_pop_to_root", self, "transition_pop_to_root")	


# Stops us from receiving signals from the given state.
func  _uninstall_signal_handlers(state: State) -> void:
	_uninstall_signal_handler(state, "transition_push")
	_uninstall_signal_handler(state, "transition_replace_single")
	_uninstall_signal_handler(state, "transition_replace_all")
	_uninstall_signal_handler(state, "transition_pop")
	_uninstall_signal_handler(state, "transition_pop_to_root")


# Disconnect us from the signal only if we are currently connected. The
# other case should never happen, but we decide to play it safe.
func _uninstall_signal_handler(state: State, the_signal: String) -> void:
	if state.is_connected(the_signal, self, the_signal):
		state.disconnect(the_signal, self, the_signal)
