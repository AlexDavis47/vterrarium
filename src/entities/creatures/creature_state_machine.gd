extends FiniteStateMachine
class_name CreatureStateMachine

var creature: Creature:
	set(value):
		creature = value
		_pass_creature_to_children()
	get:
		return creature

func _ready():
	super ()
	if creature == null:
		if get_parent() is Creature:
			creature = get_parent() as Creature
			_pass_creature_to_children()
		else:
			push_error("CreatureStateMachine must be a child of a Creature")

func _pass_creature_to_children():
	for child in get_children():
		if child is CreatureState:
			child.creature = creature
