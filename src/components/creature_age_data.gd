extends Resource
class_name CreatureAgeData

enum AgeCategory {
	Baby,
	Adult,
	Old
}

@export var age: float = 0.0
@export var age_category: AgeCategory = AgeCategory.Baby

func serialize() -> Dictionary:
	return {
		"age": age,
		"age_category": age_category,
	}

func deserialize(data: Dictionary):
	age = data.get("age", 0.0)
	age_category = data.get("age_category", AgeCategory.Baby)
