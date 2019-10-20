extends State


####################################################################################
# Scene Lifecycle

func _process(delta):
	# If the user presses Escape, exit the pause menu
	if is_running() and Input.is_action_just_pressed("ui_cancel"):
		_pause()


func _notification(what):
	# Pause if we lose focus during the game
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		_pause()


func _pause():
	transition_push(Constants.STATE_MENU_PAUSE)
