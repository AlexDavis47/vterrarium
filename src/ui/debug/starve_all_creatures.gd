extends PanelContainer

@export var button: Button

func _ready() -> void:
	button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	for creature in SaveManager.save_file.creature_inventory:
		creature.creature_satiation = 0.0
