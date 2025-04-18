## This resource contains data to determine the properties of a food item.
## It will be used both in UI, as well as in the fish food entities spawned from the item.
@tool
extends ItemDataResource
class_name FishFoodData

signal food_name_changed(value: String)
signal food_description_changed(value: String)
signal food_texture_changed(value: Texture2D)
signal times_eatable_changed(value: int)
signal food_value_changed(value: float)
signal food_lifetime_changed(value: float)
signal food_color_changed(value: Color)
signal food_rarity_changed(value: Enums.Rarity)
signal is_infinite_use_changed(value: bool)
signal number_owned_changed(value: int)

## Only one type of food is currently supported.
enum FoodType {
	COMMON,
	UNCOMMON,
	RARE
}


@export_group("Food Properties")
## The display name of this food type
@export var food_name: String = "Fish Food":
	set(value):
		food_name = value
		food_name_changed.emit(value)
		emit_changed()
	get:
		return food_name

## Description of the food item
@export var food_description: String = "A food item that can be eaten by creatures.":
	set(value):
		food_description = value
		food_description_changed.emit(value)
		emit_changed()
	get:
		return food_description

## The type of food, affects physical properties and fish preferences
@export var food_type: FoodType = FoodType.COMMON:
	set(value):
		food_type = value
		emit_changed()
	get:
		return food_type

## The texture used for UI representation
@export var food_texture: Texture2D:
	set(value):
		food_texture = value
		food_texture_changed.emit(value)
		emit_changed()
	get:
		return food_texture

## The color of the food particles
@export var food_color: Color = Color(1.0, 1.0, 1.0):
	set(value):
		food_color = value
		food_color_changed.emit(value)
		emit_changed()
	get:
		return food_color

## How many times the food can be eaten before it disappears
@export var times_eatable: int = 1:
	set(value):
		times_eatable = value
		times_eatable_changed.emit(value)
		emit_changed()
	get:
		return times_eatable

## The nutrition value added to a creature's satiation when eaten
@export var food_value: float = 0.1:
	set(value):
		food_value = value
		food_value_changed.emit(value)
		emit_changed()
	get:
		return food_value

## How long the food remains in the tank before disappearing (seconds)
@export var food_lifetime: float = 25.0:
	set(value):
		food_lifetime = value
		food_lifetime_changed.emit(value)
		emit_changed()
	get:
		return food_lifetime

## The rarity of the food
@export var food_rarity: Enums.Rarity = Enums.Rarity.Common:
	set(value):
		food_rarity = value
		food_rarity_changed.emit(value)
		emit_changed()
	get:
		return food_rarity

## The number of individual food instances spawned when used
@export var spawn_quantity: int = 1:
	set(value):
		spawn_quantity = max(1, value) # Ensure at least 1 is spawned
		# No signal needed currently, as it's used at spawn time
		emit_changed()
	get:
		return spawn_quantity

## Whether this food is consumed from inventory when used
@export var is_infinite_use: bool = false:
	set(value):
		is_infinite_use = value
		is_infinite_use_changed.emit(value)
	get:
		return is_infinite_use

## How many of this food the player owns
@export var number_owned: int = 0:
	set(value):
		number_owned = max(0, value)
		number_owned_changed.emit(value)
	get:
		return number_owned


@export_group("Physical Properties")
## How quickly the food sinks in water (higher values sink faster)
@export var sink_speed: float = 1.0:
	set(value):
		sink_speed = value
		emit_changed()
	get:
		return sink_speed

## How much the food spreads out when dropped (higher values spread more)
@export var spread_factor: float = 1.0:
	set(value):
		spread_factor = value
		emit_changed()
	get:
		return spread_factor

## The mass of each food particle
@export var food_mass: float = 0.1:
	set(value):
		food_mass = value
		emit_changed()
	get:
		return food_mass

@export_group("System Properties")
## The scene to instantiate for this food type
@export var food_scene_path: String = "uid://df5rypo11dohl":
	set(value):
		food_scene_path = value
		emit_changed()
	get:
		return food_scene_path

## Unique ID for this food
@export var food_id: String = "":
	set(value):
		food_id = value
		emit_changed()
	get:
		return food_id

## Called when this food is first created
func on_generated(luck: float = 1) -> void:
	if food_id.is_empty():
		food_id = Utils.generate_unique_id()

## Get the actual scene for this food type
func get_food_scene() -> PackedScene:
	return load(food_scene_path) as PackedScene
