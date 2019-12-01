extends Node

# Add to a scene to allow for taking screenshots. This code was adapted from the
# Godot Asset Library's Simple Screenshot Script:
#   https://godotengine.org/asset-library/asset/79
class_name Screenshot


####################################################################################
# Configuration Options

# The UI action that will cause us to take a screenshot.
export var shortcut_action = "" setget set_shortcut_action

# Prefix of screenshot file names.
export var file_prefix = ""

# How screenshot file names are generated.
export(int, 'Datetime', 'Unix Timestamp') var file_tag

# The output directory.
export(String, DIR) var output_path = "res://" setget set_output_path


####################################################################################
# State

# This is basically what the file names will be built with.
var _tag = ""
var _index = 0


####################################################################################
# Scene Lifecycle

func _ready():
	_check_actions([shortcut_action])
	_check_path(output_path)
	
	if not output_path[-1] == "/":
		output_path += "/"
	if not file_prefix.empty():
		file_prefix += "_"
	set_process_input(true)
	
func _input(event):
	if event.is_action_pressed(shortcut_action):
		make_screenshot()


####################################################################################
# Accessors

# Sets the UI action if it exists.
func set_shortcut_action(action):
	_check_actions([action])
	shortcut_action = action

# Sets the output path if it exists.
func set_output_path(path):
	_check_path(path)
	output_path = path


####################################################################################
# Screenshot Taking

# Take a screenshot and save it somewhere.
func make_screenshot():
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")		
	var image = get_viewport().get_texture().get_data()
	image.flip_y()

	_update_tags()
	image.save_png("%s%s%s_%s.png" % [output_path, file_prefix, _tag, _index])


# Check whether the given action IDs are valid.
func _check_actions(actions = []):
	if OS.is_debug_build():
		for action in actions:
			if not InputMap.has_action(action):
				print('WARNING: No action "%s"' % action)

# Checks whether the given directory exists and prints a warning to the
# console if it doesn't.
func _check_path(path):
	if OS.is_debug_build():
		var dir = Directory.new()
		dir.open(path)
		if not dir.dir_exists(path):
			print('WARNING: No directory "%s"' % path)


func _update_tags():
	var time
	if file_tag == 1:
		time = str(OS.get_unix_time())
	else:
		time = OS.get_datetime()
		time = "%s_%02d_%02d_%02d%02d%02d" % [time['year'], time['month'], time['day'], 
											time['hour'], time['minute'], time['second']]
	
	if _tag == time:
		_index += 1
	else:
		_index = 0
	_tag = time	
