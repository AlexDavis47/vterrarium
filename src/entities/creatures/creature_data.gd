@tool
extends Resource
class_name CreatureData

## The creature type, for instantiating the creature in the creature factory
@export var creature_type: CreatureFactory.CreatureTemplate
## The display name of the creature in UI and other places
@export var creature_name: String = "Unnamed Creature"
## The rarity of the creature, this is taken from the Enums.Rarity enum from the enums.gd global script
@export var rarity: Enums.Rarity = Enums.Rarity.Common
## The base scene of the creature, this is the scene that will be instantiated when the creature is created
@export var creature_scene: PackedScene
## A unique identifier for this creature instance
var creature_id: String
## The luck of the creature, this determines the stats of the creature
## 1.0 is the default luck, 2.0 is double luck, 0.5 is half luck
var luck: float = 1.0
## The rate at which the creature produces money hourly
@export var base_money_rate: float = 1.0
var money_rate: FloatWithModifiers = FloatWithModifiers.new()
## The pool chances for the creature, this is used to determine the chance of the creature being spawned in the creature factory
@export var pool_chances: Array[PoolChance] = []


func _init() -> void:
	resource_local_to_scene = true
	money_rate.base_value = base_money_rate
	money_rate.resource_local_to_scene = true

func serialize() -> Dictionary:
	return {
		"creature_name": creature_name,
		"rarity": rarity,
		"creature_id": creature_id,
		"creature_type": creature_type,
		"luck": luck,
		"money_rate": money_rate.base_value,
		"creature_scene": creature_scene
	}

func deserialize(data: Dictionary):
	creature_name = data.get("creature_name", "Unnamed Creature")
	rarity = data.get("rarity", Enums.Rarity.Common)
	creature_id = data.get("creature_id", Utils.generate_unique_id())
	creature_type = data.get("creature_type", "")
	luck = data.get("luck", 1.0)
	money_rate.base_value = data.get("money_rate", 1.0)
	creature_scene = data.get("creature_scene", null)
