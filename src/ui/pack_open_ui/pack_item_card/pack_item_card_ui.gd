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
var _preview_instance: Node = null

signal item_taken(item_card: PackItemCardUI)

########################################################
# Initialization
########################################################

func _ready():
	# Connect signals or do other setup needed only when in the tree
	take_button.pressed.connect(_on_take_button_pressed)

func prepare_card_visuals():
	# This should be called *after* data is set, but *before* adding to tree
	if data == null:
		printerr("Cannot prepare card visuals: data is null.")
		return
		
	if data is CreatureData:
		card_item_type = CardItemType.Creature
	elif data is AccessoryData:
		card_item_type = CardItemType.Accessory
	elif data is FishFoodData:
		card_item_type = CardItemType.Food
	else:
		card_item_type = CardItemType.Other

	_instantiate_preview() # Instantiate before updating UI that adds it
	update_ui()

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
	if _preview_instance != null:
		scene_preview.add_child_to_root_node(_preview_instance)
	else:
		printerr("Preview instance was null when trying to add it to the scene.")

func _instantiate_preview():
	var scene_to_load: String = ""

	if data is CreatureData:
		var creature_data: CreatureData = data as CreatureData
		_preview_instance = CreatureFactory.create_creature_preview(creature_data)
	elif data is AccessoryData:
		var accessory_data: AccessoryData = data as AccessoryData
		scene_to_load = accessory_data.accessory_scene_uuid
	elif data is FishFoodData:
		var fish_food_data: FishFoodData = data as FishFoodData
		scene_to_load = fish_food_data.food_scene_path
	else:
		printerr("Unknown data type for preview instantiation")
		return # Cannot instantiate anything

	# Handle instantiation for non-creature types
	if card_item_type == CardItemType.Accessory or card_item_type == CardItemType.Food:
		if scene_to_load.is_empty():
			printerr("Scene path/UUID is empty for Accessory/Food item.")
			return
		var loaded_scene: PackedScene = load(scene_to_load)
		if loaded_scene != null:
			_preview_instance = loaded_scene.instantiate()
		else:
			printerr("Failed to load scene: ", scene_to_load)


func take_item():
	if data is CreatureData:
		var creature_data: CreatureData = data as CreatureData
		CreatureFactory.add_creature_to_inventory(creature_data)
	elif data is AccessoryData:
		var accessory_data: AccessoryData = data as AccessoryData
		AccessoryFactory.add_accessory_to_inventory(accessory_data)
	elif data is FishFoodData:
		var fish_food_data: FishFoodData = data as FishFoodData
		FoodFactory.add_food_to_inventory(fish_food_data)
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
	AudioManager.play_sfx(AudioManager.SFX.POP_1, 0.8, 1.2)
	take_item()
