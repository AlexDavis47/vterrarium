@tool
extends Resource
class_name AccessoryData

enum AccessoryType {
	Hat
}

@export_group("Basic Information")
## The display name of the accessory in UI and other places
@export var accessory_name: String = "Unnamed Accessory"
## The category of the accessory (e.g., hat, collar, etc.)
## Used to determine the attachment point of the accessory
@export var accessory_category: AccessoryType = AccessoryType.Hat
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

@export_group("Instance Data DON'T TOUCH")
## A unique identifier for this accessory instance
@export var accessory_id: String
## The luck of the accessory, affects its stats
@export var accessory_luck: float = 1.0
## Whether this accessory is currently equipped on a creature
@export var accessory_is_equipped: bool = false

## Accessories don't really need to do anything when generated right now
func on_generated(luck: float) -> void:
	pass
