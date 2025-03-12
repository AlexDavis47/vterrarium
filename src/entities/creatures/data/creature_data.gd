@tool
extends Resource
class_name CreatureData

## The display name of the creature in UI and other places
@export var creature_name: String = "Unnamed Creature"
## The rarity of the creature, this is taken from the Enums.Rarity enum from the enums.gd global script
@export var rarity: Enums.Rarity = Enums.Rarity.Common
## A unique identifier for this creature instance
@export var creature_id: String
## The luck of the creature, this determines the stats of the creature
## 1.0 is the default luck, 2.0 is double luck, 0.5 is half luck
@export var luck: float = 1.0
## The rate at which the creature produces money hourly
@export var money_rate: FloatWithModifiers = FloatWithModifiers.new()

func _init() -> void:
	resource_local_to_scene = true
	money_rate.base_value = 1.0

func serialize() -> Dictionary:
	return {
		"creature_name": creature_name,
		"rarity": rarity,
		"creature_id": creature_id,
		"luck": luck,
		"money_rate": money_rate.base_value
	}

func deserialize(data: Dictionary):
	creature_name = data.get("creature_name", "Unnamed Creature")
	rarity = data.get("rarity", Enums.Rarity.Common)
	creature_id = data.get("creature_id", Utils.generate_unique_id())
	luck = data.get("luck", 1.0)
	money_rate.base_value = data.get("money_rate", 1.0)
