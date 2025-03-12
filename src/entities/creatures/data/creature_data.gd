@tool
extends Resource
class_name CreatureData

## The display name of the creature in UI and other places
@export var creature_name: String = "Unnamed Creature"
## The rarity of the creature, this is taken from the Enums.Rarity enum from the enums.gd global script
@export var rarity: Enums.Rarity = Enums.Rarity.Common
## A unique identifier for this creature instance
@export var creature_id: String


func serialize() -> Dictionary:
	return {
		"creature_name": creature_name,
		"rarity": rarity,
		"creature_id": creature_id
	}

func deserialize(data: Dictionary):
	creature_name = data.get("creature_name", "Unnamed Creature")
	rarity = data.get("rarity", Enums.Rarity.Common)
	creature_id = data.get("creature_id", Utils.generate_unique_id())
