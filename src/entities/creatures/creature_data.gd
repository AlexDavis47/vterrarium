@tool
extends Resource
class_name CreatureData

enum HungerBracket {
	Starving,
	Hungry,
	Full
}

enum HappinessBracket {
	Depressed,
	Sad,
	Happy,
	Ecstatic
}

@export_group("Creature Data")
## The display name of the creature in UI and other places
@export var creature_name: String = "Unnamed Creature"
## The description of the creature
@export var description: String = "A creature with no description"
## The image of the creature, this is used to display the creature in the inventory
@export var creature_image: Texture2D = null
## The rarity of the creature, this is taken from the Enums.Rarity enum from the enums.gd global script
@export var rarity: Enums.Rarity = Enums.Rarity.Common
## The base scene of the creature, this is the scene that will be instantiated when the creature is created
@export var creature_scene_uuid: String = ""
## The pool chances for the creature, this is used to determine the chance of the creature being spawned in the creature factory
@export var pool_chances: Array[PoolChance] = []

@export_group("Stats")
## The money per hour that the creature generates
@export var money_per_hour: float = 1.0
## The hunger rate of the creature, this is the rate at which the creature will lose satiation per hour
@export var hunger_rate: float = 1.0:
	set(value):
		hunger_rate = value
	get:
		return hunger_rate
## The satiation of the creature, this is the amount of satiation the creature has
@export var satiation: float = 1.0:
	set(value):
		satiation = clamp(value, 0.0, 1.0)
	get:
		return satiation

@export_group("Instance Data DON'T TOUCH")
## A unique identifier for this creature instance
@export var creature_id: String
## The luck of the creature, this determines the stats of the creature
## 1.0 is the default luck, 2.0 is double luck, 0.5 is half luck
@export var creature_luck: float = 1.0
## Whether the creature scene for this creature data is currently instantiated
@export var is_in_tank: bool = false
var creature_instance: Creature

## The global position of the creature in the tank
@export var creature_position: Vector3 = Vector3.ZERO

func on_generated(luck: float) -> void:
	creature_luck = luck
	money_per_hour *= randfn(creature_luck, creature_luck * 0.50)
	hunger_rate /= randfn(creature_luck, creature_luck * 0.50)
	creature_id = Utils.generate_unique_id()

func to_dict() -> Dictionary:
	return {
		"creature_name": creature_name,
		"description": description,
		"rarity": rarity,
		"creature_scene_uuid": creature_scene_uuid,
		"pool_chances": pool_chances,
		"money_per_hour": money_per_hour,
		"hunger_rate": hunger_rate,
		"satiation": satiation,
		"creature_id": creature_id,
		"creature_luck": creature_luck,
	}


# func serialize() -> Dictionary:
# 	return {
# 		"creature_name": creature_name,
# 		"description": description,
# 		"rarity": rarity,
# 		"creature_scene": creature_scene,
# 		"pool_chances": pool_chances,
# 		"money_per_hour": money_per_hour,
# 		"hunger_rate": hunger_rate,
# 		"satiation": satiation,
# 		"creature_id": creature_id,
# 		"creature_luck": creature_luck,
# 		"creature_position_x": creature_position.x,
# 	}

# func deserialize(data: Dictionary) -> void:
# 	creature_name = data.get("creature_name")
# 	description = data.get("description")
# 	rarity = data.get("rarity")
# 	creature_scene = data.get("creature_scene")
# 	pool_chances = data.get("pool_chances")
# 	money_per_hour = data.get("money_per_hour")
# 	hunger_rate = data.get("hunger_rate")
# 	satiation = data.get("satiation")
# 	creature_id = data.get("creature_id")
# 	creature_luck = data.get("creature_luck")
