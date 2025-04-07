extends PanelContainer

@export var button: Button

func _ready() -> void:
	button.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	AccessoryFactory.create_test_accessories()
