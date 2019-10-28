extends Node2D

# A building has a size and a position. The latter can be set. Buildings can
# also generate random positions appropriate for spawning enemies.
class_name Building


# Returns the position of the building's top left corner.
func get_building_position() -> Vector2:
	return Vector2(0, 0)


# Sets the position of the building's top left corner.
func set_building_position(pos: Vector2) -> void:
	pass


# Returns the building's size. This is the building itself, without any enemies.
func get_building_size() -> Vector2:
	return Vector2(0, 0)


# Returns a position where an enemy can be spawned. The position will end up
# being the enemy's bottom left corner.
func random_enemy_position() -> Vector2:
	return Vector2(0, 0)
