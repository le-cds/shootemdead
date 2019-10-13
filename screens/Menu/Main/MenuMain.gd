extends State


####################################################################################
# Scene Objects

onready var animator := $AnimationPlayer


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
