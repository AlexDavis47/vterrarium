## Represents a save file for the game
extends Resource
class_name SaveFile

## The version of the save file
@export var save_version: int = 1

## The name of the user
@export var user_name: String = "Unnamed User"

## The date and time the save file was created
@export var created_at: Dictionary = {}

## The date and time the save file was last saved
@export var last_saved_at: Dictionary = {}

## A unique identifier for the save file
@export var save_id: String = ""

## The money the player has
@export var money: float = 0

## The inventory of creatures the player has
@export var creature_inventory: Array[CreatureData] = []

## The inventory of accessories the player has
@export var accessory_inventory: Array[AccessoryData] = []

## The inventory of foods the player has
@export var food_inventory: Array[FishFoodData] = []