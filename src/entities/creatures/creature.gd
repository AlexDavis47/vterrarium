extends CharacterBody3D
class_name Creature

## The creature data resource that contains all the common and savable data for the creature.
## We separate this data so that we can save and load creature data easily.
## When we remove a creature, we can just save the creature data and not the entire creature node.
## And when we load a creature, we can just load the saved data back into a new creature instance.
@export var creature_data: CreatureData


func _physics_process(delta: float) -> void:
	creature_data.creature_age.base_value += delta
