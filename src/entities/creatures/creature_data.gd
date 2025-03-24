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

@export_group("Basic Information")
## The display name of the creature in UI and other places
@export var creature_name: String = "Unnamed Creature"
## The species of the creature. Used in UI.
@export var creature_species: String = "Unnamed Species"
## The creature_description of the creature
@export var creature_description: String = "A creature with no creature_description"
## The type of creature, this is used to determine which creature to spawn in the creature factory
@export var creature_type: CreatureFactory.CreatureType = CreatureFactory.CreatureType.FISH
## The creature_rarity of the creature, this is taken from the Enums.Rarity enum from the enums.gd global script
@export var creature_rarity: Enums.Rarity = Enums.Rarity.Common
## The image of the creature, this is used to display the creature in the inventory
@export var creature_image: Texture2D = null
## The UUID of the mesh of the creature
@export var creature_mesh_uuid: String = ""

@export_group("Appearance")
## The tinting of the creature, a color value. Will be used to tint the creature's albedo texture.
@export var creature_tint: Color = Color.WHITE
## The amount of tinting to apply to the creature, this is a value between 0 and 1
@export var creature_tint_amount: float = 1.0
## The creature's size, affects the size of the creature
@export var creature_size: float = 1.0

@export_group("Gameplay Stats")
## The money per hour that the creature generates
@export var creature_money_per_hour: float = 1.0
## The hunger rate of the creature, this is the rate at which the creature will lose creature_satiation per hour
@export var creature_hunger_rate: float = 1.0:
	set(value):
		creature_hunger_rate = value
	get:
		return creature_hunger_rate
## The creature_satiation of the creature, this is the amount of creature_satiation the creature has
@export var creature_satiation: float = 1.0:
	set(value):
		creature_satiation = clamp(value, 0.0, 1.0)
	get:
		return creature_satiation
## The creature's speed, affects the speed that the creature moves around the tank
@export var creature_speed: float = 1.0

@export_group("Preferences")
## The light level preference of the creature, this is an editor curve.
## 0 on the x axis is dark, 1 on the x axis is light
## 0 on the y axis is dislike, 1 on the y axis is like
@export var creature_light_preference: Curve = Curve.new()
## The temperature preference of the creature, this is an editor curve.
## 0 on the x axis is cold, 1 on the x axis is hot
## 0 on the y axis is dislike, 1 on the y axis is like
@export var creature_temperature_preference: Curve = Curve.new()
## The pool chances for the creature, this is used to determine the chance of the creature being spawned in the creature factory
@export var creature_pool_chances: Array[PoolChance] = []

@export_group("Instance Data DON'T TOUCH")
## A unique identifier for this creature instance
@export var creature_id: String
## The luck of the creature, this determines the stats of the creature
## 1.0 is the default luck, 2.0 is double luck, 0.5 is half luck
@export var creature_luck: float = 1.0
## Whether the creature scene for this creature data is currently instantiated
@export var creature_is_in_tank: bool = false
## The global position of the creature in the tank
@export var creature_position: Vector3 = Vector3.ZERO

## The current contentment with the light level, this is a value between 0 and 1
@export var creature_light_contentment: float = 1.0:
	set(value):
		creature_light_contentment = clamp(value, 0.0, 1.0)
	get:
		return creature_light_contentment
## The current contentment with the temperature, this is a value between 0 and 1
@export var creature_temperature_contentment: float = 1.0:
	set(value):
		creature_temperature_contentment = clamp(value, 0.0, 1.0)
	get:
		return creature_temperature_contentment
## The creature_happiness of the creature, affects the money rate
@export var creature_happiness: float = 1.0:
	set(value):
		creature_happiness = clamp(value, 0.0, 1.0)
	get:
		return creature_happiness

# TEMPORARY VARIABLES
## Reference to the currently instantiated creature object spawned from this data
var creature_instance: Creature

func on_generated(luck: float) -> void:
	creature_luck = luck
	creature_money_per_hour *= randfn(creature_luck, creature_luck * 0.25)
	print("creature_money_per_hour: ", creature_money_per_hour)
	creature_hunger_rate /= randfn(creature_luck, creature_luck * 0.25)
	print("creature_hunger_rate: ", creature_hunger_rate)
	creature_speed *= randfn(1, 0.25)
	creature_speed = clamp(creature_speed, 0.25, 2.0)
	print("creature_speed: ", creature_speed)
	creature_size *= randfn(1, 0.25)
	creature_size = clamp(creature_size, 0.25, 2.0)
	print("creature_size: ", creature_size)
	creature_id = Utils.generate_unique_id()
	creature_tint = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	creature_tint_amount = randfn(creature_luck - 1.0, creature_luck * 0.25)