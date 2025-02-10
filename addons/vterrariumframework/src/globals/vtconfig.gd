extends Node

var primary_window: Window
var secondary_window: Window


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	primary_window = get_viewport().get_window()
	secondary_window = get_viewport().get_window()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
