extends Node2D

# This class spawns scenes and lets them scroll through the screen from right to
# left at a configurable speed. Scenes are spawned with a configurable spacing
# between them at the y coordinate this node is placed at. They are freed once
# they have left the screen. The scenes are added to the scene graph as children
# of this node.
class_name EndlessSidescroller


# Triggered when a new scene has been spawned.
signal scene_spawned(scene)

# Triggered when a scene left the screen.
signal scene_left(scene)


# The scene to be spawned. This must be set for the whole thing to work. A scene
# spawned by this thing must either be a Control or a Sprite.
export (PackedScene) var scene

# The width of this sidescroller. New scenes are spawned to the right.
export var sidescroller_width := 100

# The distance between two scenes.
export var distance := 10

# If true, we will fill the screen with spawned scenes during initialization.
# Otherwise, we will start spawning only when physics processing starts.
export var pre_spawn := false

# Number of pixels per second the objects should basically move with. The base
# speed can be modified by setting the speed factor.
export var base_speed := 20

# Speed factor. The base speed gets multiplied by this to arrive at the actual
# speed.  This allows for controlling different sidescrollers with the same base
# speed, while modifying each one to achieve a kind of parallax effect.
export var speed_factor := 1.0

# If this is not empty, spawned scenes will be added to a group of the same name
# for easy access.
export var spawn_group := ""

# Whether this is actually running at the moment.
export var running := false


# The most recently added scene.
var last_scene: CanvasItem = null

# The distance we have accumulated by now. Whenever this gets at least 1, we move
# all of the spawned scenes by the accumulated integer amount and reset this.
var accumulated_distance := 0.0


func _ready() -> void:
	# If we should pre_spawn, this is the moment to do so
	if pre_spawn:
		var x = distance
		
		while x < sidescroller_width:
			_spawn(x)
			
			# If we were not able to instantiate the scene, last_scene will be null
			# and it won't make sense to continue
			if last_scene == null:
				break
			else:
				x += _get_width(last_scene) + distance


# Moves the scenes along and spawns a new one, if necessary.
func _physics_process(delta) -> void:
	if running:
		accumulated_distance += base_speed * speed_factor * delta
		
		# If we have accumulated a distance of at least one pixel, move all of our
		# children along
		if accumulated_distance >= 1.0:
			var integer_distance = floor(accumulated_distance)
			for child in get_children():
				_move(child, integer_distance)
			
			# Reset the accumulated distance
			accumulated_distance -= integer_distance
		
			# Check if the first child has to be removed
			if get_child_count() > 0:
				var leftmost_child = get_child(0)
				if _get_x(leftmost_child) + _get_width(leftmost_child) < 0:
					_despawn(leftmost_child)
			
		# Check if it's time to spawn the next scene
		if last_scene != null:
			var next_x = _get_x(last_scene) + _get_width(last_scene) + distance
			
			# Already spawn a new scene a bit earlier than strictly necessary
			if next_x < sidescroller_width + 5:
				_spawn(next_x)
		
		else:
			_spawn(sidescroller_width + 5)


# Spawns a copy of our scene at the given x coordinate and our own y coordinate. Also
# triggers the scene_spawned signal. After this method has finished, last_scene will
# contain a reference to the spawned scene.
func _spawn(x: int) -> void:
	var new_scene = scene.instance()
	
	# If we support the scene's root type, initialize it, add it to our list of
	# children and tell the world about it
	if _is_valid_scene(new_scene):
		if spawn_group.length() > 0:
			new_scene.add_to_group(spawn_group)
		
		_set_x(new_scene, x)
		
		add_child(new_scene)
		emit_signal("scene_spawned", new_scene)
		
		last_scene = new_scene


# Removes the given scene and triggers the scene_left signal.
func _despawn(scene: CanvasItem):
	scene.queue_free()
	emit_signal("scene_left", scene)


# Moves the given child scene the given distance to the left. If that causes the scene
# to leave the screen, queues the scene for removal and triggers the scene_left signal.
func _move(scene: CanvasItem, distance: float) -> void:
	_set_x(scene, _get_x(scene) - distance)


# Checks wether the scene's root object is one we can work with.
func _is_valid_scene(scene: Object) -> bool:
	return scene is Control or scene is Sprite


# Returns the x coordinate or the given scene's left boundary.
func _get_x(scene: CanvasItem) -> float:
	assert(_is_valid_scene(scene))
	
	if scene is Control:
		var control: Control = scene as Control
		return control.rect_position.x
		
	elif scene is Sprite:
		# The x coordinate marks the sprite's center
		var sprite: Sprite = scene as Sprite
		return sprite.position.x - sprite.get_rect().size.x
	
	else:
		# This shoud not happen
		return 0.0


# Ensures the given scene's left boundary ends up at (local) coordinate x.
func _set_x(scene: CanvasItem, x: float) -> void:
	assert(_is_valid_scene(scene))
	
	if scene is Control:
		var control: Control = scene as Control
		control.rect_position.x = x
		
	elif scene is Sprite:
		# The x coordinate marks the sprite's center
		var sprite: Sprite = scene as Sprite
		sprite.position.x = x + sprite.get_rect().size.x


# Returns the width of the scene's root object (if it's an object we know).
func _get_width(scene: CanvasItem) -> float:
	assert(_is_valid_scene(scene))
	
	if scene is Control:
		var control: Control = scene as Control
		return control.rect_size.x
		
	elif scene is Sprite:
		var sprite: Sprite = scene as Sprite
		return sprite.get_rect().size.x
	
	else:
		# This should not happen
		return 1.0
