extends PanelContainer

@export var button: Button

func _ready() -> void:
	button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	CreatureFactory._create_test_creatures()
