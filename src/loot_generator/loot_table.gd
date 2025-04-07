## Loot tables contain a list of item data resources that can be pulled from, along with a weight for each item.
## The loot generator will use the weights and entries to pick a random item from the table.
@tool
extends Resource
class_name LootTableData

@export var entries: Array[LootTableDataEntry] = []

## If true, the loot table will not be randomized, and will always return all items in the order defined in the entries array.
@export var static_pack: bool = false:
	get:
		return static_pack
	set(value):
		static_pack = value
		emit_changed()

func get_total_weight() -> float:
	var total_weight: float = 0.0
	for entry in entries:
		total_weight += entry.weight
	return total_weight

func get_random_item(luck: float = 1.0) -> ItemDataResource:
	var total_weight: float = get_total_weight()
	var random_value: float = randf() * total_weight
	var cumulative_weight: float = 0.0

	for entry in entries:
		cumulative_weight += entry.weight
		if random_value <= cumulative_weight:
			var item: ItemDataResource = entry.item.duplicate(true)
			item.on_generated(luck)
			return item

	return null

func get_static_pack() -> Array[ItemDataResource]:
	var items: Array[ItemDataResource] = []
	for entry in entries:
		items.append(entry.item.duplicate(true))
		entry.item.on_generated(1.0)
	return items
