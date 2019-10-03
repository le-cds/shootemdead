extends TextureRect

# This randomly sets its size such that the texture is repeated an
# integer amount of times.
func _ready():
	var texture_size: Vector2 = texture.get_size()
	
	var x_scale = randi() % 6 + 1
	var y_scale = randi() % 8 + 1
	
	rect_size.x = x_scale * texture_size.x
	rect_size.y = y_scale * texture_size.y
