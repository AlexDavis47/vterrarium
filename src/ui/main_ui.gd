extends Control

var inventory_scene: PackedScene = preload("uid://bda2an2nm10ol")


@export var inventory_button: Button
@export var feed_button: Button
@export var clean_button: Button
@export var shop_button: Button
@export var money_label: Label


func _ready() -> void:
	inventory_button.pressed.connect(open_inventory)


func _physics_process(delta):
	var money_string = "Money: " + str(int(SaveManager.save_file.money))
	money_label.text = money_string


func open_inventory() -> void:
	var inventory_instance = inventory_scene.instantiate()
	inventory_instance.inventory_closed.connect(_on_inventory_closed)
	VTGlobal.top_window.add_child(inventory_instance)
	hide()


func _on_inventory_closed() -> void:
	show()
