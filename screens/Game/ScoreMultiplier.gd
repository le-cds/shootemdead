extends Node2D

# Displays a score multiplayer which animates up for a while. Once the animation
# has finished, this node removes itself from the scene.

const ANIMATION_DISTANCE := 90

onready var _label: Label = $Label
onready var _animation_player: AnimationPlayer = $AnimationPlayer


# Sets the label's bottom center point at the start of the animation and triggers
# the animation.
func animate(multiplier: int, start: Vector2) -> void:
	_label.text = str(multiplier) + "x"
	_label.rect_position.x = start.x - _label.rect_size.x / 2
	
	# We have to create a new animation and assign the animation player to play
	# it here. This is because since animations are resources, they are shared
	# between animation players. See Godot issue #30197. (This could be done by
	# loading an animation resource and modifying that, but I only discovered that
	# after writing this code, and it's not that much faster I guess...)
	_animation_player.add_animation("Fade", _create_animation(
		Vector2(start.x - _label.rect_size.x / 2, start.y - _label.rect_size.y)))
	_animation_player.play("Fade")
	
	yield(_animation_player, "animation_finished")
	self.queue_free()


# Creates the animation for the animation player.
func _create_animation(start_point: Vector2) -> Animation:
	var end_point := Vector2(start_point.x, start_point.y - ANIMATION_DISTANCE)
	
	var animation := Animation.new()
	animation.length = 1
	
	# Add a track to animate the position
	var move_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(move_idx, "Label:rect_position")
	animation.track_insert_key(move_idx, 0, start_point)
	animation.track_insert_key(move_idx, 1, end_point)
	
	# ...and a track to fade the thing out
	var fade_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(fade_idx, "Label:modulate")
	animation.track_insert_key(fade_idx, 0, Color(1, 1, 1, 1))
	animation.track_insert_key(fade_idx, 0.3, Color(1, 1, 1, 1))
	animation.track_insert_key(fade_idx, 1, Color(1, 1, 1, 0))
	
	return animation
