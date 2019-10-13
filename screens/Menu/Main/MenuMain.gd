extends State


onready var animator := $AnimationPlayer


func _ready():
	# We need to fill in the version number
	$MiscContainer/Label.text = tr("VERSION_LABEL") % ProjectSettings.get("application/config/version")


####################################################################################
# State Lifecycle

func state_started() -> void:
	.state_started()
	animator.play("fade")


func state_paused() -> void:
	.state_paused()
	animator.play_backwards("fade")


####################################################################################
# Event Handling

func _on_ButtonPlay_pressed():
	get_parent().transition_pop()


func _on_ButtonExit_pressed():
	get_tree().quit()
