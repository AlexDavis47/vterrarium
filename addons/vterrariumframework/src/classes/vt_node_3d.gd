extends Node3D
class_name VTNode3D
@export_group("Screen Parameters")
## If true, this node will be rendered to the primary (top) screen.
@export var primary_screen : bool = true
## If true, this node will be rendered to the secondary (front) screen.
@export var secondary_screen : bool = true
## If true, this node will inherit the screen flags of it's parent,
## otherwise, the above flags will be used
@export var inherit_flags : bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
