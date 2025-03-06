extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	Config.debug_mode = not Config.debug_mode
	Config.debug_mode_changed.emit(Config.debug_mode)
