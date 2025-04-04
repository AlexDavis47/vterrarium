extends VBoxContainer


@export var creature_capacity_label: Label

func _ready():
	CreatureFactory.creature_added.connect(_on_creature_added)
	CreatureFactory.creature_removed.connect(_on_creature_removed)
	update_ui()


func update_ui():
	_update_creature_capacity()


func _update_creature_capacity():
	creature_capacity_label.text = "Tank Capacity: " + str(CreatureFactory.get_number_of_creatures_in_tank()) + "/" + str(SaveManager.save_file.tank_capacity)

func _on_creature_added(creature: CreatureData):
	update_ui()

func _on_creature_removed(creature: CreatureData):
	update_ui()
