extends Control

signal inventory_closed
signal inventory_opened

@export var close_button: Button

func _ready() -> void:
	inventory_opened.emit()
	close_button.pressed.connect(_on_close_pressed)
	show()


func _on_close_pressed() -> void:
	inventory_closed.emit()
	queue_free()
