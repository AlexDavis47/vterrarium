extends Node3D
class_name VTGameWorld

@export var keyboard : OnscreenKeyboard

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	VTGlobal.game_world = self
	VTGlobal.onscreen_keyboard = keyboard
