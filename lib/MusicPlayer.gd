extends Node

####################################################################################
# Constants and Resources

# Our two extreme volumne levels.
const VOLUME_NORMAL := 0
const VOLUME_SILENT := -80

# Constant specifying that no music is to be played.
const NONE := ""

# Fade time in seconds.
const DEFAULT_FADE_TIME := 1.0


####################################################################################
# Configuration

# The audio bus used to play music.
export var audio_bus: String = "Music"


####################################################################################
# State

# The streams of music we have available for playback.
var _streams := { NONE: null }

# For each stream of music, we have an audio player available. We are using one
# player per piece of music so that we can easily resume each piece where it left
# of the last time.
var _players := {}

# A tween we're using to fade stuff.
var _tween: Tween

# The piece of music we're currently playing.
var _currently_playing: String = NONE


####################################################################################
# Lifecycle

func _ready() -> void:
	# We need a tween to fade music
	_tween = Tween.new()
	_tween.connect("tween_completed", self, "_fade_complete")
	self.add_child(_tween)


####################################################################################
# Stream Management

# Registers the given stream with the music player under the given ID.
func add_stream(id: String, stream: AudioStream) -> void:
	# If there already is a stream with that ID, don't bother
	if _streams.has(id):
		return
	
	# Add a stream player for the stream
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = Constants.MUSIC_BUS
	player.stream = stream
	self.add_child(player)
	
	# Remember stream and player
	_streams[id] = stream
	_players[id] = player


# Removes the stream with the given ID.
func remove_stream(id: String) -> void:
	if _streams.has(id):
		_streams.erase(id)
		
		var player: AudioStreamPlayer = _players[id]
		_players.erase(id)
		self.remove_child(player)
		player.queue_free()


####################################################################################
# Playback

# Plays the given piece of music. Valid pieces of music are defined in the Music
# enumeration.
func play(next_piece: String, fade_time: float = DEFAULT_FADE_TIME) -> void:
	# Reset invalid pieces to silence
	if not _streams.has(next_piece):
		next_piece = NONE
	
	# If the new music is the same as the old, don't bother
	if _currently_playing == next_piece:
		return
	
	# If we don't need to fade anything, we don't need to use the tween
	var use_tween := false
	
	# If we're currently playing a piece of music, that must be faded out
	if _currently_playing != NONE:
		use_tween = true
		_tween.interpolate_property(
			_players[_currently_playing],
			"volume_db",
			VOLUME_NORMAL,
			VOLUME_SILENT,
			fade_time,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN)
	
	if next_piece != NONE:
		var next_player: AudioStreamPlayer = _players[next_piece]
		
		# We need to fade in the new piece of music if we're fading out an existing
		# piece or if the new piece of music has been played before, and is thus in
		# the middle of being played.
		if _currently_playing != NONE or next_player.stream_paused:
			use_tween = true
			_tween.interpolate_property(
				next_player,
				"volume_db",
				VOLUME_SILENT,
				VOLUME_NORMAL,
				fade_time,
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
