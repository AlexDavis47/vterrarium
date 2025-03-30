extends Control
class_name CreatureDetailViewUI

########################################################
# Exports
########################################################

@export_group("Creature Data")
@export var creature_data: CreatureData

@export_group("UI Components")
@export var _accessory_equip_menu_button: TextureButton
@export var _rarity_and_type_label: Label
@export var _name_button: Button
@export var _name_rename_button: TextureButton
@export var _description_label: Label
@export var _species_label: Label
@export var _image: TextureRect

@export_group("Stat Containers")
@export var _money_per_hour_container: StatContainer
@export var _hunger_rate_container: StatContainer
@export var _speed_container: StatContainer
@export var _size_container: StatContainer

@export_group("Need Containers")
@export var _happiness_container: NeedContainer
@export var _satiation_container: NeedContainer

@export_group("Controls")
@export var _close_button: TextureButton

@export_group("Preference Graphs")
@export var _brightness_graph: CurveVisualizerUI
@export var _temperature_graph: CurveVisualizerUI

@export_group("Preview")
@export var _creature_live_camera: CreatureLiveCamera
@export var _creature_live_camera_subviewport_container: SubViewportContainer
@export var _creature_live_subviewport_container: ScenePreviewSubviewportContainer

########################################################
# Private Variables
########################################################

var _accessory_equip_menu_scene: PackedScene = preload("uid://d2ve1bal36q1d")
var _text_entry_ui_scene: PackedScene = preload("uid://dmowdukxcisg8")

########################################################
# Initialization
########################################################

func _ready() -> void:
	_initialize_connections()
	update_info()
	
	# Set up the preview creature if needed
	if !creature_data.creature_is_in_tank:
		var preview_creature: Creature = CreatureFactory.create_creature_preview(creature_data)
		_creature_live_subviewport_container.root_node.add_child(preview_creature)
	
	_update_camera_visibility()

func _initialize_connections() -> void:
	_close_button.pressed.connect(_on_close_button_pressed)
	_name_button.pressed.connect(_on_name_button_pressed)
	_name_rename_button.pressed.connect(_on_name_rename_button_pressed)
	_accessory_equip_menu_button.pressed.connect(_on_accessory_equip_menu_button_pressed)
	_creature_live_camera.creature_data = creature_data
	creature_data.trigger_preview_update.connect(_on_creature_data_trigger_preview_update)

########################################################
# UI Update Methods
########################################################

func update_info() -> void:
	_update_camera_visibility()
	_update_rarity_and_type()
	_update_name()
	_update_image()
	_update_species()
	_update_description()
	_update_money_per_hour()
	_update_hunger_rate()
	_update_speed()
	_update_size()
	_update_happiness()
	_update_satiation()
	_update_brightness_graph()
	_update_temperature_graph()

func _update_camera_visibility() -> void:
	if creature_data.creature_is_in_tank:
		_creature_live_camera_subviewport_container.visible = true
		_creature_live_subviewport_container.visible = false
	else:
		_creature_live_camera_subviewport_container.visible = false
		_creature_live_subviewport_container.visible = true
		# Force an update of the preview
		_creature_live_subviewport_container.force_update()

func _update_rarity_and_type() -> void:
	var rarity_string: String = Enums.Rarity.keys()[creature_data.creature_rarity]
	rarity_string = rarity_string.capitalize()

	var type_string: String = CreatureFactory.CreatureType.keys()[creature_data.creature_type]
	type_string = type_string.capitalize()

	_rarity_and_type_label.text = rarity_string + " " + type_string

func _update_name() -> void:
	_name_button.text = creature_data.creature_name

func _update_image() -> void:
	_image.texture = creature_data.creature_image

func _update_species() -> void:
	_species_label.text = creature_data.creature_species

func _update_description() -> void:
	_description_label.text = creature_data.creature_description

func _update_money_per_hour() -> void:
	_money_per_hour_container.stat = "Earns"
	_money_per_hour_container.value = "%.0f" % creature_data.creature_money_per_hour
	_money_per_hour_container.unit = "Coins per Hour"

func _update_hunger_rate() -> void:
	_hunger_rate_container.stat = "Loses"
	_hunger_rate_container.value = "%.0f" % (creature_data.creature_hunger_rate * 100) + "%"
	_hunger_rate_container.unit = "Satiation per Hour"

func _update_speed() -> void:
	_speed_container.stat = "Moves"
	var speed_percentage = (creature_data.creature_speed - 1.0) * 100
	var speed_text = ""
	
	if speed_percentage > 0:
		speed_text = "+%.0f" % speed_percentage + "% faster than average"
	elif speed_percentage < 0:
		speed_text = "%.0f" % abs(speed_percentage) + "% slower than average"
	else:
		speed_text = "Average speed"
		
	_speed_container.value = speed_text
	_speed_container.unit = ""

func _update_size() -> void:
	_size_container.stat = "Is"
	var size_percentage = (creature_data.creature_size - 1.0) * 100
	var size_text = ""
	
	if size_percentage > 0:
		size_text = "+%.0f" % size_percentage + "% larger than average"
	else:
		size_text = "%.0f" % abs(size_percentage) + "% smaller than average"
		
	_size_container.value = size_text
	_size_container.unit = ""

func _update_happiness() -> void:
	_happiness_container.need_name = "Happiness"
	_happiness_container.value = creature_data.creature_happiness

func _update_satiation() -> void:
	_satiation_container.need_name = "Satiation"
	_satiation_container.value = creature_data.creature_satiation

func _update_brightness_graph() -> void:
	_brightness_graph.curve = creature_data.creature_light_preference
	_brightness_graph.current_value = VTHardware.brightness

func _update_temperature_graph() -> void:
	_temperature_graph.curve = creature_data.creature_temperature_preference
	_temperature_graph.current_value = Utils.celsius_to_fahrenheit(VTHardware.temperature)

########################################################
# Signal Handlers
########################################################

func _on_close_button_pressed() -> void:
	VTGlobal.onscreen_keyboard.hide()
	queue_free()

func _on_name_button_pressed() -> void:
	var text_entry_ui = _text_entry_ui_scene.instantiate()
	text_entry_ui.prompt = "Rename Creature"
	text_entry_ui.placeholder = creature_data.creature_name
	text_entry_ui.text = creature_data.creature_name
	text_entry_ui.text_confirmed.connect(_on_text_entry_ui_text_confirmed)
	add_child(text_entry_ui)

func _on_name_rename_button_pressed() -> void:
	var text_entry_ui = _text_entry_ui_scene.instantiate()
	text_entry_ui.prompt = "Rename Creature"
	text_entry_ui.placeholder = creature_data.creature_name
	text_entry_ui.text = creature_data.creature_name
	text_entry_ui.text_confirmed.connect(_on_text_entry_ui_text_confirmed)
	add_child(text_entry_ui)

func _on_accessory_equip_menu_button_pressed() -> void:
	var accessory_equip_menu = _accessory_equip_menu_scene.instantiate()
	accessory_equip_menu.creature_data = creature_data
	add_child(accessory_equip_menu)

func _on_creature_data_trigger_preview_update() -> void:
	_creature_live_subviewport_container.clear_root_node()
	var preview_creature: Creature = CreatureFactory.create_creature_preview(creature_data)
	_creature_live_subviewport_container.add_child_to_root_node(preview_creature)
	_creature_live_subviewport_container.force_update()

func _on_text_entry_ui_text_confirmed(text: String) -> void:
	creature_data.creature_name = text
	VTGlobal.trigger_inventory_refresh.emit()
	_name_button.text = text
