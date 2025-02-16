@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_autoload_singleton("VTGlobal", "res://addons/vterrariumframework/src/globals/vtglobal.gd")
	add_autoload_singleton("VTConfig", "res://addons/vterrariumframework/src/globals/vtconfig.gd")
	add_autoload_singleton("VTUserConfig", "res://addons/vterrariumframework/src/globals/vt_user_config.gd")
	add_autoload_singleton("VTHardware", "res://addons/vterrariumframework/src/globals/vt_hardware.gd")


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
