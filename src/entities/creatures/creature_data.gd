## This resource stores all common data for creatures in the game that need to be cared for and return money to the player.
## Properties shared between all creatures are defined here, making it easy to save and load creature data.
## Specialized properties can be added through components or extension.
## ADDITIONALLY, this resource type can be extended to create a more specific creature data resource for each creature type.
## Such as a goldfish data resource, a crab data resource, etc.
## However, unless needed, it is best to keep all data here to avoid bloat.
extends Resource
class_name CreatureData


## The display name of the creature in UI and other places
@export var creature_name: String = "Creature"
## The rarity of the creature, this is taken from the Enums.Rarity enum from the enums.gd global script
@export var creature_rarity: Enums.Rarity = Enums.Rarity.Common
## The age of the creature in seconds since the creature was born
@export var creature_age: float = 0
## The base money rate of the creature per second
@export var creature_money_rate: int = 1
## The base speed of the creature in units per second
@export var creature_speed: int = 1
