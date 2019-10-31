extends Node2D

class_name Enemy


####################################################################################
# Signals

# Triggered when the enemy leaves the scene, either because it survived or was
# killed. We don't split this into different events because this allows connecting
# to this event using a one-shot connection that is disconnected as soon as this
# event is triggered.
signal enemy_left(enemy, survived)


####################################################################################
# Scene Objects

onready var _rect: ColorRect = $ColorRect


####################################################################################
# Scene Lifecycle

func _process(delta) -> void:
	var global_pos: Vector2 = _rect.rect_global_position
	if global_pos.x + _rect.rect_size.x < 0:
		_survive()


# Tells listeners that this enemy has survived and removes it from the scene.
func _survive() -> void:
	emit_signal("enemy_left", self, true)
	self.queue_free()


# Tells listeners that this enemy has died, triggers any death animations and
# removes it from the scene.
func die(signal_listeners: bool) -> void:
	if (signal_listeners):
		emit_signal("enemy_left", self, false)
	self.queue_free()


####################################################################################
# Getters / Setters

func set_spawn_location(location: Vector2) -> void:
	set_position(Vector2(
		location.x,
		location.y - _rect.rect_size.y))


####################################################################################
# Event Handling

func _on_ColorRect_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		die(true)
