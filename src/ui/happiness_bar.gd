extends TextureRect
class_name HappinessBar

@export var min_width = 0
@export var max_width = 200
@export var lerp_speed = 5.0

var current_width = 0

func _ready() -> void:
	# Initialize current_width to avoid sudden jumps on startup
	var happiness_percentage = Utils.get_total_creature_happiness_percentage()
	current_width = min_width + (max_width - min_width) * happiness_percentage
	size.x = current_width

func _physics_process(delta: float) -> void:
	var happiness_percentage = Utils.get_total_creature_happiness_percentage()
	var target_width = min_width + (max_width - min_width) * happiness_percentage
	
	# Smoothly interpolate between current width and target width
	current_width = lerp(current_width, target_width, delta * lerp_speed)
	size.x = current_width
