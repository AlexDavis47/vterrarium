extends HSlider

func _ready() -> void:
	value_changed.connect(_on_value_changed)
	
func _on_value_changed(value : float):
	VTHardware.brightness = value
