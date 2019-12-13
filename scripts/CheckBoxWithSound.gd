extends CheckBox

# This is a button which is happy to play sounds when the mouse cursor enters it
# or clicks on it. This button is hard-coded for our sounds through defaults.
class_name CheckBoxWithSound


# The sound we play when the mouse cursor enters us.
export(AudioStream) var hover_sound: AudioStream = preload("res://assets/Sounds/menu_hover.ogg")
# The sound we play when the mouse cursor clicks us.
export(AudioStream) var click_sound: AudioStream = preload("res://assets/Sounds/menu_select.ogg")


func _init() -> void:
	# We'll listen for button presses
	connect("button_down", self, "_play_click_sound")


func _notification(what) -> void:
	match what:
		NOTIFICATION_MOUSE_ENTER:
			if hover_sound:
				SoundPlayer.play_sound(self, hover_sound)


func _play_click_sound() -> void:
	if click_sound:
		SoundPlayer.play_sound(self, click_sound)
