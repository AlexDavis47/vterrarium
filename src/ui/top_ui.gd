extends Control
class_name TopUI

## The delay in seconds between the menu will minimize itself
const SLEEP_DELAY: float = 10.0
## The duration of the sleep animation
const SLEEP_ANIMATION_DURATION: float = 0.5

signal menu_opened(menu_name: String)
signal menu_closed()

var inventory_scene: PackedScene = preload("uid://bda2an2nm10ol")
var feeding_scene: PackedScene = preload("uid://bda2an2nm10ol")
var store_scene: PackedScene = preload("uid://bda2an2nm10ol")

@export var menu_buttons: MenuButtons

var current_menu: Control = null
var current_menu_name: String = ""

var _sleep_counter: float = 0.0
var _is_sleeping: bool = false
var _original_position: Vector2 = Vector2.ZERO

func _init() -> void:
	VTGlobal.top_ui = self

func _ready() -> void:
	_original_position = menu_buttons.position
	VTInput.top_window_input.connect(_on_top_window_input)

func _process(delta: float) -> void:
	if Utils.all_menus_closed:
		_sleep_counter += delta
	if _sleep_counter >= SLEEP_DELAY and not _is_sleeping:
		_sleep()
	

func _on_top_window_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_wake_up()


func _sleep() -> void:
	close_all_menus()
	_is_sleeping = true
	_sleep_counter = 0.0
	
	# Store original position if not already stored
	if _original_position == Vector2.ZERO:
		_original_position = menu_buttons.position
	
	# Create a tween to animate the menu buttons sliding off screen
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	var target_position = Vector2(_original_position.x + menu_buttons.size.x, _original_position.y)
	tween.tween_property(menu_buttons, "position", target_position, SLEEP_ANIMATION_DURATION)

func _wake_up() -> void:
	if not _is_sleeping:
		return
		
	_is_sleeping = false
	_sleep_counter = 0.0
	
	# Create a tween to animate the menu buttons sliding back on screen
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(menu_buttons, "position", _original_position, SLEEP_ANIMATION_DURATION)

func open_inventory_menu():
	_wake_up()
	if current_menu_name == "inventory":
		close_all_menus()
	else:
		_open_menu(inventory_scene, "inventory")

func open_feeding_menu():
	_wake_up()
	if current_menu_name == "feeding":
		close_all_menus()
	else:
		_open_menu(feeding_scene, "feeding")

func open_store_menu():
	_wake_up()
	if current_menu_name == "store":
		close_all_menus()
	else:
		_open_menu(store_scene, "store")

func close_all_menus():
	if current_menu != null:
		current_menu.queue_free()
	current_menu = null
	current_menu_name = ""
	menu_closed.emit()
	Utils.all_menus_closed = true

func _open_menu(menu: PackedScene, menu_name: String):
	if current_menu != null:
		current_menu.queue_free()
	current_menu = menu.instantiate()
	current_menu_name = menu_name
	add_child(current_menu)
	menu_opened.emit(menu_name)
	Utils.all_menus_closed = false
