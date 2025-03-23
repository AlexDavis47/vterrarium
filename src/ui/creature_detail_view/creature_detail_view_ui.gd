extends Control
class_name CreatureDetailViewUI

@export var creature_data: CreatureData

@export var _rarity_and_type_label: Label
@export var _name_line_edit: LineEdit
@export var _description_label: Label
@export var _species_label: Label
@export var _image: TextureRect

@export var _money_per_hour_container: StatContainer
@export var _hunger_rate_container: StatContainer

@export var _happiness_container: NeedContainer
@export var _satiation_container: NeedContainer

@export var _close_button: TextureButton


func _ready() -> void:
	_close_button.pressed.connect(_on_close_button_pressed)
	update_info()
	_name_line_edit.text_changed.connect(_on_name_line_edit_changed)

func update_info() -> void:
	_update_rarity_and_type()
	_update_name()
	_update_image()
	_update_species()
	_update_description()
	_update_money_per_hour()
	_update_hunger_rate()
	_update_happiness()
	_update_satiation()


func _update_rarity_and_type() -> void:
	var rarity_string: String = Enums.Rarity.keys()[creature_data.creature_rarity]
	rarity_string = rarity_string.capitalize()

	var type_string: String = CreatureFactory.CreatureType.keys()[creature_data.creature_type]
	type_string = type_string.capitalize()

	_rarity_and_type_label.text = rarity_string + " " + type_string

func _update_name() -> void:
	_name_line_edit.text = creature_data.creature_name

func _update_image() -> void:
	_image.texture = creature_data.creature_image

func _update_species() -> void:
	_species_label.text = creature_data.creature_species

func _update_description() -> void:
	_description_label.text = creature_data.creature_description

func _update_money_per_hour() -> void:
	_money_per_hour_container.stat = "Earns"
	_money_per_hour_container.value = "%.2f" % creature_data.creature_money_per_hour
	_money_per_hour_container.unit = "Coins per Hour"

func _update_hunger_rate() -> void:
	_hunger_rate_container.stat = "Gains"
	_hunger_rate_container.value = "%.2f" % creature_data.creature_hunger_rate
	_hunger_rate_container.unit = "Hunger per Hour"

func _update_happiness() -> void:
	_happiness_container.need_name = "Happiness"
	_happiness_container.value = creature_data.creature_happiness

func _update_satiation() -> void:
	_satiation_container.need_name = "Satiation"
	_satiation_container.value = creature_data.creature_satiation

func _on_close_button_pressed() -> void:
	queue_free()

func _on_name_line_edit_changed(new_text: String) -> void:
	creature_data.creature_name = new_text
	VTGlobal.trigger_inventory_refresh.emit()
