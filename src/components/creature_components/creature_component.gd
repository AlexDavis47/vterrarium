## Base class for all creature components.
## 
## CreatureComponent provides a foundation for building modular creature behaviors and attributes.
## It handles common tasks like stat modification, property management, and signal handling,
## allowing derived components to focus on their specific functionality.
extends Node
class_name CreatureComponent

## The creature that the component belongs to.
@export var creature: Creature

func _ready() -> void:
	if not creature:
		if get_parent() is Creature:
			creature = get_parent() as Creature
		else:
			push_error("CreatureComponent must be a child of a Creature node")
