## This resource contains data to determine the properties of a food item.
## It will be used both in UI, as well as in the fish food entities spawned from the item.
extends Resource
class_name FishFoodData

signal food_name_changed(value: String)
signal food_description_changed(value: String)
signal food_texture_changed(value: Texture2D)
signal times_eatable_changed(value: int)
signal food_value_changed(value: float)
signal food_lifetime_changed(value: float)
signal food_color_changed(value: Color)

@export var food_name: String = "Fish Food":
	set(value):
		food_name = value
		food_name_changed.emit(value)
	get:
		return food_name

@export var food_description: String = "A food item that can be eaten by creatures.":
	set(value):
		food_description = value
		food_description_changed.emit(value)
	get:
		return food_description

@export var food_texture: Texture2D:
	set(value):
		food_texture = value
		food_texture_changed.emit(value)
	get:
		return food_texture

@export var food_color: Color = Color(1.0, 1.0, 1.0):
	set(value):
		food_color = value
		food_color_changed.emit(value)
	get:
		return food_color

@export var times_eatable: int = 1:
	set(value):
		times_eatable = value
		times_eatable_changed.emit(value)
	get:
		return times_eatable

@export var food_value: float = 0.1:
	set(value):
		food_value = value
		food_value_changed.emit(value)
	get:
		return food_value

@export var food_lifetime: float = 10.0:
	set(value):
		food_lifetime = value
		food_lifetime_changed.emit(value)
	get:
		return food_lifetime
