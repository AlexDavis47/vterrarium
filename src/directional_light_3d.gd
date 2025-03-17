extends DirectionalLight3D


func _ready():
	VTHardware.brightness_changed.connect(process_arduino_light)

func process_arduino_light(new_brightness: float):
	var brightness = 1 * new_brightness
	self.light_energy = brightness
