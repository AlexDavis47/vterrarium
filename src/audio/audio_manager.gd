extends Node

enum SFX {
    POP_1,
    POP_2,
    UI_CLICK_1,
    SPLASH_1,
	COINS_1
}


var _sfx_dictionary: Dictionary[SFX, AudioStream] = {
	SFX.POP_1: preload("uid://bi6tqac60bnfl"),
	SFX.POP_2: preload("uid://brmcgndjuf2t3"),
	SFX.UI_CLICK_1: preload("uid://bms5rd1xu82xc"),
    SFX.SPLASH_1: preload("uid://cqlml5h7eycko"),
	SFX.COINS_1: preload("uid://bjnanq3yimdky")
}


## Play a sound effect
func play_sfx(sfx: SFX, min_pitch: float = 1.0, max_pitch: float = 1.0) -> void:
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sfx_player.stream = _sfx_dictionary[sfx]
	sfx_player.pitch_scale = randf_range(min_pitch, max_pitch)
	get_tree().root.add_child(sfx_player)
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)
