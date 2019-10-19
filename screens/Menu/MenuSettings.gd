extends State


####################################################################################
# CONSTANTS

const ANIMATION_BUTTONS := "fade"


####################################################################################
# Scene Objects

onready var _animator: AnimationPlayer = $AnimationPlayer

onready var _music_volume: Slider = $VBoxContainer/SettingsContainer/VBoxContainer/MusicVolume
onready var _sound_volume: Slider = $VBoxContainer/SettingsContainer/VBoxContainer/SoundVolume
onready var _gore_option_1: CheckBox = $VBoxContainer/SettingsContainer/VBoxContainer/GoreOption1
onready var _gore_option_2: CheckBox = $VBoxContainer/SettingsContainer/VBoxContainer/GoreOption2


####################################################################################
# Scene Lifecycle

func _ready():
	# We want to play animations when pausing
	set_yield_on_pause(true)


####################################################################################
# State Lifecycle

func state_started(prev_state: State) -> void:
	.state_started(prev_state)
	
	# Initialize the values of our controls
	_music_volume.value = Settings.get_music_volume()
	_sound_volume.value = Settings.get_sound_volume()
	
	var gore: int = Settings.get_gore_option()
	_gore_option_1.pressed = gore == 1
	_gore_option_2.pressed = gore == 2
	
	# Animate animations!
	_animator.play(ANIMATION_BUTTONS)


func state_paused(next_state: State) -> void:
	.state_paused(next_state)
	
	# Animate animations!
	_animator.play_backwards(ANIMATION_BUTTONS)
	yield(_animator, "animation_finished")


####################################################################################
# Event Handling

func _on_MusicVolume_value_changed(value):
	Settings.set_music_volume(value)


func _on_SoundVolume_value_changed(value):
	Settings.set_sound_volume(value)


func _on_GoreOption1_toggled(button_pressed):
	Settings.set_gore_option(1)


func _on_GoreOption2_toggled(button_pressed):
	Settings.set_gore_option(2)


func _on_BackButton_pressed() -> void:
	Settings.save_settings()
	transition_pop()
