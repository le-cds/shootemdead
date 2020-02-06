tool
extends Label

# This is a label which can toggle between two colours. Excellent for getting
# on people's nerves.
class_name BlinkingLabel


####################################################################################
# Configuration Options

# The colors we want to run through.
export (Array, Color) var colors: Array setget set_colors

# The time in milliseconds before we switch to the next color.
export (float, 0.01, 10) var delay: float

# Whether we're currently blinking.
export var running: bool setget set_running


####################################################################################
# State

# The current color's index.
var _current_color := 0

# Time since we last activated a color.
var _time_since_last_color := 0.0


####################################################################################
# Scene Lifecycle

func _init() -> void:
	._init()
	
	# Disable processing while we're not running
	set_process(false)


func _process(delta: float) -> void:
	_time_since_last_color += delta
	
	# If it's time for a color change, do it
	if _time_since_last_color >= delay:
		var colors_to_advance: int = int(_time_since_last_color / delay)
		_time_since_last_color -= colors_to_advance * delay
		_activate_color(_current_color + colors_to_advance)
	


####################################################################################
# Getters / Setters

func set_colors(c: Array) -> void:
	colors = c
	
	# If we have at least one color, reset us to that first color
	if _color_count() > 0:
		_activate_color(0)


func set_running(run: bool) -> void:
	if running != run:
		running = run
		
		# It only makes sense to actually switch between colors if we have colors to
		# switch between in the first place.
		set_process(running and _color_count() > 1)


####################################################################################
# Utilities

# Checks how many colors we have.
func _color_count() -> int:
	if colors:
		return colors.size()
	else:
		return 0


# Activates the color with the given index, modulo the number of colors. Also saves
# the new color as the currently active one.
func _activate_color(index: int) -> void:
	index = index % colors.size()
	set("custom_colors/font_color", colors[index])
	
	_current_color = index
	_time_since_last_color = 0
