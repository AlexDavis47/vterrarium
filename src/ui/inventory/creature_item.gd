## This is a card style item to display a creature in the inventory.
@tool
extends Panel
class_name UICreatureItem

@export var creature_data: CreatureData:
	set(value):
		creature_data = value

@export var creature_name: Label
@export var creature_preview: TextureRect
@export var add_to_tank_button: Button
@export var remove_from_tank_button: Button

signal creature_added_to_tank(creature_data: CreatureData)
signal creature_removed_from_tank(creature_data: CreatureData)


func _ready() -> void:
	if creature_data:
		update_info()
	add_to_tank_button.pressed.connect(_on_add_to_tank_pressed)
	remove_from_tank_button.pressed.connect(_on_remove_from_tank_pressed)


func update_info() -> void:
	creature_name.text = creature_data.creature_name
	creature_preview.texture = creature_data.creature_image
	if creature_data.is_in_tank:
		add_to_tank_button.disabled = true
		remove_from_tank_button.disabled = false
	else:
		add_to_tank_button.disabled = false
		remove_from_tank_button.disabled = true

func _on_add_to_tank_pressed() -> void:
	CreatureFactory.spawn_creature(creature_data)
	creature_added_to_tank.emit(creature_data)


func _on_remove_from_tank_pressed() -> void:
	CreatureFactory.remove_creature(creature_data.creature_instance)
	creature_removed_from_tank.emit(creature_data)
