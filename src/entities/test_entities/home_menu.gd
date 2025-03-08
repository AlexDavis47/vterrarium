extends Control

@export var menu_scene: PackedScene = preload("res://src/entities/test_entities/open_menu.tscn")

func _on_menu_pressed() -> void:
	var menu_instance = menu_scene.instantiate()
	add_child(menu_instance)
	menu_instance.show()
