extends VBoxContainer


@export var creature_capacity_label: Label

@export var creature_sorting_type: OptionButton
@export var creature_sorting_direction: CheckButton


func _ready():
	CreatureFactory.creature_added.connect(_on_creature_added)
	CreatureFactory.creature_removed.connect(_on_creature_removed)
	_populate_sorting_options()
	_setup_signals()
	update_ui()


func update_ui():
	_update_creature_capacity()


func _update_creature_capacity():
	creature_capacity_label.text = "Tank Capacity: " + str(CreatureFactory.get_number_of_creatures_in_tank()) + "/" + str(SaveManager.save_file.tank_capacity)

func _on_creature_added(_creature: CreatureData):
	update_ui()

func _on_creature_removed(_creature: CreatureData):
	update_ui()

func _populate_sorting_options() -> void:
	creature_sorting_type.clear()
	
	creature_sorting_type.add_item("Name", Utils.CreatureSortType.NAME)
	creature_sorting_type.add_item("Age", Utils.CreatureSortType.AGE)
	creature_sorting_type.add_item("Happiness", Utils.CreatureSortType.HAPPINESS)
	creature_sorting_type.add_item("Value", Utils.CreatureSortType.VALUE)
	creature_sorting_type.add_item("Species", Utils.CreatureSortType.SPECIES)
	creature_sorting_type.add_item("Rarity", Utils.CreatureSortType.RARITY)
	creature_sorting_type.add_item("Hunger", Utils.CreatureSortType.HUNGER)
	
	creature_sorting_type.select(0) # Default to sorting by name
	
	# Configure the direction toggle - checked = descending, unchecked = ascending
	creature_sorting_direction.text = "Descending"
	creature_sorting_direction.button_pressed = false # Default to ascending

func _setup_signals() -> void:
	creature_sorting_type.item_selected.connect(_on_sorting_changed)
	creature_sorting_direction.toggled.connect(_on_direction_changed)
	VTGlobal.trigger_inventory_refresh.connect(_on_inventory_refresh)
	
func _on_sorting_changed(_index: int) -> void:
	VTGlobal.trigger_inventory_refresh.emit()
	
func _on_direction_changed(_button_pressed: bool) -> void:
	VTGlobal.trigger_inventory_refresh.emit()
	
func get_current_sort_type() -> int:
	return creature_sorting_type.get_selected_id()
	
func get_current_sort_direction() -> int:
	return Utils.SortDirection.DESCENDING if creature_sorting_direction.button_pressed else Utils.SortDirection.ASCENDING

func _on_inventory_refresh() -> void:
	update_ui()
