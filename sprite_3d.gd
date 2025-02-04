extends Node3D

func _process(delta: float) -> void:
	global_position.x += Input.get_last_mouse_velocity().x * delta * 0.01
	global_position.z += Input.get_last_mouse_velocity().y * delta * 0.01
