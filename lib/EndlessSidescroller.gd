tool
extends Node2D

# This class spawns scenes and lets them scroll through the screen from right to
# left at a configurable speed. Scenes are spawned with a configurable spacing
# between them at the y coordinate this node is placed at. They are freed once
# they have left the screen. The scenes are added to the scene graph as children
# of this node.
class_name EndlessSidescroller


####################################################################################
# Types

# Enumerates the possible ways for choosing the next scene.
enum SceneSelectionMode { LINEAR, RANDOM }


####################################################################################
# Signals

# Triggered when a new scene has been spawned.
signal scene_spawned(scene)

# Triggered when a scene left the screen.
signal scene_left(scene)


####################################################################################
# Configuration Options

# Possible scenes to be spawned. This must contain at least one scene for the
# whole thing to work. When a new scene needs to be spawned, this will either
# go through the scenes in linear succession, or choose a random one. A scene
# spawned by this thing must either be a Control or a Sprite.
export (Array, PackedScene) var scenes

# How to choose the next scene to be spawned.
export (SceneSelectionMode) var scene_selection := SceneSelectionMode.RANDOM

# The width of this sidescroller. New scenes are spawned to the right.
export (int, 20, 5000) var sidescroller_width := 100 setget set_sidescroller_width

# The distance between two scenes.
export (int, 0, 5000) var distance := 10

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


####################################################################################
# State

# Index of the most recently spawned scene in our list of scenes.
var last_scene_index := -1

# The most recently added scene.
var last_scene: CanvasItem = null

# The distance we have accumulated by now. Whenever this gets at least 1, we move
# all of the spawned scenes by the accumulated integer amount and reset this.
var accumulated_distance := 0.0


####################################################################################
# Object Lifecycle

func _ready() -> void:
	# Disable processing if we're running in the editor
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return
	
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
				x += _get_size(last_scene).x + distance


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
				if _get_right_border_x(leftmost_child) < 0:
					_despawn(leftmost_child)
			
		# Check if it's time to spawn the next scene
		if last_scene != null:
			var next_x = _get_right_border_x(last_scene) + distance
			
			# Already spawn a new scene a bit earlier than strictly necessary
			if next_x < sidescroller_width + 5:
				_spawn(next_x)
		
		else:
			_spawn(sidescroller_width + 5)


####################################################################################
# Accessors

# Updates the node if the width changes and we're in the editor, since the width
# is visualized there.
func set_sidescroller_width(new_width: int) -> void:
	sidescroller_width = new_width
	if Engine.editor_hint:
		update()


####################################################################################
# Scene Spawning / Despawning

# Spawns a copy of our scene at the given x coordinate and our own y coordinate. Also
# triggers the scene_spawned signal. After this method has finished, last_scene will
# contain a reference to the spawned scene.
func _spawn(x: int) -> void:
	# Try to get our hands upon a scene that we can instantiate
	var new_packed_scene = _choose_next_scene()
	if new_packed_scene == null:
		return
	
	var new_scene = new_packed_scene.instance()
	
	# If we support the scene's root type, initialize it, add it to our list of
	# children and tell the world about it
	if _is_supported_scene(new_scene):
		if spawn_group.length() > 0:
			new_scene.add_to_group(spawn_group)
		
		_set_position(new_scene, Vector2(x, 0))
		
		add_child(new_scene)
		emit_signal("scene_spawned", new_scene)
		
		last_scene = new_scene


# Chooses the next scene to be spawned, subject to the 
func _choose_next_scene() -> PackedScene:
	if scenes == null or scenes.size() == 0:
		# Nothing to spawn
		return null
	
	elif scenes.size() == 1:
		# Only one possible scene
		return scenes[0]
	
	else:
		# What we do now depends on our scene selection mode...
		match scene_selection:
			SceneSelectionMode.LINEAR:
				# Simply return the next scene
				last_scene_index += 1
				return scenes[last_scene_index % scenes.size()]
				
			SceneSelectionMode.RANDOM:
				if last_scene_index == -1:
					# If we never returned a scene, we can simply choose a random one
					last_scene_index = randi() % scenes.size()
				else:
					# Don't choose the same scene that we chose before
					var rand_index = randi() % (scenes.size() - 1)
					if rand_index >= last_scene_index:
						rand_index += 1
					last_scene_index = rand_index
				
				return scenes[last_scene_index]


# Removes the given scene and triggers the scene_left signal.
func _despawn(scene: CanvasItem):
	scene.queue_free()
	emit_signal("scene_left", scene)


# Checks wether the scene's root object is one we can work with.
func _is_supported_scene(scene: Object) -> bool:
	return scene is Control or scene is Sprite


####################################################################################
# Scene Movement

# Moves the given child scene the given distance to the left. If that causes the
# scene to leave the screen, queues the scene for removal and triggers the
# scene_left signal.
func _move(scene: CanvasItem, distance: float) -> void:
	var pos: Vector2 = _get_position(scene)
	var size: Vector2 = _get_size(scene)
	
	pos.x -= distance
	pos.y = -size.y
	
	_set_position(scene, pos)


# Returns the position of the given scene's top left corner. Modifications to the
# vector won't influence the scene's actual position.
func _get_position(scene: CanvasItem) -> Vector2:
	assert(_is_supported_scene(scene))
	
	if scene is Control:
		var control: Control = scene as Control
		var pos: Vector2 = control.rect_position
		return Vector2(pos.x, pos.y)
	
	elif scene is Sprite:
		# The position marks the sprite's center
		var sprite: Sprite = scene as Sprite
		var pos: Vector2 = sprite.position
		var size: Vector2 = sprite.get_rect().size
		return Vector2(pos.x - size.x / 2, pos.y - size.y / 2)
	
	else:
		return Vector2(0, 0)


# Sets the position of the given scene's top left corner.
func _set_position(scene: CanvasItem, new_pos: Vector2) -> void:
	assert(_is_supported_scene(scene))
	
	if scene is Control:
		var control: Control = scene as Control
		control.rect_position.x = new_pos.x
		control.rect_position.y = new_pos.y
		
	elif scene is Sprite:
		# The position marks the sprite's center
		var sprite: Sprite = scene as Sprite
		var size: Vector2 = sprite.get_rect().size
		sprite.position.x = new_pos.x + size.x / 2
		sprite.position.y = new_pos.y + size.y / 2


# Returns the width of the scene's root object (if it's an object we know).
func _get_size(scene: CanvasItem) -> Vector2:
	assert(_is_supported_scene(scene))
	
	if scene is Control:
		var control: Control = scene as Control
		return control.rect_size
		
	elif scene is Sprite:
		var sprite: Sprite = scene as Sprite
		return sprite.get_rect().size
	
	else:
		# This should not happen
		return Vector2(1, 1)


# Convenience method to return the x coordinate of the scene's right border.
func _get_right_border_x(scene: CanvasItem) -> float:
	return _get_position(scene).x + _get_size(scene).x


####################################################################################
# Editor Support

func _get_configuration_warning():
	if scenes == null or scenes.size() == 0:
		return "You must configure at least one scene to be spawned."
	
	return ""


# Draws the extent of our sidescrolling area
func _draw():
	# Only draw stuff if we're inside the editor
	if not Engine.editor_hint:
		return
	
	draw_line(Vector2(0, 0), Vector2(sidescroller_width - 1, 0), Color.gray, 2)
