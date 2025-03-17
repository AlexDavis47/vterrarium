extends Node3D

signal feed_closed
signal feed_opened

@export var close_button : Button

func _ready() -> void:
	feed_opened.emit()
	close_button.pressed.connect(_on_close_pressed)
	show()

func _on_close_pressed() -> void:
	feed_closed.emit()
	queue_free()
