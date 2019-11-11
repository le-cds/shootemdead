tool
extends TextureRect

# This is a TextureRect that can show a sequence of textures, either once
# or in constant rotation. Fades between textures are done by modifying the
# modulation color. The slideshow must be started by calling start().
class_name Slideshow


####################################################################################
# Signals

# Triggered when the slideshow finished. Only triggered when the slideshow is not
# on repeat.
signal slideshow_finished()


####################################################################################
# Configuration Options

# The textures to show in the slideshow.
export (Array, Texture) var textures: Array

# How long to display each texture.
export var display_time := 2.0

# How long fades should be. If this is zero, we don't fade, but simply hide or
# show textures directly.
export var fade_time := 1.0

# Time between fading out one texture and fading in the next.
export var black_time := 0.1

# Whether to repeat the slideshow once it has finished.
export var repeat := false


####################################################################################
# State

const NO_TEXTURE := -1
const COLOR_SOLID := Color(1.0, 1.0, 1.0, 1.0)
const COLOR_TRANSPARENT := Color(1.0, 1.0, 1.0, 0.0)

# Index of the texture that we're currently showing, fading in, or fading out.
var _curr_texture_index := NO_TEXTURE
# Whether the slideshow is currently running.
var _running := false

# A tween we'll use to fade things.
var _tween: Tween


####################################################################################
# Scene Lifecycle

func _init() -> void:
	_tween = Tween.new()
	self.add_child(_tween)


####################################################################################
# Slideshow

# Starts the slideshow, unless it is already running.
func start() -> void:
	if not _running:
		_curr_texture_index = NO_TEXTURE
		_running = true
		_show_next()


func _show_next() -> void:
	# Don't do anything if there are no textures
	if textures == null or textures.empty():
		return
	
	# If we have a current texture, we need to fade that out
	var had_previous_texture := false
	if _curr_texture_index != NO_TEXTURE:
		had_previous_texture = true
		
		# Fade out slide, if necessary (if we don't need to fade out, but there
		# also isn't a next texture, we'll remove the current texture below)
		if fade_time > 0.0:
			_tween.interpolate_property(
				self,
				"modulate",
				COLOR_SOLID,
				COLOR_TRANSPARENT,
				fade_time,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN)
			_tween.start()
			yield(_tween, "tween_completed")
	
	# If we're currently showing the last texture but are set to repeat, we need
	# to jump back to the first
	_curr_texture_index += 1
	if repeat:
		_curr_texture_index %= textures.size()
	
	# If we have a next slide, excellent. Otherwise, we're through!
	if _curr_texture_index < textures.size():
		# Wait a while, if necessary
		if had_previous_texture and black_time > 0.0:
			yield(get_tree().create_timer(black_time), "timeout")
		
		# Actually set the texture
		self.texture = textures[_curr_texture_index]
		
		# Fade in slide, if necessary
		if fade_time > 0.0:
			_tween.interpolate_property(
				self,
				"modulate",
				COLOR_TRANSPARENT,
				COLOR_SOLID,
				fade_time,
				Tween.TRANS_LINEAR,
				Tween.EASE_OUT)
			_tween.start()
			yield(_tween, "tween_completed")
		
		# Schedule this method to be called again
		_tween.interpolate_deferred_callback(self, display_time, "_show_next")
		_tween.start()
		
	else:
		# Be sure that we're not displaying anything
		self.texture = null
		
		# There is no next slide; signal the signal!
		_running = false
		emit_signal("slideshow_finished")


####################################################################################
# Editor Support

func _get_configuration_warning():
	if textures == null or textures.empty():
		return "You must configure at least one texture."
	
	return ""
