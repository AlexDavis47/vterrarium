extends CreatureComponent
class_name CreatureHungerComponent

var parent_creature: Creature

signal starvation_started()
signal starvation_ended()

var component_name: String = "Hunger Component"

@export var hunger_component_data: HungerComponentData

func _ready():
	parent_creature = get_parent()
	if not parent_creature:
		push_error("HungerComponent: Parent creature not found")

func _physics_process(delta):
	_process_hunger(delta)

## Decreases the satiation of the creature by the hunger rate
## Called every physics frame
func _process_hunger(delta: float):
	hunger_component_data.satiation -= hunger_component_data.hunger_rate * (delta / 3600.0)
	if hunger_component_data.satiation <= 0.0:
		if not hunger_component_data._is_starving:
			emit_signal("starvation_started")
			hunger_component_data._is_starving = true
	else:
		if hunger_component_data._is_starving:
			emit_signal("starvation_ended")
			hunger_component_data._is_starving = false

## Called by the creature when it is serialized
func serialize() -> Dictionary:
	return hunger_component_data.serialize()

## Called by the creature when it is deserialized
func deserialize(data: Dictionary):
	hunger_component_data.deserialize(data)
