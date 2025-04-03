extends VBoxContainer
class_name MenuButtons

@export var inventory_button: TextureButton
@export var feeding_button: TextureButton
@export var store_button: TextureButton

# Make sure only one button can be pressed at a time.
func _ready():
	inventory_button.pressed.connect(_on_inventory_button_pressed)
	feeding_button.pressed.connect(_on_feeding_button_pressed)
	store_button.pressed.connect(_on_store_button_pressed)
	
	# Connect to TopUI signals
	VTGlobal.top_ui.menu_opened.connect(_on_menu_opened)
	VTGlobal.top_ui.menu_closed.connect(_on_menu_closed)

func _on_inventory_button_pressed():
	VTGlobal.top_ui.open_inventory_menu()
	AudioManager.play_sfx(AudioManager.SFX.UI_CLICK_1, 0.8, 1.2)

func _on_feeding_button_pressed():
	VTGlobal.top_ui.open_feeding_menu()
	AudioManager.play_sfx(AudioManager.SFX.UI_CLICK_1, 0.8, 1.2)

func _on_store_button_pressed():
	VTGlobal.top_ui.open_store_menu()
	AudioManager.play_sfx(AudioManager.SFX.UI_CLICK_1, 0.8, 1.2)

func _on_menu_opened(menu_name: String):
	# Reset all buttons first
	inventory_button.button_pressed = false
	feeding_button.button_pressed = false
	store_button.button_pressed = false
	
	# Then set the correct one
	match menu_name:
		"inventory": inventory_button.button_pressed = true
		"feeding": feeding_button.button_pressed = true
		"store": store_button.button_pressed = true

func _on_menu_closed():
	inventory_button.button_pressed = false
	feeding_button.button_pressed = false
	store_button.button_pressed = false
