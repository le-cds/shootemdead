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
func get_top_state() -> State:
	if _state_stack.empty():
		return null
	else:
		return _state_stack.back()


####################################################################################
# State Manipulation

# Transitions to the given state and pushes it on our state stack.
func transition_push(state: State) -> void:
	_push(state)


# Transitions to the given state, replacing the newest stack state only.
func transition_replace_single(state: State) -> void:
	_pop(false)
	_push(state)


# Transitions to the given state, replacing all states on the stack. Calling
# transition_back(...) from that state won't make sense.
func transition_replace_all(state: State) -> void:
	while not _state_stack.empty():
		_pop(false)
	
	_push(state)


# Removes the current state from the stack and transitions back to the state that
# preceded it.
func transition_pop() -> void:
	_pop(true)


# Removes all but the lowermost states and transitions back to that state.
func transition_pop_to_root() -> void:
	if _state_stack.size() > 1:
		# Pop off almost all states, but only restart the last state
		while _state_stack.size() > 1:
			_pop(_state_stack.size() == 2)


# If we have a running state, pauses, deactivates and removes it. The
# parameter controls whether we restart the new top state, if any. This
# will be false if we pop off multiple states at once or if the popped
# state will immediately be replaced by a new state
func _pop(start_state_below: bool) -> void:
	# If we have a running state, pause and deactivate it
	var top_state := get_top_state()
	if top_state != null:
		if top_state.is_running():
			# This can be false if we're removing multiple states at once
			top_state.state_paused()
			_uninstall_signal_handlers(top_state)
		
		_state_stack.pop_back()
		top_state.state_deactivated()
	
	# Start the new top state, if necessary
	if start_state_below:
		var new_top_state := get_top_state()
		if new_top_state != null:
			new_top_state.state_started()


# Pushes, activates and starts the given state. Does not pause the previously
# running state, if any
func _push(state: State) -> void:
	# Tell the currently running state that is must pause
	var top_state := get_top_state()
	if top_state != null and top_state.is_running():
		top_state.state_paused()
	
	# Activate and start the new state
	_state_stack.append(state)
	_install_signal_handlers(state)
	state.state_activated()
	state.state_started()


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
