extends Control

var inventory_scene: PackedScene = preload("uid://bda2an2nm10ol")
var shop_scene: PackedScene = preload("uid://b2vp764bh2bre")
var clean_scene: PackedScene = preload("uid://h87keo8yxa01")
var feed_scene: PackedScene = preload("uid://dk2hur3xscydf")

@export var inventory_button: Button
@export var feed_button: Button
@export var clean_button: Button
@export var shop_button: Button
@export var money_label: Label

const SLEEP_TIMEOUT: float = 5.0  # Time in seconds before the screen sleeps

var _inactivity_timer: float = 0.0
var _is_awake: bool = true

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

func _ready() -> void:
	inventory_button.pressed.connect(open_inventory)
	shop_button.pressed.connect(open_shop)
	clean_button.pressed.connect(open_clean)
	feed_button.pressed.connect(open_feed)
	_reset_timer()


func _physics_process(delta):
	var money_string = "Money: " + str(int(SaveManager.save_file.money))
	money_label.text = money_string


func open_inventory() -> void:
	var inventory_instance = inventory_scene.instantiate()
	inventory_instance.inventory_closed.connect(_on_inventory_closed)
	VTGlobal.top_window.add_child(inventory_instance)
	hide()
	
func _on_inventory_closed() -> void:
	show()

func open_shop() -> void:
	var shop_instance = shop_scene.instantiate()
	shop_instance.shop_closed.connect(_on_shop_closed)
	VTGlobal.top_window.add_child(shop_instance)
	hide()

func _on_shop_closed() -> void:
	show()
	
func open_clean() -> void:
	var clean_instance = clean_scene.instantiate()
	clean_instance.clean_closed.connect(_on_clean_closed)
	VTGlobal.top_window.add_child(clean_instance)
	hide()
	
func _on_clean_closed() -> void:
	show()

func open_feed() -> void:
	var feed_instance = feed_scene.instantiate()
	feed_instance.feed_closed.connect(_on_feed_closed)
	VTGlobal.top_window.add_child(feed_instance)
	hide()
	
func _on_feed_closed() -> void:
	show()
