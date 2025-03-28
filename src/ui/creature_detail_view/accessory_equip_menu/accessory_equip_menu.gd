extends Control

@export var creature_data: CreatureData

@export var close_button: TextureButton

@export var _hats_container: AccessoriesContainer

signal accessory_equipped(accessory_data: AccessoryData, creature_data: CreatureData)
signal accessory_unequipped(accessory_data: AccessoryData, creature_data: CreatureData)


func _ready() -> void:
	update_ui()
	close_button.pressed.connect(_on_close_button_pressed)

func update_ui() -> void:
	_hats_container.creature_data = creature_data
	_hats_container.accessory_equipped.connect(_on_accessory_equipped)
	_hats_container.accessory_unequipped.connect(_on_accessory_unequipped)
	_hats_container.update_ui()

func _on_accessory_equipped(accessory_data: AccessoryData, creature_data: CreatureData) -> void:
	accessory_equipped.emit(accessory_data, creature_data)

func _on_accessory_unequipped(accessory_data: AccessoryData, creature_data: CreatureData) -> void:
	accessory_unequipped.emit(accessory_data, creature_data)

func _on_close_button_pressed() -> void:
	queue_free()
