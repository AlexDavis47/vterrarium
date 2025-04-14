extends Control

@export var food_card_container: VBoxContainer
@export var food_card_template: PackedScene
@export var touch_zone: Control

# Keep track of the currently selected card and food data
var selected_index: int = -1
var selected_food_data: FishFoodData = null

func _ready() -> void:
	update_ui()
	initialize_connections()

func update_ui() -> void:
	# Clear and repopulate
	clear_food_cards()
	populate_food_cards()

func initialize_connections() -> void:
	if touch_zone:
		# Connect touch input on the touch zone
		touch_zone.gui_input.connect(_on_touch_zone_input)

func _on_food_card_selected(card: FoodCard, food_data: FishFoodData) -> void:
	# Store the new selection state
	var new_selected_index = card.get_index()
	selected_food_data = food_data

	# Only proceed if the selection actually changed
	if new_selected_index == selected_index:
		# If clicking the already selected card, ensure it stays visually selected
		# (in case something external tried to deselect it)
		card.is_selected = true
		return

	selected_index = new_selected_index

	# Update the selection state for all cards
	for i in range(food_card_container.get_child_count()):
		var child = food_card_container.get_child(i)
		if child is FoodCard:
			child.is_selected = (i == selected_index)

	# No need to explicitly set card.is_selected = true here, the loop handles it.


## Handle touch input on the touch zone
func _on_touch_zone_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if selected_food_data:
			# Convert touch position to global coordinates
			var touch_position = touch_zone.get_global_transform_with_canvas().origin + event.position
			var camera = VTGlobal.top_camera
			var world_position = camera.project_position(touch_position, camera.global_position.y - VTConfig.terrarium_dimensions.y / 2)
			
			# Spawn the selected food at the touch position
			FoodFactory.spawn_food(selected_food_data, world_position)

			if selected_food_data.number_owned <= 0:
				selected_food_data = null
				selected_index = -1
			
			# Force a complete refresh to update all cards with current inventory data
			update_ui()

func populate_food_cards() -> void:
	var food_data_array = SaveManager.save_file.food_inventory
	food_data_array.sort_custom(func(a: FishFoodData, b: FishFoodData): return a.food_name < b.food_name)

	for i in range(food_data_array.size()): # Iterate with index
		var food_data = food_data_array[i]
		var card_instance: FoodCard = food_card_template.instantiate()
		card_instance.food_data = food_data
		
		# Set the selected state based on the stored index
		card_instance.is_selected = (i == selected_index)
			
		food_card_container.add_child(card_instance)
		
		# Connect signals
		if not card_instance.selected.is_connected(_on_food_card_selected):
			card_instance.selected.connect(_on_food_card_selected)

func clear_food_cards() -> void:
	for child in food_card_container.get_children():
		child.queue_free()
