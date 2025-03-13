extends Control

@export var menu_scene: PackedScene = preload("res://src/entities/test_entities/open_menu.tscn")

const SLEEP_TIMEOUT: float = 5.0  # Time in seconds before the screen sleeps

var _inactivity_timer: float = 0.0
var _is_awake: bool = true

func _ready() -> void:
	_reset_timer()

func _process(delta: float) -> void:
	if _is_awake:
		_inactivity_timer += delta
		if _inactivity_timer >= SLEEP_TIMEOUT:
			sleep_screen()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_reset_timer()
			if not _is_awake:
				wake_screen()

func _reset_timer() -> void:
	_inactivity_timer = 0.0

func sleep_screen() -> void:
	_is_awake = false
	print("Screen is now sleeping.")
	self.visible = false

func wake_screen() -> void:
	_is_awake = true
	_reset_timer()
	print("Screen is now awake!")
	self.visible = true

func _on_menu_pressed() -> void:
	var menu_instance = menu_scene.instantiate()
	add_child(menu_instance)
	menu_instance.show()
