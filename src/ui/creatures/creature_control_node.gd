extends Panel
class_name UICreatureControlNode

@export var creature_data: CreatureData:
	set(value):
		creature_data = value

@export var creature_name: Label
@export var creature_preview: TextureRect
@export var remove_from_tank_button: Button

signal creature_removed_from_tank(creature_data: CreatureData)

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_filter = Control.MOUSE_FILTER_STOP
	if creature_data:
		update_info()
	remove_from_tank_button.pressed.connect(_on_remove_from_tank_pressed)
	VTGlobal.top_window.window_input.connect(_on_window_input)
	

func _on_window_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var local_event = make_input_local(event)
		if !Rect2(Vector2.ZERO, size).has_point(local_event.position):
			queue_free()

func update_info() -> void:
	creature_name.text = creature_data.creature_name
	creature_preview.texture = creature_data.creature_image

func _on_remove_from_tank_pressed() -> void:
	CreatureFactory.remove_creature(creature_data.creature_instance)
	creature_removed_from_tank.emit(creature_data)
