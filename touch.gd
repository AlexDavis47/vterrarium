extends Node2D
@onready var circle_container = $circle_container
var circles = []

func _ready() -> void:
	for circle in circle_container.get_children():
		circles.append(circle)

func _input(event):
	if event is InputEventScreenDrag:
		var i = event.index
		if i >= 0 and i < circles.size():
			circles[i].show()
			circles[i].global_position = event.position
	elif event is InputEventScreenTouch and not event.pressed:
		var i = event.index  # Fix: Use `index` instead of `get_index`
		if i >= 0 and i < circles.size():
			circles[i].hide()
			
