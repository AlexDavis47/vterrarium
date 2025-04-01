@tool
extends Resource
class_name StoreItemData

@export var item_name: String = "Item Name":
	get:
		return item_name
	set(value):
		item_name = value
		emit_changed()

@export var item_description: String = "Item Description":
	get:
		return item_description
	set(value):
		item_description = value
		emit_changed()

@export var item_price: int = 100:
	get:
		return item_price
	set(value):
		item_price = value
		emit_changed()

@export var item_icon: Texture2D:
	get:
		return item_icon
	set(value):
		item_icon = value
		emit_changed()

@export var item_color: Color = Color(1, 1, 1, 0):
	get:
		return item_color
	set(value):
		item_color = value
		emit_changed()
