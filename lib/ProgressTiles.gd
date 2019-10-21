tool
extends Control

# This class is a kind of progress bar that only allows integer ranges and
# shows them with tiles based on textures. The number of tiles displayed
# correspond to the maximum displayable value. Tiles may be arranged
# horizontally or vertically, and may be filled from the beginning (left
# or top) or the end.
class_name ProgressTiles


####################################################################################
# Types

# How the tiles will be laid out.
enum LayoutMode { HORIZONTAL, VERTICAL }

# From where the progress bar will be filled.
enum FillMode { FROM_START, FROM_END }


####################################################################################
# Configuration Options

# The texture to be used for filled tiles.
export (Texture) var filled_texture: Texture setget set_filled_texture
# The texture to be used for empty tiles.
export (Texture) var empty_texture: Texture setget set_empty_texture
# Whether to layout the tiles horizontally or vertically.
export (LayoutMode) var layout_mode := LayoutMode.HORIZONTAL setget set_layout_mode
# Whether to fill the tiles from the start (top or left) or the end.
export (FillMode) var fill_mode := FillMode.FROM_START setget set_fill_mode
# Gap between adjacent tiles
export (int) var gap := 0 setget set_gap
# The number of tiles to display.
export (int, 40) var max_value := 5 setget set_max_value
# The number of filled tiles.
export (int, 40) var value := 2 setget set_value


####################################################################################
# State

# The size we require to draw all tiles.
var _size := Vector2(0, 0)


####################################################################################
# Drawing

func _draw() -> void:
	# Skip all this if there is nothing we could draw
	if filled_texture == null or max_value == 0:
		return
	
	var curr_pos: Vector2 = _compute_start_position()
	var pos_delta: Vector2 = _compute_position_delta()
	
	# Draw filled tiles
	for i in range(value):
		draw_texture(filled_texture, curr_pos)
		curr_pos += pos_delta
	
	# Draw empty tiles, if the texture is set
	if empty_texture != null:
		for i in range(max_value - value):
			draw_texture(empty_texture, curr_pos)
			curr_pos += pos_delta


# Computes where we need to start drawing the first tile.
func _compute_start_position() -> Vector2:
	var result: Vector2
	
	if fill_mode == FillMode.FROM_START:
		result = Vector2(0, 0)
	else:
		if layout_mode == LayoutMode.HORIZONTAL:
			result = Vector2(_size.x - filled_texture.get_width(), 0)
		else:
			result = Vector2(_size.y - filled_texture.get_height(), 0)
	
	return result


# Computes how we get from one tile's position to the next
func _compute_position_delta() -> Vector2:
	var result: Vector2
	
	if layout_mode == LayoutMode.HORIZONTAL:
		result = Vector2(filled_texture.get_width() + gap, 0)
	else:
		result = Vector2(0, filled_texture.get_height() + gap)
	
	if fill_mode == FillMode.FROM_END:
		result *= -1
	
	return result


####################################################################################
# Control Stuff

# Updates our minimum size based on our current settings.
func _update_minimum_size() -> void:
	# Check whether we have anything to work with
	if filled_texture != null and max_value > 0:
		# The side along which we arrange the tiles
		var long_side_length := 0.0
		if layout_mode == LayoutMode.HORIZONTAL:
			long_side_length = filled_texture.get_width()
		else:
			long_side_length = filled_texture.get_height()
		
		# Account for gaps
		long_side_length *= max_value
		long_side_length += gap * (max_value - 1)
		
		if layout_mode == LayoutMode.HORIZONTAL:
			_size = Vector2(long_side_length, filled_texture.get_height())
		else:
			_size = Vector2(filled_texture.get_width(), long_side_length)
	else:
		_size = Vector2(0, 0)
	
	set_custom_minimum_size(_size)


####################################################################################
# Getters and Setters

func set_filled_texture(texture: Texture) -> void:
	filled_texture = texture
	_update_minimum_size()
	update()


func set_empty_texture(texture: Texture) -> void:
	empty_texture = texture
	update()


func set_layout_mode(mode: int) -> void:
	if mode != layout_mode and mode in LayoutMode.values():
		layout_mode = mode
		_update_minimum_size()
		update()
	else:
		push_error("Invalid layout mode: " + str(mode))


func set_fill_mode(mode: int) -> void:
	if mode != fill_mode and mode in FillMode.values():
		fill_mode = mode
		update()
	else:
		push_error("Invalid fill mode: " + str(mode))


func set_gap(new_gap: int) -> void:
	if gap != new_gap:
		gap = new_gap
		_update_minimum_size()
		update()


func set_max_value(new_max_value: int) -> void:
	if new_max_value >= 0:
		max_value = new_max_value
		value = int(max(max_value, new_max_value))
		_update_minimum_size()
		update()


func set_value(new_value: int) -> void:
	if new_value != value && new_value >= 0 && new_value <= max_value:
		value = new_value
		update()


####################################################################################
# Editor Support

func _get_configuration_warning():
	if filled_texture == null:
		return "The filled texture must be set."
	
	return ""
