extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)
	
func _on_pressed():
	for creature : CreatureData in Utils.get_all_creatures_in_tank():
		creature.creature_satiation = 0.0
