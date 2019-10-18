extends Node

# Provides access to game settings and takes care of loading and saving them. In
# a larger game, this class would only be responsible for loading and saving
# settings as well as triggering events when settings are changed (the audio
# engine might listen for those and adapt volume levels accordingly). In this
# small game, however, this class is simply responsible for applying the few
# settings we have.


####################################################################################
# Settings

const _SETTINGS_PATH := "user://settings.cnf"

const _SETTINGS_SECTION := "Settings"

const _MUSIC_VOLUME := "music_volume"
const _SOUND_VOLUME := "sound_volume"
const _GORE_OPTION := "gore"

var _settings := {
	_MUSIC_VOLUME: 0.8,
	_SOUND_VOLUME: 1.0,
	_GORE_OPTION: 1
}


####################################################################################
# Scene Lifecycle

func _init() -> void:
	_load_settings()


####################################################################################
# Getters and Setters

func get_music_volume() -> float:
	return _settings[_MUSIC_VOLUME]

func set_music_volume(volume: float) -> void:
	if volume >= 0.0 and volume <= 1.0:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(Constants.MUSIC_BUS),
			linear2db(volume))
		_settings[_MUSIC_VOLUME] = volume

func get_sound_volume() -> float:
	return _settings[_SOUND_VOLUME]

func set_sound_volume(volume: float) -> void:
	if volume >= 0.0 and volume <= 1.0:
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index(Constants.SOUND_BUS),
			linear2db(volume))
		_settings[_SOUND_VOLUME] = volume

func get_gore_option() -> int:
	return _settings[_GORE_OPTION]

func set_gore_option(gore: int) -> void:
	if gore >= 1 and gore <= 2:
		_settings[_GORE_OPTION] = gore


####################################################################################
# Loading / Saving

# Loads all settings from the settings file, if one exists. Automatically called
# during initialization.
func _load_settings() -> void:
	var config_file := ConfigFile.new()
	var err = config_file.load(_SETTINGS_PATH)
	
	if err == OK:
		set_music_volume(config_file.get_value(
			_SETTINGS_SECTION, _MUSIC_VOLUME, _settings[_MUSIC_VOLUME]))
		set_sound_volume(config_file.get_value(
			_SETTINGS_SECTION, _SOUND_VOLUME, _settings[_SOUND_VOLUME]))
		set_gore_option(config_file.get_value(
			_SETTINGS_SECTION, _GORE_OPTION, _settings[_GORE_OPTION]))


# Savess all settings to the settings file.
func save_settings() -> void:
	var config_file := ConfigFile.new()
	
	for key in _settings:
		config_file.set_value(_SETTINGS_SECTION, key, _settings[key])
	
	config_file.save(_SETTINGS_PATH)
