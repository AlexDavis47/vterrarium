@tool
extends Node


## Generate a unique ID
func generate_unique_id() -> String:
	return str(randi()) + str(int(Time.get_unix_time_from_system()))


## Play a sound effect
func play_sfx(sfx: AudioStream, min_pitch: float = 1.0, max_pitch: float = 1.0) -> void:
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sfx_player.stream = sfx
	sfx_player.pitch_scale = randf_range(min_pitch, max_pitch)
	get_tree().root.add_child(sfx_player)
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)
