@tool
extends Resource
class_name CreatureRarityData

## The rarity of the creature from the Enums.Rarity enum
@export var rarity: Enums.Rarity = Enums.Rarity.Common

## Returns rarity-based multipliers for various stats
func get_rarity_multiplier() -> float:
    match rarity:
        Enums.Rarity.Common:
            return 1.0
        Enums.Rarity.Uncommon:
            return 1.5
        Enums.Rarity.Rare:
            return 2.0
        Enums.Rarity.Epic:
            return 3.0
        Enums.Rarity.Legendary:
            return 5.0
        _:
            return 1.0
