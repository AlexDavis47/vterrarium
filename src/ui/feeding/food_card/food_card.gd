@tool
extends TextureRect
class_name FoodCard

signal selected(food_data: FishFoodData)

@export var food_data: FishFoodData:
	set(value):
		food_data = value
		update_ui()

@export var food_name: Label
@export var food_description: Label
@export var scene_preview: ScenePreviewSubviewportContainer
@export var select_button: TextureButton
@export var number_owned: Label
@export var selected_label: Label
@export var selected_color_rect: ColorRect

@export var selected_color: Color = Color(0.5, 0.5, 0.5, 0.5)
@export var unselected_color: Color = Color(0.5, 0.5, 0.5, 0.5)

var is_selected: bool = false:
	set(value):
		is_selected = value
		update_selected()


########################################################
# Initialization
########################################################

func _ready() -> void:
	update_ui()
	initialize_connections()

func initialize_connections() -> void:
	if food_data:
		food_data.changed.connect(_on_food_data_changed)
	if select_button:
		select_button.pressed.connect(_on_select_button_pressed)

########################################################
# Body
########################################################

func update_ui() -> void:
	if food_data == null:
		return
	update_name()
	update_scene_preview()
	update_description()
	update_number_owned()
	update_selected()

func update_name() -> void:
	if food_name and food_data:
		food_name.text = food_data.food_name
		
func update_description() -> void:
	if food_description:
		food_description.text = food_data.food_description

func update_number_owned() -> void:
	if number_owned:
		if food_data.is_infinite_use:
			number_owned.text = "∞"
		else:
			number_owned.text = str(food_data.number_owned)

func update_scene_preview() -> void:
	if scene_preview and food_data and food_data.food_scene_path:
		scene_preview.clear_root_node()
		var food_scene: PackedScene = load(food_data.food_scene_path)
		if food_scene:
			var food_instance: FishFood = food_scene.instantiate()
			food_instance.fish_food_data = food_data
			scene_preview.add_child_to_root_node(food_instance)

func update_selected() -> void:
	if selected_label:
		selected_label.text = "Selected" if is_selected else "Unselected"
	if selected_color_rect:
		selected_color_rect.color = selected_color if is_selected else unselected_color

########################################################
# Signal Handlers
########################################################

func _on_food_data_changed() -> void:
	update_ui()

func _on_select_button_pressed() -> void:
	is_selected = true
	update_selected()
	selected.emit(self, food_data)
