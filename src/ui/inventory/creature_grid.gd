extends GridContainer

var creature_item_scene: PackedScene = preload("uid://d8tgrkwn0t1w")

var creature_items: Array[UICreatureItem] = []

func _ready() -> void:
	_populate_grid()

func reload_grid() -> void:
	# Clear existing items
	for child in get_children():
		child.queue_free()
	
	# Repopulate the grid
	_populate_grid()

func _populate_grid() -> void:
	creature_items.clear()
	for creature in SaveManager.save_file.creature_inventory:
		# Skip creatures that are already in the tank
		if creature.is_in_tank:
			continue
			
		# Create and configure the creature item
		var creature_item = creature_item_scene.instantiate()
		creature_item.creature_data = creature
		creature_item.creature_added_to_tank.connect(_on_creature_added_to_tank)
		creature_item.creature_removed_from_tank.connect(_on_creature_removed_from_tank)
		
		# Add to the grid and track in our array
		add_child(creature_item)
		creature_items.append(creature_item)

func _on_creature_added_to_tank(creature_data: CreatureData) -> void:
	# Reload the grid when a creature is added to the tank
	reload_grid()

func _on_creature_removed_from_tank(creature_data: CreatureData) -> void:
	# Reload the grid when a creature is removed from the tank
	reload_grid()
