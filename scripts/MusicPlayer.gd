extends Node

####################################################################################
# Constants and Resources

# Enumeration of the pieces of music we have.
enum Music {
	MENU_MUSIC,
	GAME_MUSIC,
	SILENCE
}

# Volume of normal 
const VOLUME_NORMAL := 0
const VOLUME_SILENT := -80

# Fade time in seconds.
const FADE_TIME := 1.0

# Array of available music streams, in the same order as the enumeration
# constants..
var _streams = [
	preload("res://assets/Music/false_awakenings.ogg"),
	preload("res://assets/Music/local_forecast.ogg")
]


####################################################################################
# Scene Objects

# Array of audio stream players. We are using one player per piece of music so that
# we can easily resume each piece where it left of the last time.
var _players: Array

# A tween we're using to fade stuff.
var _tween: Tween


####################################################################################
# State

# The piece of music we're currently playing.
var _currently_playing: int = Music.SILENCE


####################################################################################
# Lifecycle

func _ready() -> void:
	# We need a tween to fade music
	_tween = Tween.new()
	_tween.connect("tween_completed", self, "_fade_complete")
	self.add_child(_tween)
	
	# Create players for each piece of music and load everything up
	_players = []
	for stream in _streams:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = Constants.MUSIC_BUS
		player.stream = stream
		
		_players.append(player)
		self.add_child(player)


####################################################################################
# Functionality

# Plays the given piece of music. Valid pieces of music are defined in the Music
# enumeration.
func play(next_piece: int) -> void:
	# Reset invalid pieces to silence
	if next_piece < 0 or next_piece >= _streams.size():
		next_piece = Music.SILENCE
	
	# If the new music is the same as the old, don't bother
	if _currently_playing == next_piece:
		return
	
	# If we don't need to fade anything, we don't need to use the tween
	var use_tween := false
	
	# If we're currently playing a piece of music, that must be faded out
	if _currently_playing != Music.SILENCE:
		use_tween = true
		_tween.interpolate_property(
			_players[_currently_playing],
			"volume_db",
			VOLUME_NORMAL,
			VOLUME_SILENT,
			FADE_TIME,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN)
	
	if next_piece != Music.SILENCE:
		var next_player: AudioStreamPlayer = _players[next_piece]
		
		# We need to fade in the new piece of music if we're fading out an existing
		# piece or if the new piece of music has been played before, and is thus in
		# the middle of being played.
		if _currently_playing != Music.SILENCE or next_player.stream_paused:
			use_tween = true
			_tween.interpolate_property(
				next_player,
				"volume_db",
				VOLUME_SILENT,
				VOLUME_NORMAL,
				FADE_TIME,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN)
			
			# Resume or start playing
			if next_player.playing:
				next_player.stream_paused = false
			else:
				next_player.play()
			
		else:
			# Simply start the music
			next_player.play()
	
	if use_tween:
		_tween.start()
	
	_currently_playing = next_piece


func _fade_complete(object: Object, path: NodePath) -> void:
	# The object will be an AudioStreamPlayer
	var player: AudioStreamPlayer = object as AudioStreamPlayer
	
	# If the player was faded out, pause it
	if player.volume_db < VOLUME_SILENT + 2:
		player.stream_paused = true
