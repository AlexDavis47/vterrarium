extends Panel
class_name UICreatureControlNode

var creature_data: CreatureData
@export var creature: Creature
@export var creature_name: Label
@export var creature_preview: TextureRect
@export var remove_from_tank_button: Button

var _detailed_view_visible := false
var _creature_detector: Control

func _ready() -> void:
	focus_mode = Control.FOCUS_CLICK
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Start completely hidden
	visible = false

	creature = get_parent() as Creature
	creature_data = creature.creature_data

	focus_exited.connect(_on_focus_exited)
	
	# Create detector control node
	_creature_detector = Control.new()
	_creature_detector.mouse_filter = Control.MOUSE_FILTER_STOP
	_creature_detector.size = Vector2(50, 50)
	_creature_detector.gui_input.connect(_on_detector_input)
	if !VTGlobal.windows_setup_completed:
		await VTGlobal.windows_initialized
	VTGlobal.top_window.add_child(_creature_detector)
	
	if creature_data:
		update_info()
	
	remove_from_tank_button.pressed.connect(_on_remove_from_tank_pressed)
	if !VTGlobal.windows_setup_completed:
		await VTGlobal.windows_initialized
	VTGlobal.top_window.window_input.connect(_on_window_input)

func _physics_process(delta) -> void:
	if creature:
		# Update the detector position to follow the creature
		var creature_position: Vector2 = VTGlobal.top_camera.unproject_position(creature.global_position)
		
		# Position the detector control
		_creature_detector.position = creature_position - _creature_detector.size / 2
		
		# If the detailed view is visible, position it next to the creature
		if _detailed_view_visible:
			position.x = creature_position.x - size.x / 2
			position.y = creature_position.y - size.y / 2

func _on_detector_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed and not _detailed_view_visible:
		_show_detailed_view()

func _on_window_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed and _detailed_view_visible:
		# Check if touch is outside the detailed view panel
		var panel_rect = Rect2(position, size)
		if not panel_rect.has_point(event.position):
			_hide_detailed_view()

func _show_detailed_view() -> void:
	_detailed_view_visible = true
	visible = true

	# We need to update once or else the position will not be set initially
	_physics_process(0.0)
	
	if creature and creature.creature_data:
		creature_data = creature.creature_data
		update_info()

func _hide_detailed_view() -> void:
	_detailed_view_visible = false
	visible = false

func update_info() -> void:
	creature_name.text = creature_data.creature_name
	creature_preview.texture = creature_data.creature_image

func _on_remove_from_tank_pressed() -> void:
	_hide_detailed_view()
	CreatureFactory.remove_creature(creature_data.creature_instance)

func _on_focus_exited() -> void:
	_hide_detailed_view()
