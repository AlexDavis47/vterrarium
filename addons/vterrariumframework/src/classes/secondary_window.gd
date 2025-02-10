extends Window
class_name SecondaryWindow

var window : Window

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	window = self
	VTGlobal.secondary_window = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
