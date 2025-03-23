extends Control
class_name InventoryUI

@export var close_button: Button

func _ready() -> void:
	close_button.pressed.connect(VTGlobal.top_ui.close_all_menus)
