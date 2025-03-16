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


func _process(_delta: float) -> void:
	text = ""
	var data = creature.creature_data.to_dict()
	for key in data.keys():
		text += key + ": " + str(data[key]) + "\n"
