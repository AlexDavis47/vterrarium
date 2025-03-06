@tool
extends Label3D
class_name CreatureDebugLabel

@export var creature: Creature

func _ready():
	no_depth_test = true
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	Config.debug_mode_changed.connect(_on_debug_mode_changed)
	_on_debug_mode_changed(Config.debug_mode)


func _on_debug_mode_changed(new_value: bool) -> void:
	if new_value:
		visible = true
	else:
		visible = false


func _process(delta: float) -> void:
	text = ""
	var creature_name = creature.creature_data.creature_name
	text += creature_name + "\n"
	text += "Happiness: " + str(creature.creature_data.creature_happiness.modified_value) + "\n"
	text += "Age: " + str(creature.creature_data.creature_age.modified_value) + "\n"
	text += "Money Rate: " + str(creature.creature_data.creature_money_rate.modified_value) + "\n"
	text += "Speed: " + str(creature.creature_data.creature_speed.modified_value) + "\n"
	for child in creature.get_children():
		if child is CreatureHungerComponent:
			text += "Satiation" + ": " + str(child.satiation) + "\n"
