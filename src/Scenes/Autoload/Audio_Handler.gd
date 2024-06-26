#Singleton that initializes a node of type audio stream player and deletes instances after 
#audio is played
extends Node

enum Type {
	NON_POSITIONAL,
	POSITIONAL_2D,
}

@onready var audio_stream_player: Node


func _ready() -> void:
	self.process_mode = 3


func play(type: int, parent: Node, stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	match type:
		Type.NON_POSITIONAL:
			audio_stream_player = AudioStreamPlayer.new()
		Type.POSITIONAL_2D:
			audio_stream_player = AudioStreamPlayer2D.new()
	
	audio_stream_player.add_to_group("audio")
	audio_stream_player.process_mode = 3

	parent.add_child(audio_stream_player)
	audio_stream_player.bus = "Effects"
	audio_stream_player.stream = stream
	audio_stream_player.volume_db = volume_db
	audio_stream_player.pitch_scale = pitch_scale
	audio_stream_player.play()
	audio_stream_player.connect("finished", _remove)


func _remove() -> void:
	GarbageCollector.clear_group("audio")
