extends TextureButton

var debug_menu_scene: PackedScene = preload("uid://dk08klp38nyv6")
var debug_menu: Control = null

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	debug_menu = debug_menu_scene.instantiate()
	VTGlobal.front_window.add_child(debug_menu)
	debug_menu.closed.connect(_on_debug_menu_closed)
	self.visible = false
	AudioManager.play_sfx(AudioManager.SFX.POP_2, 0.8, 1.2)

func _on_debug_menu_closed() -> void:
	self.visible = true
	debug_menu = null
