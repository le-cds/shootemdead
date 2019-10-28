extends Building


####################################################################################
# Scene Objects

onready var front: TextureRect = $Front
onready var enemy_zone_roof: Path2D = $EnemyZones/Roof
onready var enemy_zone_street: Path2D = $EnemyZones/Street


####################################################################################
# Scene Lifecycle

func _ready():
	# This randomly sets its size such that the texture is repeated an
	# integer amount of times.
	var texture_size: Vector2 = front.texture.get_size()
	
	var x_scale = randi() % 5 + 2
	var y_scale = randi() % 7 + 2
	
	front.rect_size.x = x_scale * texture_size.x
	front.rect_size.y = y_scale * texture_size.y
	
	# We need to setup our enemy spawn areas now
	var roof_curve: Curve2D = enemy_zone_roof.curve
	roof_curve.add_point(Vector2(0, 0))
	roof_curve.add_point(Vector2(front.rect_size.x - Constants.MAX_ENEMY_WIDTH, 0))
	
	var street_curve: Curve2D = enemy_zone_street.curve
	var street_y: float = front.rect_size.y + 30
	street_curve.add_point(Vector2(0, street_y))
	street_curve.add_point(Vector2(front.rect_size.x - Constants.MAX_ENEMY_WIDTH, street_y))


####################################################################################
# Building

func get_building_position() -> Vector2:
	return get_position()


func set_building_position(pos: Vector2) -> void:
	set_position(pos)


func get_building_size() -> Vector2:
	return Vector2(front.rect_size.x, front.rect_size.y)


func random_enemy_position() -> Vector2:
	var spawn_zone: Path2D
	if randi() % 2 == 0:
		spawn_zone = enemy_zone_roof
	else:
		spawn_zone = enemy_zone_street
	
	# Return a random point somewhere along the spawn zone
	return spawn_zone.curve.interpolate(0, randf())
