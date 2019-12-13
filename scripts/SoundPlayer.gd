extends Node

func play_sound(parent: Node, stream: AudioStream, bus: String = "Sounds", volumne: float = 0.0) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = bus
	player.stream = stream
	player.volume_db = volumne
	
	# Add the player to our node and play away!
	parent.add_child(player)
	player.play()
	
	# Be sure the player disappears once it has finished
	player.connect("finished", player, "queue_free")
