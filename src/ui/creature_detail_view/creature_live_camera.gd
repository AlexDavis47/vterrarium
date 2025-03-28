extends Camera3D
class_name CreatureLiveCamera

@export var creature_data: CreatureData

var creature_instance: Creature

func _ready() -> void:
	if creature_data and creature_data.creature_is_in_tank:
		creature_instance = creature_data.creature_instance

func _process(delta: float) -> void:
	if creature_data and creature_data.creature_is_in_tank:
		if creature_instance:
			# Calculate camera position based on creature's rotation
			var offset = Vector3(0, 0.5, 0.5).rotated(Vector3.UP, creature_instance.rotation.y)
			offset = offset.rotated(Vector3.UP, 60)
			look_at_from_position(creature_instance.global_position + offset, creature_instance.global_position, Vector3.UP)
			global_position += Vector3(0, 0.3, 0)
		else:
			creature_instance = creature_data.creature_instance
