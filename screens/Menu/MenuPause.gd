extends State


####################################################################################
# Scene Lifecycle

func _process(delta: float) -> void:
	# If the user presses Escape, exit the pause menu
	if is_running() and Input.is_action_just_pressed("ui_cancel"):
		_resume()


####################################################################################
# State Lifecycle

func state_started(prev_state: State, params: Dictionary) -> void:
	.state_started(prev_state, params)
	
	# Put Godot into Pause mode
	get_tree().paused = true


func state_paused(next_state: State) -> void:
	.state_paused(next_state)
	
	# Recover from Pause mode
	get_tree().paused = false


####################################################################################
# Behaviour

# Ends the pause state by returning to the previous state
func _resume():
	transition_pop()


# Returns to the main menu
func _main_menu():
	# This assumes that the main menu state is the topmost state
	transition_pop_to_root()


# Quits the game by stopping the state machine.
func _quit():
	transition_replace_all(Constants.STATE_EXIT)


####################################################################################
# Event Handling

func _on_ResumeButton_pressed():
	_resume()


func _on_MainMenuButton_pressed():
	_main_menu()


func _on_QuitButton_pressed():
	_quit()
