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

@export var loot_table: LootTableData = null:
	get:
		return loot_table
	set(value):
		loot_table = value
		emit_changed()

@export var number_of_items: int = 3:
	get:
		return number_of_items
	set(value):
		number_of_items = value
		emit_changed()

## Implementation stub
func _get_pack_item_cards() -> Array[PackItemCardUI]:
	print("Pack item cards not implemented")
	return []
