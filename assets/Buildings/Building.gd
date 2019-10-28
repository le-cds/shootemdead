extends Node2D

# A building has a size and a position. The latter can be set. Buildings can
# also generate random positions appropriate for spawning enemies.
class_name Building


func get_position() -> Vector2:
	return Vector2(0, 0)

func set_position(pos: Vector2) -> void:
	pass

func get_size() -> Vector2:
	return Vector2(0, 0)
