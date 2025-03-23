extends HBoxContainer
class_name StatContainer

@export var _stat_label: Label
@export var _value_label: Label
@export var _unit_label: Label

@export var stat: String:
	set(value):
		stat = value
		if _stat_label:
			_stat_label.text = stat
@export var value: String:
	set(value):
		value = value
		if _value_label:
			_value_label.text = value
@export var unit: String:
	set(value):
		unit = value
		if _unit_label:
			_unit_label.text = unit

func _ready() -> void:
	if _stat_label:
		_stat_label.text = stat
	if _value_label:
		_value_label.text = value
	if _unit_label:
		_unit_label.text = unit
