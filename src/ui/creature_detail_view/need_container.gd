extends MarginContainer
class_name NeedContainer

@export var _need_label: Label
@export var _need_meter: HorizontalMeterUI

@export var need_name: String:
	set(value):
		need_name = value
		if _need_label:
			_need_label.text = need_name

var value: float = 1.0:
	set(new_value):
		value = clamp(new_value, 0.0, 1.0)
		if _need_meter:
			_need_meter.value = value

func _ready() -> void:
	if _need_meter:
		_need_meter.max_value = 1.0
		_need_meter.value = value
	
	if _need_label and need_name:
		_need_label.text = need_name
