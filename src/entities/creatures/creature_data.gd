## This resource stores all common data for creatures in the game that need to be cared for and return money to the player.
## All creature properties are managed through component data resources for consistency.
## This makes it easy to save and load creature data and extend functionality through components.
## ADDITIONALLY, this resource type can be extended to create a more specific creature data resource for each creature type.
## Such as a goldfish data resource, a crab data resource, etc.
## However, unless needed, it is best to keep all data here to avoid bloat.
@tool
extends Resource
class_name CreatureData

## Basic creature identification
@export var creature_name: String = "Creature"
@export var creature_rarity_data: CreatureRarityData

## Component data resources
@export var money_rate_data: CreatureMoneyRateData
@export var speed_data: CreatureSpeedData
@export var happiness_data: CreatureHappinessData
@export var age_data: CreatureAgeData
@export var hunger_data: CreatureHungerData
# Add other component data as needed