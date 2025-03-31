@tool
## This whole thing stinks and ideally we should have a custom resource type
## that all item resources inherit from. Then we can always assume we have
## the same properties available to us, but that's a relatively large task for right now.

extends MarginContainer
class_name PackItemCardUI

@export var data: Resource

@export var rarity_type_label: Label
@export var name_label: Label
@export var scene_preview: ScenePreviewSubviewportContainer
@export var take_button: TextureButton

enum CardItemType {
	Creature,
	Accessory,
	Food,
	Other
}

var card_item_type: CardItemType = CardItemType.Other

signal item_taken(item_card: PackItemCardUI)

########################################################
# Initialization
########################################################

func _ready():
	if data is CreatureData:
		card_item_type = CardItemType.Creature
	elif data is AccessoryData:
		card_item_type = CardItemType.Accessory
	elif data is FishFoodData:
		card_item_type = CardItemType.Food
	else:
		card_item_type = CardItemType.Other
	update_ui()
	take_button.pressed.connect(_on_take_button_pressed)

########################################################
# UI Updates
########################################################

func update_ui():
	update_rarity_type_label()
	update_name_label()
	update_scene_preview()

func update_rarity_type_label():
	var rarity: String = ""
	var type: String = ""
	if data is CreatureData:
		var creature_data: CreatureData = data as CreatureData
		rarity = Enums.Rarity.keys()[creature_data.creature_rarity].capitalize()
		type = CreatureFactory.CreatureType.keys()[creature_data.creature_type].capitalize()
	elif data is AccessoryData:
		var accessory_data: AccessoryData = data as AccessoryData
		rarity = Enums.Rarity.keys()[accessory_data.accessory_rarity].capitalize()
		type = "Accessory"
	elif data is FishFoodData:
		var fish_food_data: FishFoodData = data as FishFoodData
		rarity = Enums.Rarity.keys()[fish_food_data.food_rarity].capitalize()
		type = "Food"
	else:
		rarity = "Unknown"
		type = "Unknown"

	rarity_type_label.text = "%s %s" % [rarity, type]


func update_name_label():
	var name: String = ""
	if data is CreatureData:
		var creature_data: CreatureData = data as CreatureData
		name = creature_data.creature_name
	elif data is AccessoryData:
		var accessory_data: AccessoryData = data as AccessoryData
		name = accessory_data.accessory_name
	elif data is FishFoodData:
		var fish_food_data: FishFoodData = data as FishFoodData
		name = fish_food_data.food_name
	else:
		name = "Unknown"

	name_label.text = name

func update_scene_preview():
	var scene_uuid: String = ""
	var creature_preview: Creature = null
	if data is CreatureData:
		var creature_data: CreatureData = data as CreatureData
		scene_uuid = creature_data.creature_scene_uuid
		creature_preview = CreatureFactory.create_creature_preview(creature_data)
	elif data is AccessoryData:
		var accessory_data: AccessoryData = data as AccessoryData
		scene_uuid = accessory_data.accessory_scene_uuid
	elif data is FishFoodData:
		var fish_food_data: FishFoodData = data as FishFoodData
		scene_uuid = fish_food_data.food_scene_path

	if card_item_type == CardItemType.Creature:
		scene_preview.add_child_to_root_node(creature_preview)
	elif card_item_type == CardItemType.Accessory:
		scene_preview.add_child_to_root_node(load(scene_uuid).instantiate())
	elif card_item_type == CardItemType.Food:
		scene_preview.add_child_to_root_node(load(scene_uuid).instantiate())


func take_item():
	if data is CreatureData:
		var creature_data: CreatureData = data as CreatureData
		SaveManager.save_file.creature_inventory.append(creature_data)
	elif data is AccessoryData:
		var accessory_data: AccessoryData = data as AccessoryData
		SaveManager.save_file.accessory_inventory.append(accessory_data)
	elif data is FishFoodData:
		var fish_food_data: FishFoodData = data as FishFoodData
		SaveManager.save_file.fish_food_inventory.append(fish_food_data)
	else:
		printerr("Invalid item type")
	item_taken.emit(self)

	pivot_offset = size / 2
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.35)
	tween.parallel().tween_property(self, "scale", Vector2(0.0, 0.0), 0.35)
	tween.parallel().tween_property(self, "rotation_degrees", 180.0, 0.35)
	tween.tween_callback(queue_free)
########################################################
# Signal Handlers
########################################################

func _on_take_button_pressed():
	take_item()
