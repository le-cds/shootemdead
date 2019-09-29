extends ColorRect

class_name Enemy

enum State {ALIVE, DEAD, SURVIVED}
var state: int = State.ALIVE

signal survived
signal died

func _gui_input(event):
    if event is InputEventMouseButton:
        if event.pressed:
            die()


func _process(delta):
	if state == State.ALIVE and rect_global_position.x + rect_size.x < 0:
		state = State.SURVIVED
		emit_signal("survived")


func die():
	if state == State.ALIVE:
		state = State.DEAD
		color = Color(255, 0, 0)
		print("Received pressed event")
		emit_signal("died")
