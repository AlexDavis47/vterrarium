## This class is used to generate creatures randomly, and off of creature pools
@tool
extends Node

enum CreaturePool {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY
}

enum CreatureType {
	FISH,
	CRAB
}

enum Creatures {
	BLUE_FISH,
	RED_FISH,
	YELLOW_TANG_FISH,
	AXOLOTL,
	MYSTERY_FISH,
	CREDITS_ALEX,
	CREDITS_ALICIA,
	CREDITS_MAIKA,
	CREDITS_LANCE,
	CREDITS_SYLVIA,
	LIL_BLUE_FISH
}


## This contains a list of all of the creature data resources that we can duplicate to create new creatures
## Stored mainly for scanning pools
var creature_data_templates: Dictionary[Creatures, CreatureData] = {
	Creatures.BLUE_FISH: preload("uid://bi10nf3pilsau"),
	Creatures.RED_FISH: preload("uid://x7f8v6e3a7u2"),
	Creatures.YELLOW_TANG_FISH: preload("uid://cl4iqwjh3g3cm"),
	Creatures.AXOLOTL: preload("uid://b2whh0mnx8dh"),
	Creatures.MYSTERY_FISH: preload("uid://byfmr0pletltf"),
	Creatures.CREDITS_ALEX: preload("uid://duf8h8xtuyku3"),
	Creatures.CREDITS_ALICIA: preload("uid://jgors16k8mmq"),
	Creatures.CREDITS_MAIKA: preload("uid://brp3bkjmcrbb"),
	Creatures.CREDITS_SYLVIA: preload("uid://dsa7mg82m6842"),
	Creatures.CREDITS_LANCE: preload("uid://4oej1iqrknt6"),
	Creatures.LIL_BLUE_FISH: preload("uid://r1xm2w02drrx")
}

signal creature_added(creature_data: CreatureData)
signal creature_removed(creature_data: CreatureData)


func run_test_cycle() -> void:
		# Initial setup for testing - create creatures and add to tank
	#_create_test_creatures()
	var creature = create_creature(Creatures.RED_FISH)
	SaveManager.save_file.creature_inventory.append(creature)
	_add_creature_to_tank(creature)


	# # Test cycle 1: Remove all creatures from tank
	# await get_tree().create_timer(1.0).timeout
	# _remove_all_creatures_from_tank()
	
	# # Test cycle 2: Add all creatures back to tank
	# await get_tree().create_timer(1.0).timeout
	# _add_all_creatures_to_tank()
	
	# # Test cycle 3: Remove all creatures from tank again
	# await get_tree().create_timer(1.0).timeout
	# _remove_all_creatures_from_tank()

	# # Test cycle 4: Add all creatures back to tank again
	# await get_tree().create_timer(1.0).timeout
	# _add_all_creatures_to_tank()


## Creates test creatures and adds them to the inventory and tank
func _create_test_creatures() -> void:
	for creature_type in creature_data_templates.keys():
		for i in range(1):
			var new_creature = create_creature(creature_type)
			SaveManager.save_file.creature_inventory.append(new_creature)
			_add_creature_to_tank(new_creature)

## Creates a new creature of the specified type with random luck
func create_creature(creature_type: Creatures) -> CreatureData:
	var template = creature_data_templates[creature_type]
	var new_creature: CreatureData = template.duplicate(true)
	new_creature.on_generated(randf_range(0.5, 1.5))
	return new_creature

func create_creature_from_data(creature_data: CreatureData) -> CreatureData:
	var new_creature: CreatureData = creature_data.duplicate(true)
	new_creature.on_generated(randf_range(0.5, 1.5))
	return new_creature

## Generates a new creature from a template with random luck
## @deprecated Use create_creature instead
func _generate_creature_from_template(template: CreatureData) -> CreatureData:
	var new_creature: CreatureData = template.duplicate(true)
	new_creature.on_generated(randf_range(0.5, 1.5))
	return new_creature

## Adds all creatures in inventory to the tank
func _add_all_creatures_to_tank() -> void:
	for creature_data in SaveManager.save_file.creature_inventory:
		_add_creature_to_tank(creature_data)

## Removes all creatures from the tank but keeps them in inventory
func _remove_all_creatures_from_tank() -> void:
	for creature_data in SaveManager.save_file.creature_inventory:
		if creature_data.creature_is_in_tank:
			_remove_creature_from_tank(creature_data)

## Adds a creature to the tank
func _add_creature_to_tank(creature_data: CreatureData) -> void:
	# Generate a safe random initial position within tank bounds
	var half_width := VTConfig.width * 0.5 - 1.0
	var half_height := VTConfig.height * 0.5 - 1.0
	var half_depth := VTConfig.depth * 0.5 - 1.0
	
	creature_data.creature_position = Vector3(
		randf_range(-half_width, half_width),
		randf_range(-half_height, half_height),
		randf_range(-half_depth, half_depth)
	)
	
	var creature_scene = load(creature_data.creature_scene_uuid)
	var creature = creature_scene.instantiate()
	
	# Set creature data before adding to scene tree
	creature.creature_data = creature_data
	creature_data.creature_is_in_tank = true
	creature_data.creature_instance = creature

	
	# Add to scene tree after all data is properly set
	call_deferred("_deferred_add_creature", creature)

# New method to safely add creature to scene tree
func _deferred_add_creature(creature: Node) -> void:
	add_child(creature)
	creature_added.emit(creature.creature_data)

## Removes a creature from the tank
func _remove_creature_from_tank(creature_data: CreatureData) -> void:
	creature_data.creature_is_in_tank = false
	if is_instance_valid(creature_data.creature_instance):
		creature_data.creature_instance.queue_free()
	creature_data.creature_instance = null
	# Emit signal after creature is properly removed
	creature_removed.emit(creature_data)

## Public method to spawn a creature in the tank
func spawn_creature(creature_data: CreatureData) -> void:
	if creature_data.creature_is_in_tank:
		return
	if get_number_of_creatures_in_tank() >= SaveManager.save_file.tank_capacity:
		VTGlobal.display_notification("Cannot add more creatures, max capacity reached!")
		return
	_add_creature_to_tank(creature_data)
	AudioManager.play_sfx(AudioManager.SFX.SPLASH_1, 0.8, 1.2)

## Public method to remove a creature from the tank
func remove_creature(creature: Creature) -> void:
	if is_instance_valid(creature) and creature.creature_data:
		_remove_creature_from_tank(creature.creature_data)
		
func remove_creature_by_data(creature_data: CreatureData) -> void:
	if creature_data and creature_data.creature_is_in_tank:
		_remove_creature_from_tank(creature_data)


func generate_creature_from_pool(pool: CreaturePool) -> CreatureData:
	var viable_creatures: Array[Creatures] = []
	var viable_chances: Dictionary = {}
	
	for creature_type in creature_data_templates.keys():
		var template: CreatureData = creature_data_templates[creature_type]
		for pool_chance: PoolChance in template.creature_pool_chances:
			if pool_chance.pool == pool:
				viable_creatures.append(creature_type)
				viable_chances[creature_type] = pool_chance.chance

	var total_chance: float = 0.0
	for creature_type in viable_creatures:
		total_chance += viable_chances[creature_type]

	# Handle case where no creatures are available for this pool
	if total_chance <= 0 or viable_creatures.is_empty():
		return null

	var random_value: float = randf_range(0.0, total_chance)
	var cumulative_chance: float = 0.0
	
	for creature_type in viable_creatures:
		cumulative_chance += viable_chances[creature_type]
		if random_value <= cumulative_chance:
			return create_creature(creature_type)

	# Fallback in case of floating point errors
	if not viable_creatures.is_empty():
		return create_creature(viable_creatures[viable_creatures.size() - 1])
	return null


func get_creature_by_id(id: String) -> CreatureData:
	if id.is_empty():
		return null
	for creature in SaveManager.save_file.creature_inventory:
		if creature.creature_id == id:
			return creature
	return null

func get_creature_instance_by_id(id: String) -> Creature:
	if id.is_empty():
		return null
	for creature in get_tree().get_nodes_in_group("creatures"):
		if is_instance_valid(creature) and creature.creature_data and creature.creature_data.creature_id == id:
			return creature
	return null


func create_creature_preview(creature_data: CreatureData) -> Creature:
	if not creature_data:
		return null
	var creature_scene = load(creature_data.creature_scene_uuid)
	var creature = creature_scene.instantiate()
	creature.creature_data = creature_data
	creature._is_in_preview_mode = true
	creature.process_mode = PROCESS_MODE_DISABLED
	return creature

func sell_creature(creature_data: CreatureData) -> void:
	if not creature_data:
		return
	if SaveManager.save_file.creature_inventory.size() <= 1: # Don't allow selling the last creature
		AudioManager.play_sfx(AudioManager.SFX.CANCEL_1)
		VTGlobal.display_notification("Cannot sell last creature!")
		return
	if creature_data.creature_is_in_tank:
		if is_instance_valid(creature_data.creature_instance):
			remove_creature(creature_data.creature_instance)
		else:
			creature_data.creature_is_in_tank = false
	AccessoryFactory.unequip_all_accessories(creature_data)
	SaveManager.save_file.creature_inventory.erase(creature_data)
	SaveManager.save_file.money += creature_data.get_price()
	VTGlobal.display_notification("Sold creature: %s for %s coins!" % [creature_data.creature_name, creature_data.get_price()])
	# Ensure signal is emitted even if creature was not in tank
	creature_removed.emit(creature_data)
	AudioManager.play_sfx(AudioManager.SFX.COINS_1, 0.8, 1.2)
	VTGlobal.trigger_inventory_refresh.emit()

func get_number_of_creatures_in_tank() -> int:
	var count: int = 0
	for creature in get_tree().get_nodes_in_group("creatures"):
		if is_instance_valid(creature) and creature.creature_data and creature.creature_data.creature_is_in_tank:
			count += 1
	return count
