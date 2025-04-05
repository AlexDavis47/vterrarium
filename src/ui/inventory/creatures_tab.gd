extends VBoxContainer


@export var creature_capacity_label: Label

func _ready():
	CreatureFactory.creature_added.connect(_on_creature_added)
	CreatureFactory.creature_removed.connect(_on_creature_removed)
	# Connect to the final calculated value change signal
	if SaveManager and SaveManager.save_file and SaveManager.save_file.tank_capacity:
		SaveManager.save_file.tank_capacity.modified_value_changed.connect(_on_tank_capacity_value_changed)
	else:
		push_warning("CreaturesTab: Could not connect to tank_capacity.modified_value_changed on ready.")
		
	# Initial UI update
	update_ui()


func update_ui():
	_update_creature_capacity()


func _update_creature_capacity():
	# Ensure SaveManager and properties are valid before accessing
	if not SaveManager or not SaveManager.save_file or not SaveManager.save_file.tank_capacity:
		creature_capacity_label.text = "Tank Capacity: Error"
		push_warning("CreaturesTab: Cannot update capacity label - SaveManager or properties invalid.")
		return
		
	var current_creatures = 0
	if CreatureFactory: # Check if CreatureFactory is available
		current_creatures = CreatureFactory.get_number_of_creatures_in_tank()
		
	var capacity = SaveManager.save_file.tank_capacity.modified_value
	creature_capacity_label.text = "Tank Capacity: " + str(current_creatures) + "/" + str(capacity)

func _on_creature_added(_creature: CreatureData):
	update_ui()

func _on_creature_removed(_creature: CreatureData):
	update_ui()

# Renamed handler for the modified_value_changed signal
func _on_tank_capacity_value_changed(_new_value: int, _old_value: int):
	update_ui()
