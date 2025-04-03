@tool
extends ItemDataResource
class_name AccessoryData


@export_group("Basic Information")
## The display name of the accessory in UI and other places
@export var accessory_name: String = "Unnamed Accessory"
## The category of the accessory (e.g., hat, collar, etc.)
## Used to determine the attachment point of the accessory
@export var accessory_category: AccessoryFactory.AccessoryType = AccessoryFactory.AccessoryType.HAT
## The description of the accessory
@export var accessory_description: String = "An accessory with no description"
## The rarity of the accessory, taken from the Enums.Rarity enum
@export var accessory_rarity: Enums.Rarity = Enums.Rarity.Common
## The image of the accessory, used to display in the inventory
@export var accessory_image: Texture2D = null
## The UUID of the accessory's scene
@export var accessory_scene_uuid: String = ""

@export_group("Gameplay Stats")
## The money per hour bonus this accessory provides
@export var accessory_money_bonus: float = 0.0
## The happiness bonus this accessory provides
@export var accessory_happiness_bonus: float = 0.0:
	set(value):
		accessory_happiness_bonus = clamp(value, -1.0, 1.0)
	get:
		return accessory_happiness_bonus
## The temperature bonus this accessory provides
@export var accessory_temperature_bonus: float = 0.0
## The brightness bonus this accessory provides
@export var accessory_brightness_bonus: float = 0.0:
	set(value):
		accessory_brightness_bonus = clamp(value, -1.0, 1.0)
	get:
		return accessory_brightness_bonus

@export_group("Instance Data DON'T TOUCH")
## A unique identifier for this accessory instance
@export var accessory_id: String
## The luck of the accessory, affects its stats
@export var accessory_luck: float = 1.0
## Whether this accessory is currently equipped on a creature
@export var accessory_is_equipped: bool = false
## The ID of the creature that is currently equipped with this accessory
@export var creature_equipped_id: String = ""

func _equip_accessory(creature_id: String) -> void:
	accessory_is_equipped = true
	creature_equipped_id = creature_id

func _unequip_accessory() -> void:
	accessory_is_equipped = false
	creature_equipped_id = ""

func is_equipped() -> bool:
	return accessory_is_equipped

func get_creature_id() -> String:
	return creature_equipped_id

## Called when the accessory is generated, sets the unique ID
func on_generated(luck: float) -> void:
	accessory_id = Utils.generate_unique_id()
