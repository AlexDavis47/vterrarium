@tool
extends Node

var all_menus_closed: bool = true


var _money_per_hour: float = 0.0
var _last_money: float = 0.0

var _process_scheduler: ProcessScheduler = ProcessScheduler.new()


enum CreatureSortType {
	NAME,
	AGE,
	HAPPINESS,
	VALUE,
	SPECIES,
	RARITY,
	HUNGER
}

enum SortDirection {
	ASCENDING,
	DESCENDING
}


func _ready():
	if not Engine.is_editor_hint():
		_process_scheduler.tick_second.connect(_on_money_per_hour_tick)
		add_child(_process_scheduler)


func _on_money_per_hour_tick(delta: float):
	if Engine.is_editor_hint():
		return
	var current_money: float = SaveManager.save_file.money
	var money_delta: float = current_money - _last_money
	_last_money = current_money
	_money_per_hour = money_delta * 3600.0

## Generate a unique ID
func generate_unique_id() -> String:
	return str(randi()) + str(int(Time.get_unix_time_from_system()))

## Take a large number and convert it to a readable string with suffix
## EG: 154345 returns "154.3k", 1543450000 returns "1.5B"
func convert_long_int_to_string(number: int) -> String:
	var suffix: String = ""
	var value: float = float(number)
	
	if value >= 1000000000000000:
		suffix = "Q"
		value /= 1000000000000000
	elif value >= 1000000000000:
		suffix = "T"
		value /= 1000000000000
	elif value >= 1000000000:
		suffix = "B"
		value /= 1000000000
	elif value >= 1000000:
		suffix = "M"
		value /= 1000000
	elif value >= 1000:
		suffix = "k"
		value /= 1000
	
	# Format with one decimal place for large numbers
	if suffix != "":
		return "%.1f%s" % [value, suffix]
	else:
		return str(int(value))

## Take a large float and convert it to a readable string with suffix
## EG: 154345.75 returns "154.3k", 1543450000.5 returns "1.5B"
func convert_long_float_to_string(number: float) -> String:
	return convert_long_int_to_string(int(number))


func get_total_creature_happiness_percentage() -> float:
	var total_happiness: float = 0.0
	var total_creatures: int = 0

	for creature in SaveManager.save_file.creature_inventory:
		if not creature.creature_is_in_tank:
			continue
		total_happiness += creature.creature_happiness
		total_creatures += 1

	if total_creatures == 0:
		return 0.0

	return total_happiness / total_creatures

## Get all creatures in the inventory
func get_all_creatures_in_inventory() -> Array[CreatureData]:
	var creatures: Array[CreatureData] = []
	for creature in SaveManager.save_file.creature_inventory:
		creatures.append(creature)
	return creatures

## Get all creatures in the tank
func get_all_creatures_in_tank() -> Array[CreatureData]:
	var creatures: Array[CreatureData] = []
	for creature in SaveManager.save_file.creature_inventory:
		if not creature.creature_is_in_tank:
			continue
		creatures.append(creature)
	return creatures


## Convert Celsius to Fahrenheit
func celsius_to_fahrenheit(celsius: float) -> float:
	return celsius * 1.8 + 32

## Convert Fahrenheit to Celsius

func fahrenheit_to_celsius(fahrenheit: float) -> float:
	return (fahrenheit - 32) / 1.8

func get_all_creatures_sorted(sort_type: CreatureSortType, sort_direction: SortDirection = SortDirection.ASCENDING) -> Array[CreatureData]:
	var creatures: Array[CreatureData] = get_all_creatures_in_inventory()
	creatures.sort_custom(func(a: CreatureData, b: CreatureData) -> bool:
		var result: bool = false
		
		match sort_type:
			CreatureSortType.NAME:
				result = a.creature_name < b.creature_name
			CreatureSortType.AGE:
				result = a.creature_age < b.creature_age
			CreatureSortType.HAPPINESS:
				result = a.creature_happiness < b.creature_happiness
			CreatureSortType.VALUE:
				result = a.creature_money_per_hour < b.creature_money_per_hour
			CreatureSortType.SPECIES:
				result = a.creature_species < b.creature_species
			CreatureSortType.RARITY:
				result = a.creature_rarity < b.creature_rarity
			CreatureSortType.HUNGER:
				result = a.creature_hunger < b.creature_hunger
			_:
				result = false
		
		# Invert result if descending order is requested
		if sort_direction == SortDirection.DESCENDING:
			result = !result
		return result
	)
	return creatures
