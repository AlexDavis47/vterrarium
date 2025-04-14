@tool
extends TextureRect
class_name FoodCard

@export var food_data: FishFoodData:
	set(value):
		food_data = value
		update_ui()

@export var food_name: Label
@export var scene_preview: ScenePreviewSubviewportContainer

func _ready() -> void:
	update_ui()
	initialize_connections()

func initialize_connections() -> void:
	if food_data:
		food_data.changed.connect(update_ui)

func update_ui() -> void:
	if food_data == null:
		return
	update_name()
	update_scene_preview()

func update_name() -> void:
	if food_name and food_data:
		food_name.text = food_data.food_name

func update_scene_preview() -> void:
	if scene_preview and food_data and food_data.food_scene_path:
		scene_preview.clear_root_node()
		scene_preview.add_child_to_root_node(load(food_data.food_scene_path).instantiate())
