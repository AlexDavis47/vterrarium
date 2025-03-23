extends TextureRect
class_name HappinessBar

@export var min_width = 0
@export var max_width = 200

func _physics_process(delta: float) -> void:
	var happiness_percentage = Utils.get_total_creature_happiness_percentage()
	var width = min_width + (max_width - min_width) * happiness_percentage
	size.x = width
