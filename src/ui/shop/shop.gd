extends Control

signal shop_closed
signal shop_opened

@export var close_button : Button

func _ready() -> void:
	shop_opened.emit()
	close_button.pressed.connect(_on_close_pressed)
	show()

func _on_close_pressed() -> void:
	shop_closed.emit()
	queue_free()
