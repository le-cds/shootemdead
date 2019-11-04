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

onready var _rect: ColorRect = $Visuals/ColorRect
onready var _animation_player: AnimationPlayer = $AnimationPlayer
onready var _blood_splatter: Particles2D = $BloodSplatter
onready var _visibiliy_notifier: VisibilityNotifier2D = $VisibilityNotifier2D


####################################################################################
# State

# The enemy's ID. Used by the game for scoring multiplier purposes.
var id := 0

# Whether the enemy is still alive.
var _alive := true


####################################################################################
# Scene Lifecycle

func _process(delta) -> void:
	var global_pos: Vector2 = _rect.rect_global_position
	if _alive and global_pos.x + _rect.rect_size.x < 0:
		survive(true, false)


# Tells listeners that this enemy has survived, optionally triggers animations and
# removes it from the scene.
func survive(signal_listeners: bool, play_animation: bool) -> void:
	if signal_listeners:
		emit_signal("enemy_left", self, true)
	
	if play_animation:
		_animation_player.play("Hide")
		yield(_animation_player, "animation_finished")
	
	self.queue_free()


# Tells listeners that this enemy has died, triggers any death animations and
# removes it from the scene.
func die(signal_listeners: bool) -> void:
	_alive = false
	
	if (signal_listeners):
		emit_signal("enemy_left", self, false)
	
	# Trigger effects
	_animation_player.play("Hide")
	_blood_splatter.emitting = true
	
	# The animation is long enough to allow the particle emitter to finish
	yield(_animation_player, "animation_finished")
	self.queue_free()


####################################################################################
# Getters / Setters

func set_spawn_location(location: Vector2) -> void:
	set_position(Vector2(
		location.x,
		location.y - _rect.rect_size.y))


# Whether the enemy is still alive.
func is_alive() -> bool:
	return _alive


# Whether the enemy (or at least parts of the enemy) are currently visible.
func is_on_screen() -> bool:
	var enemy_global_rect = _rect.get_global_rect()
	return enemy_global_rect.position.x < get_viewport().size.x and enemy_global_rect.end.x > 0


####################################################################################
# Event Handling

func _on_ColorRect_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		# Place the blood splatter origin at hit point
		_blood_splatter.set_global_position(get_viewport().get_mouse_position())
		
		die(true)
