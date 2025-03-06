extends Node3D


@export var parent_creature: Creature
var test_modifier_value: float = 1.0

func _ready():
	parent_creature.creature_data.creature_happiness.add_modifier(
		"test",
		test_modifier_value,
		parent_creature.creature_data.creature_happiness.MODIFIER_MULTIPLY,
		0
	)
	parent_creature.creature_data.creature_happiness.modifier_on("test")


func _process(delta: float) -> void:
	test_modifier_value -= delta * 0.001
	parent_creature.creature_data.creature_happiness.set_modifier("test", test_modifier_value)
