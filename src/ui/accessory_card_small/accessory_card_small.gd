extends Control
class_name AccessoryCardSmall

# The creature data is used to determine the creature we're equipping the accessory to
@export var creature_data: CreatureData

# The accessory data is used to determine the accessory we're equipping
@export var accessory_data: AccessoryData

@export var rarity_type_label: Label
@export var accessory_name_label: Label
@export var accessory_image: TextureRect

@export var equip_button: TextureButton

@export var scene_preview: ScenePreviewSubviewportContainer

signal accessory_equipped(accessory_data: AccessoryData, creature_data: CreatureData)
signal accessory_unequipped(accessory_data: AccessoryData, creature_data: CreatureData)
signal request_update()

func _ready():
	equip_button.pivot_offset = equip_button.size / 2


func update_ui() -> void:
	equip_button.pressed.connect(self._on_equip_button_pressed)
	_update_rarity_type_label()
	_update_accessory_name_label()
	_update_accessory_image()
	_update_equip_button()
	_update_scene_preview()

func _update_rarity_type_label() -> void:
	var rarity = Enums.Rarity.keys()[accessory_data.accessory_rarity]
	var type = AccessoryFactory.AccessoryType.keys()[accessory_data.accessory_category]
	rarity_type_label.text = "%s %s" % [rarity, type]

func _update_accessory_name_label() -> void:
	accessory_name_label.text = accessory_data.accessory_name


func _update_accessory_image() -> void:
	accessory_image.texture = accessory_data.accessory_image


func _update_equip_button() -> void:
	if accessory_data.accessory_is_equipped:
		equip_button.set_pressed_no_signal(true)
	else:
		equip_button.set_pressed_no_signal(false)


func _update_scene_preview() -> void:
	scene_preview.clear_root_node()
	var accessory_scene = load(accessory_data.accessory_scene_uuid)
	var accessory_instance = accessory_scene.instantiate()
	scene_preview.add_child_to_root_node(accessory_instance)

func _on_equip_button_pressed() -> void:
	# If not currently equipped, equip the accessory
	if not accessory_data.accessory_is_equipped:
		AccessoryFactory.equip_accessory(accessory_data, creature_data)
		accessory_equipped.emit(accessory_data, creature_data)
		request_update.emit()
	# If currently equipped, unequip the accessory
	else:
		AccessoryFactory.unequip_accessory(accessory_data, creature_data)
		accessory_unequipped.emit(accessory_data, creature_data)
		request_update.emit()

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(equip_button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(equip_button, "scale", Vector2(1, 1), 0.1)
