## Represents a save file for the game
extends Resource
class_name SaveFile

########################################################
# Signals
########################################################

signal money_changed(new_money: float)
signal creature_inventory_changed(new_creature_inventory: Array[CreatureData])
signal accessory_inventory_changed(new_accessory_inventory: Array[AccessoryData])
signal food_inventory_changed(new_food_inventory: Array[FishFoodData])
signal upgrade_inventory_changed(new_upgrade_inventory: Array[UpgradeData])
signal save_version_changed(new_save_version: int)
signal user_name_changed(new_user_name: String)
signal created_at_changed(new_created_at: Dictionary)
signal last_saved_at_changed(new_last_saved_at: Dictionary)
signal save_id_changed(new_save_id: String)

########################################################
# Properties
########################################################

## The version of the save file
@export var save_version: int = 1:
	set(value):
		save_version = value
		save_version_changed.emit(value)

## The name of the user
@export var user_name: String = "Unnamed User":
	set(value):
		user_name = value
		user_name_changed.emit(value)

## The date and time the save file was created
@export var created_at: Dictionary = {}:
	set(value):
		created_at = value
		created_at_changed.emit(value)

## The date and time the save file was last saved
@export var last_saved_at: Dictionary = {}:
	set(value):
		last_saved_at = value
		last_saved_at_changed.emit(value)

## A unique identifier for the save file
@export var save_id: String = "":
	set(value):
		save_id = value
		save_id_changed.emit(value)

## The money the player has
@export var money: float = 0:
	set(value):
		money = value
		money_changed.emit(value)

## The max capacity of the tank
@export var tank_capacity: IntWithModifiers = IntWithModifiers.create(5):
	set(value):
		tank_capacity = value

## The inventory of creatures the player has
@export var creature_inventory: Array[CreatureData] = []:
	set(value):
		creature_inventory = value
		creature_inventory_changed.emit(value)

## The inventory of accessories the player has
@export var accessory_inventory: Array[AccessoryData] = []:
	set(value):
		accessory_inventory = value
		accessory_inventory_changed.emit(value)

## The inventory of foods the player has
@export var food_inventory: Array[FishFoodData] = []:
	set(value):
		food_inventory = value
		food_inventory_changed.emit(value)

## The inventory of upgrades the player has
@export var upgrade_inventory: Array[UpgradeData] = []:
	set(value):
		upgrade_inventory = value
		upgrade_inventory_changed.emit(value)


########################################################
# Save File Lifecycle
########################################################

## Called after the save file is loaded
func on_load() -> void:
	clear_upgrade_effects()
	apply_upgrade_effects()

## Called before the save file is saved
func on_save() -> void:
	# Update timestamps or perform other pre-save operations
	last_saved_at = Time.get_datetime_dict_from_system()


########################################################
# Upgrade System
########################################################

## Removes the effects of all upgrades from the player
func clear_upgrade_effects() -> void:
	tank_capacity.remove_all_modifiers()
	for upgrade in upgrade_inventory:
		upgrade.remove_upgrade()

## Applies the effects of all upgrades to the player
func apply_upgrade_effects() -> void:
	for upgrade in upgrade_inventory:
		upgrade.apply_upgrade()
