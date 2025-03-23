extends GridContainer

var creature_item_scene: PackedScene = preload("uid://d8tgrkwn0t1w")

var creature_items: Array[CreatureCardSmall] = []

func _ready() -> void:
	_populate_grid()
	VTGlobal.trigger_inventory_refresh.connect(_on_trigger_inventory_refresh)

func _on_trigger_inventory_refresh() -> void:
	reload_grid()

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
		# if creature.is_in_tank:
		# 	continue
		# Create and configure the creature item
		var creature_item = creature_item_scene.instantiate()
		creature_item.creature_data = creature
		creature_item.add_remove_button_pressed.connect(_on_add_remove_button_pressed)
		
		# Add to the grid and track in our array
		add_child(creature_item)
		creature_items.append(creature_item)

func _on_add_remove_button_pressed(creature_data: CreatureData) -> void:
	# Reload the grid when a creature is added to the tank
	reload_grid()
