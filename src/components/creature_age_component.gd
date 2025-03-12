extends CreatureComponent
class_name CreatureAgeComponent

var parent_creature: Creature
var component_name: String = "Creature Age Component"

signal age_category_changed(old_age_category: int, new_age_category: int)

@export var creature_age_data: CreatureAgeData

func _ready():
	parent_creature = get_parent()
	if not parent_creature:
		push_error("CreatureAgeComponent: Parent creature not found")

func _physics_process(delta):
	_process_age(delta)

## Increases the age of the creature by the delta time
## Called every physics frame
func _process_age(delta: float):
	creature_age_data.age += delta
	# Check if the age category has changed
	var old_age_category = creature_age_data.age_category
	var new_age_category = get_age_category()
	
	if new_age_category != old_age_category:
		creature_age_data.age_category = new_age_category
		emit_signal("age_category_changed", old_age_category, new_age_category)

## 0 - 24 Hours is baby, 24 - 128 Hours is adult, 128 - 256 Hours is old
func get_age_category() -> int:
	if creature_age_data.age < 24 * 3600:
		return CreatureAgeData.AgeCategory.Baby
	elif creature_age_data.age < 128 * 3600:
		return CreatureAgeData.AgeCategory.Adult
	else:
		return CreatureAgeData.AgeCategory.Old

## Called by the creature when it is serialized
func serialize() -> Dictionary:
	return creature_age_data.serialize()

## Called by the creature when it is deserialized
func deserialize(data: Dictionary):
	creature_age_data.deserialize(data)
