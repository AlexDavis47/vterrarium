extends OmniLight3D

func _ready():
	VTHardware.photodiode_changed.connect(_on_photodiode_changed)

func _on_photodiode_changed(raw_value: int, normalized_value: float) -> void:
	light_energy = normalized_value * 10
