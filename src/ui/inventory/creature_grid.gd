extends GridContainer

var creature_item_scene: PackedScene = preload("uid://d8tgrkwn0t1w")

var creature_items: Array[CreatureCardSmall] = []
const CARD_CREATION_DELAY: float = 0.05 # Delay between creating each card in seconds

func _ready() -> void:
	_populate_grid()
	VTGlobal.trigger_inventory_refresh.connect(_on_trigger_inventory_refresh)

func _on_trigger_inventory_refresh() -> void:
	reload_grid()

func reload_grid() -> void:
	# Clear all existing cards
	for item in creature_items:
		if is_instance_valid(item):
			remove_child(item)
			item.queue_free()
	creature_items.clear()
	
	# Get sort options from the creatures tab
	var sort_type = Utils.CreatureSortType.NAME
	var sort_direction = Utils.SortDirection.ASCENDING
	
	# Find the creatures tab to get current sort settings
	var creatures_tab = _find_creatures_tab()
	if creatures_tab:
		sort_type = creatures_tab.get_current_sort_type()
		sort_direction = creatures_tab.get_current_sort_direction()
	
	# Get sorted creatures
	var creatures_to_add = Utils.get_all_creatures_sorted(sort_type, sort_direction)
	
	# Create cards with delay
	_create_cards_with_delay(creatures_to_add)

# Find the creatures tab node to access sort settings
func _find_creatures_tab():
	var parent = get_parent()
	while parent and not parent is VBoxContainer:
		parent = parent.get_parent()
	
	if parent and parent.has_method("get_current_sort_type"):
		return parent
	
	push_error("Could not find creatures tab with sorting functionality")
	return null
	
func _create_cards_with_delay(creatures_to_create: Array) -> void:
	var index = 0
	
	# Create the first card immediately
	if index < creatures_to_create.size():
		_create_creature_card(creatures_to_create[index])
		index += 1
	
	# Create a timer to add the rest with delay
	while index < creatures_to_create.size():
		var creature = creatures_to_create[index]
		var timer = get_tree().create_timer(CARD_CREATION_DELAY)
		await timer.timeout
		_create_creature_card(creature)
		index += 1

func _create_creature_card(creature: CreatureData) -> void:
	var creature_item: CreatureCardSmall = creature_item_scene.instantiate()
	creature_item.creature_data = creature
	creature_item.add_remove_button_pressed.connect(_on_add_remove_button_pressed)
	add_child(creature_item)
	creature_items.append(creature_item)

	var tween = creature_item.create_tween()
	creature_item.modulate = Color(1, 1, 1, 0)
	tween.tween_property(creature_item, "modulate", Color(1, 1, 1, 1), 0.25)
	tween.set_trans(Tween.TRANS_QUAD)
	
func _populate_grid() -> void:
	creature_items.clear()
	
	# Get sort options from the creatures tab
	var sort_type = Utils.CreatureSortType.NAME
	var sort_direction = Utils.SortDirection.ASCENDING
	
	# Find the creatures tab to get current sort settings
	var creatures_tab = _find_creatures_tab()
	if creatures_tab:
		sort_type = creatures_tab.get_current_sort_type()
		sort_direction = creatures_tab.get_current_sort_direction()
	
	var creatures_to_add = Utils.get_all_creatures_sorted(sort_type, sort_direction)
	
	# Create cards with delay
	_create_cards_with_delay(creatures_to_add)

func _on_add_remove_button_pressed(creature_data: CreatureData) -> void:
	# Update the specific card that changed
	for item in creature_items:
		if item.creature_data.creature_id == creature_data.creature_id:
			item.update_info()
			break
