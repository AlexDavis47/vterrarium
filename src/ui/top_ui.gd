extends Control
class_name TopUI

signal menu_opened(menu_name: String)
signal menu_closed()

var inventory_scene: PackedScene = preload("uid://bda2an2nm10ol")
var feeding_scene: PackedScene = preload("uid://bda2an2nm10ol")
var store_scene: PackedScene = preload("uid://bda2an2nm10ol")

@export var menu_buttons: MenuButtons

var current_menu: Control = null

func _init() -> void:
	VTGlobal.top_ui = self


func open_inventory_menu():
	_open_menu(inventory_scene, "inventory")

func open_feeding_menu():
	_open_menu(feeding_scene, "feeding")

func open_store_menu():
	_open_menu(store_scene, "store")

func close_all_menus():
	if current_menu != null:
		current_menu.queue_free()
	current_menu = null
	menu_closed.emit()

func _open_menu(menu: PackedScene, menu_name: String):
	if current_menu != null:
		current_menu.queue_free()
	current_menu = menu.instantiate()
	add_child(current_menu)
	menu_opened.emit(menu_name)
