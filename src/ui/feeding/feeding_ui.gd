extends Control

@export var food_card_container: VBoxContainer
@export var food_card_template: PackedScene
@export var touch_zone: Control

# Keep track of the currently selected card and food data
var selected_card: FoodCard
var selected_food_data: FishFoodData

func _ready() -> void:
	update_ui()
	initialize_connections()

func update_ui() -> void:
	# Remember the selected index
	var selected_index = -1
	if selected_card:
		selected_index = selected_card.get_index()
	
	# Clear and repopulate
	clear_food_cards()
	populate_food_cards()
	
	# Try to select the same index, or the first card if that index no longer exists
	if selected_index >= 0 and selected_index < food_card_container.get_child_count():
		var card = food_card_container.get_child(selected_index)
		if card is FoodCard:
			card.set_selected(true)
			selected_card = card
			selected_food_data = card.food_data
	elif food_card_container.get_child_count() > 0:
		var first_card = food_card_container.get_child(0)
		if first_card is FoodCard:
			first_card.set_selected(true)
			selected_card = first_card
			selected_food_data = first_card.food_data

func initialize_connections() -> void:
	if touch_zone:
		# Connect touch input on the touch zone
		touch_zone.gui_input.connect(_on_touch_zone_input)

func _on_food_card_selected(card: FoodCard, food_data: FishFoodData) -> void:
	# Deselect all other cards
	for other_card in food_card_container.get_children():
		if other_card != card and other_card is FoodCard:
			other_card.set_selected(false)
	
	# Ensure the selected card is marked as selected
	card.set_selected(true)
	
	# Store the selected card and food data
	selected_card = card
	selected_food_data = food_data

## Handle touch input on the touch zone
func _on_touch_zone_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if selected_food_data:
			var touch_position = event.position
			var camera = VTGlobal.top_camera
			var world_position = camera.project_position(touch_position, camera.global_position.y - VTConfig.terrarium_dimensions.y / 2)
			
			# Spawn the selected food at the touch position
			FoodFactory.spawn_food(selected_food_data, world_position)
			
			# Force a complete refresh to update all cards with current inventory data
			update_ui()
			
			# Signal that inventory updated (if you have such a signal elsewhere)
			if VTGlobal.has_signal("trigger_inventory_refresh"):
				VTGlobal.trigger_inventory_refresh.emit()

func populate_food_cards() -> void:
	# Create a fresh card for each food in inventory
	for food_data in SaveManager.save_file.food_inventory:
		var card_instance = food_card_template.instantiate() as FoodCard
		food_card_container.add_child(card_instance)
		
		# Important: Set food_data after adding to tree so signals connect properly
		card_instance.food_data = food_data
		
		# Connect signals
		if not card_instance.selected.is_connected(_on_food_card_selected):
			card_instance.selected.connect(_on_food_card_selected)

func clear_food_cards() -> void:
	for child in food_card_container.get_children():
		child.queue_free()
