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
	var current_creature_ids = {}
	var inventory_creature_ids = {}
	
	# Map existing creature cards by creature ID
	for item in creature_items:
		if is_instance_valid(item) and item.creature_data:
			current_creature_ids[item.creature_data.creature_id] = item
	
	# Get sorted creatures and map by ID
	var sorted_creatures = Utils.get_all_creatures_sorted(Utils.CreatureSortType.NAME)
	for creature in sorted_creatures:
		inventory_creature_ids[creature.creature_id] = creature
	
	# Remove cards for creatures no longer in inventory
	for creature_id in current_creature_ids:
		if not inventory_creature_ids.has(creature_id):
			var item = current_creature_ids[creature_id]
			creature_items.erase(item)
			remove_child(item)
			item.queue_free()
	
	# Add cards for new creatures with delay
	var new_creatures = []
	for creature_id in inventory_creature_ids:
		if not current_creature_ids.has(creature_id):
			new_creatures.append(inventory_creature_ids[creature_id])
		else:
			# Update existing cards
			current_creature_ids[creature_id].update_info()
	
	# Create new cards with delay
	if new_creatures.size() > 0:
		_create_cards_with_delay(new_creatures)
	
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
	var creatures_to_add = Utils.get_all_creatures_sorted(Utils.CreatureSortType.VALUE, Utils.SortDirection.ASCENDING)
	
	# Create cards with delay
	_create_cards_with_delay(creatures_to_add)

func _on_add_remove_button_pressed(creature_data: CreatureData) -> void:
	# Update the specific card that changed
	for item in creature_items:
		if item.creature_data.creature_id == creature_data.creature_id:
			item.update_info()
			break
