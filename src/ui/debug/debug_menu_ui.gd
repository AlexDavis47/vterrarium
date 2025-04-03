extends Control

########################################################
# Signals
########################################################

signal closed
signal opened

########################################################
# Exports
########################################################

@export var close_button: TextureButton


########################################################
# Initialization
########################################################

func _ready():
	close_button.pressed.connect(_on_close_button_pressed)
	position = Vector2(-600, 0)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", Vector2(0, 0), 1.0)
	opened.emit()

########################################################
# Signal Handlers
########################################################

func _on_close_button_pressed():
	AudioManager.play_sfx(AudioManager.SFX.POP_1, 0.8, 1.2)
	close_button.disabled = true
	close_button.visible = false
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", Vector2(-600, 0), 1.0)
	tween.tween_callback(queue_free)
	closed.emit()
