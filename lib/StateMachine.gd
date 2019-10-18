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
# Signals

# Triggered whenever the state is changed. The given state was already started. If
# no state is on the stack anymore, state will be null.
signal state_changed(state)


####################################################################################
# State

# Our stack of states. Index 0 holds the oldest state.
var _state_stack = []

# The most recently active state.
var _last_active_state: State = null


####################################################################################
# State Access

# Returns the currently running state.
func get_top_state() -> State:
	if _state_stack.empty():
		return null
	else:
		# We're not returning the last active state here since that might not
		# be active anymore
		return _state_stack.back()


####################################################################################
# State Manipulation

# Transitions to the given state and pushes it on our state stack.
func transition_push(state: State) -> void:
	_push(state)


# Transitions to the given state, replacing the newest stack state only.
func transition_replace_single(state: State) -> void:
	_pop(false, state)
	_push(state)


# Transitions to the given state, replacing all states on the stack. Transitioning
# to null as a new state will remove all states.
func transition_replace_all(state: State) -> void:
	if state != null:
		while not _state_stack.empty():
			_pop(false, state)
		_push(state)
	else:
		while not _state_stack.empty():
			# Notify everyone that the last state was removed
			_pop(_state_stack.size() == 1, state)


# Removes the current state from the stack and transitions back to the state that
# preceded it.
func transition_pop() -> void:
	var next_state: State = null
	if _state_stack.size() > 1:
		next_state = _state_stack[_state_stack.size() - 2]
	
	_pop(true, next_state)


# Removes all but the lowermost states and transitions back to that state.
func transition_pop_to_root() -> void:
	if _state_stack.size() > 1:
		# Pop off almost all states, but only restart the last state
		while _state_stack.size() > 1:
			_pop(_state_stack.size() == 2, _state_stack[0])


# If we have a running state, pauses, deactivates and removes it. The
# parameter controls whether we restart the new top state, if any. This
# will be false if we pop off multiple states at once or if the popped
# state will immediately be replaced by a new state.
#
# The next state designates which state will be started next, possibly
# way after a single pop operation. This state is passed to states that
# are paused and removed.
func _pop(start_state_below: bool, next_state: State) -> void:
	# If we have a running state, pause and deactivate it
	var top_state := get_top_state()
	if top_state != null:
		if top_state.is_running():
			# This can be false if we're removing multiple states at once
			top_state.state_paused(next_state)
			_uninstall_signal_handlers(top_state)
		
		_state_stack.pop_back()
		top_state.state_deactivated()
	
	# Start the new top state, if necessary
	if start_state_below:
		var new_top_state := get_top_state()
		if new_top_state != null:
			new_top_state.state_started(_last_active_state)
			_last_active_state = new_top_state
			emit_signal("state_changed", new_top_state)
		else:
			emit_signal("state_changed", null)


# Pushes, activates and starts the given state. Does not pause the previously
# running state, if any
func _push(new_state: State) -> void:
	# Tell the currently running state that is must pause
	var previous_state := get_top_state()
	if previous_state != null and previous_state.is_running():
		previous_state.state_paused(new_state)
	
	# Activate and start the new state
	_state_stack.append(new_state)
	_install_signal_handlers(new_state)
	
	new_state.state_activated()
	new_state.state_started(_last_active_state)
	
	_last_active_state = new_state
	emit_signal("state_changed", new_state)


####################################################################################
# State Signal Handling

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
