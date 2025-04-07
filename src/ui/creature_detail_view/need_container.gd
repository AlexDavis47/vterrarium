extends MarginContainer
class_name NeedContainer

@export var _need_label: Label
@export var _need_meter: TextureRect

@export var need_name: String:
	set(value):
		need_name = value
		if _need_label:
			_need_label.text = need_name

var _need_meter_width: float = 0.0

var value: float = 1.0:
	set(new_value):
		value = clamp(new_value, 0.0, 1.0)
		if _need_meter:
			_need_meter.size.x = value * _need_meter_width

func _ready() -> void:
	if _need_meter:
		_need_meter_width = _need_meter.get_parent().size.x
	
	if _need_label and need_name:
		_need_label.text = need_name
	
	# Initialize meter with current value
	if _need_meter and _need_meter_width > 0:
		_need_meter.size.x = value * _need_meter_width
