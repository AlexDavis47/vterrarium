## This creature class represents the instanced version of a creature data resource
## The creature data resource itself is the "real" creature, and this class is just the thing that shows up in the tank.
extends CharacterBody3D
class_name Creature

signal started_starving
signal stopped_starving

var is_starving: bool = false


@export var creature_data: CreatureData

func _ready():
	add_to_group("creatures")


func _physics_process(delta: float) -> void:
	_process_hunger(delta)

## Process the hunger of the creature every physics frame
func _process_hunger(delta: float) -> void:
	creature_data.satiation -= creature_data.hunger_rate * (delta / 3600.0)
	if creature_data.satiation <= 0.0:
		if not is_starving:
			is_starving = true
			started_starving.emit()
	else:
		if is_starving:
			is_starving = false
			stopped_starving.emit()
