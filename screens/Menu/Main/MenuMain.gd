extends State


####################################################################################
# Scene Objects

onready var animator := $AnimationPlayer


####################################################################################
# Scene Lifecycle

func _ready():
	# We need to fill in the version number
	$MiscContainer/Label.text = tr("VERSION_LABEL") % \
		ProjectSettings.get("application/config/version")


####################################################################################
# State Lifecycle

func state_activated() -> void:
	.state_activated()
	self.visible = true
	

func state_started() -> void:
	.state_started()
	animator.play("fade")


func state_paused() -> void:
	.state_paused()
	animator.play_backwards("fade")


func state_deactivated() -> void:
	.state_deactivated()
	self.visible = false


####################################################################################
# Event Handling

func _on_ButtonPlay_pressed():
	# TODO Replace this by a transition to the game state
	get_parent().transition_pop()


func _on_ButtonExit_pressed():
	# Fade out the menu before quitting
	animator.play_backwards("fade")
	yield(animator, "animation_finished")
	
	get_tree().quit()
