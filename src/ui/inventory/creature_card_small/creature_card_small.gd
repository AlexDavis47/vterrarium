## This is a card style item to display a creature in the inventory.
extends TextureRect
class_name CreatureCardSmall

@export var rarity_and_type_label: Label
@export var name_label: Label
@export var image: TextureRect
@export var species_label: Label
@export var add_remove_button: TextureButton
@export var detail_button: TextureButton
@export var in_tank_marker: TextureRect
@export var has_accessories_marker: TextureRect

@export var creature_preview_subviewport_container: ScenePreviewSubviewportContainer

var _add_to_tank_texture: Texture2D = preload("uid://xj5qbwybtu27")
var _remove_from_tank_texture: Texture2D = preload("uid://bldq2ksww120x")

var _detailed_view_ui_scene: PackedScene = preload("uid://c7ripghigdapa")

signal add_remove_button_pressed(creature_data: CreatureData)
signal detail_button_pressed(creature_data: CreatureData)

@export var creature_data: CreatureData

func _ready() -> void:
	add_remove_button.pressed.connect(_on_add_remove_button_pressed)
	detail_button.pressed.connect(_on_detail_button_pressed)

	var preview_creature: Creature = CreatureFactory.create_creature_preview(creature_data)
	creature_preview_subviewport_container.root_node.add_child(preview_creature)
	
	if creature_data:
		update_info()

func update_info() -> void:
	_update_rarity_and_type()
	_update_name()
	_update_image()
	_update_species()
	_update_add_remove_button()
	_update_in_tank_marker()
	_update_has_accessories_marker()

func _update_rarity_and_type() -> void:
	var rarity_string: String = Enums.Rarity.keys()[creature_data.creature_rarity]
	rarity_string = rarity_string.capitalize()

	var type_string: String = CreatureFactory.CreatureType.keys()[creature_data.creature_type]
	type_string = type_string.capitalize()

	rarity_and_type_label.text = rarity_string + " " + type_string

func _update_name() -> void:
	name_label.text = creature_data.creature_name

func _update_image() -> void:
	image.texture = creature_data.creature_image

func _update_species() -> void:
	species_label.text = creature_data.creature_species

func _update_add_remove_button() -> void:
	if creature_data.creature_is_in_tank:
		add_remove_button.texture_normal = _remove_from_tank_texture
	else:
		add_remove_button.texture_normal = _add_to_tank_texture

func _update_in_tank_marker() -> void:
	if creature_data.creature_is_in_tank:
		in_tank_marker.visible = true
	else:
		in_tank_marker.visible = false

func _update_has_accessories_marker() -> void:
	if AccessoryFactory.does_creature_have_any_accessories_equipped(creature_data):
		has_accessories_marker.visible = true
	else:
		has_accessories_marker.visible = false

func _on_add_remove_button_pressed() -> void:
	# If the creature is in the tank, remove it from the tank
	if creature_data.creature_is_in_tank:
		CreatureFactory.remove_creature_by_data(creature_data)
	else:
		CreatureFactory.spawn_creature(creature_data)
	add_remove_button_pressed.emit(creature_data)

func _on_detail_button_pressed() -> void:
	detail_button_pressed.emit(creature_data)

	var detailed_view_ui: CreatureDetailViewUI = _detailed_view_ui_scene.instantiate()
	detailed_view_ui.creature_data = creature_data
	VTGlobal.top_ui.add_child(detailed_view_ui)
