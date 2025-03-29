@tool
extends Node

var all_menus_closed: bool = true


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


## Play a sound effect
func play_sfx(sfx: AudioStream, min_pitch: float = 1.0, max_pitch: float = 1.0) -> void:
	var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sfx_player.stream = sfx
	sfx_player.pitch_scale = randf_range(min_pitch, max_pitch)
	get_tree().root.add_child(sfx_player)
	sfx_player.play()
	sfx_player.finished.connect(sfx_player.queue_free)


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
