extends FiniteStateMachine
class_name CreatureStateMachine

@export var creature: Creature:
	set(value):
		creature = value
	get:
		return creature
		
func _ready():
	super._ready()
	if creature == null:
		if get_parent() is Creature:
			creature = get_parent() as Creature
			_pass_creature_to_children()
		else:
			push_error("CreatureStateMachine must be a child of a Creature")
	_pass_creature_to_children()

func _pass_creature_to_children():
	for child in get_children():
		if child is CreatureState:
			child.creature = creature
