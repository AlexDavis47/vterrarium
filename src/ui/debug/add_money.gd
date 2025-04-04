extends PanelContainer

@export var button: Button

func _ready() -> void:
	button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	SaveManager.save_file.money += 1000
