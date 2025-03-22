## This creature class represents the instanced version of a creature data resource
## The creature data resource itself is the "real" creature, and this class is just the thing that shows up in the tank.
extends CharacterBody3D
class_name Creature

signal started_starving
signal stopped_starving

var is_starving: bool = false


@export var creature_mesh: MeshInstance3D
var creature_data: CreatureData

func _ready():
	creature_mesh.mesh = creature_data.creature_mesh
	add_to_group("creatures")
	collision_layer = 0
	set_collision_layer_value(2, true)
	global_position = creature_data.creature_position
	scale = Vector3(creature_data.creature_size, creature_data.creature_size, creature_data.creature_size)


func _physics_process(delta: float) -> void:
	_process_hunger(delta)
	_process_position_data(delta)
	_process_money(delta)

## Process the hunger of the creature every physics frame
func _process_hunger(delta: float) -> void:
	creature_data.creature_satiation -= creature_data.creature_hunger_rate * (delta / 3600.0)
	if creature_data.creature_satiation <= 0.0:
		if not is_starving:
			is_starving = true
			started_starving.emit()
	else:
		if is_starving:
			is_starving = false
			stopped_starving.emit()


func _process_position_data(delta: float) -> void:
	creature_data.creature_position = global_position

func _process_money(delta: float) -> void:
	SaveManager.save_file.money += creature_data.creature_money_per_hour * delta
