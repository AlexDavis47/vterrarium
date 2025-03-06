@tool
extends Label3D
class_name CreatureDebugLabel

@export var creature: Creature

func _ready():
	no_depth_test = true
	billboard = BaseMaterial3D.BILLBOARD_ENABLED


func _process(delta: float) -> void:
	text = ""
	var creature_name = creature.creature_data.creature_name
	text += creature_name + "\n"
	text += "Happiness: " + str(creature.creature_data.creature_happiness.modified_value) + "\n"
	text += "Age: " + str(creature.creature_data.creature_age) + "\n"
	text += "Money Rate: " + str(creature.creature_data.creature_money_rate) + "\n"
	text += "Speed: " + str(creature.creature_data.creature_speed) + "\n"
	text += "Happiness: " + str(creature.creature_data.creature_happiness.modified_value) + "\n"
