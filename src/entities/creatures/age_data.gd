@tool
extends Resource
class_name CreatureAgeData

## The age of the creature in seconds since birth
@export var age: FloatWithModifiers = FloatWithModifiers.create(0.0)

## Age bracket constants
enum AgeBracket {
	Baby,
	Adult,
	Old,
	Dead
}

## Get the current age bracket based on age
func get_age_bracket() -> AgeBracket:
	if age.modified_value < 86400:
		return AgeBracket.Baby
	elif age.modified_value < 604800:
		return AgeBracket.Adult
	else:
		return AgeBracket.Old


func get_age() -> float:
	return age.modified_value
