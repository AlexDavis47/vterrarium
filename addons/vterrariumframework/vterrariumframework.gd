@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_autoload_singleton("VTGlobal", "res://addons/vterrariumframework/src/globals/vtglobal.gd")
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
