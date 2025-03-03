extends Node

# Simulation sensitivity settings
const MOUSE_ROTATION_SENSITIVITY = 0.1
const KEY_ACCELERATION_SENSITIVITY = 0.5

# Signals
signal brightness_changed(new_brightness: float)
signal temperature_changed(new_temperature: float)
signal gyro_rotation_changed(new_gyro_rotation: Vector3)
signal gyro_acceleration_changed(new_gyro_acceleration: Vector3)
signal gyro_rotation_delta_changed(new_gyro_rotation_delta: Vector3)
signal photodiode_changed(raw_value: int, normalized_value: float)

# The brightness of the hardware. 
var brightness: float = 0.0:
	set(value):
		brightness = value
		brightness_changed.emit(brightness)
	get:
		return brightness

# The temperature of the hardware, in degrees Celsius
var temperature: float = 0.0:
	set(value):
		temperature = value
		temperature_changed.emit(temperature)
	get:
		return temperature

var gyro_rotation: Vector3 = Vector3.ZERO:
	set(value):
		gyro_rotation = value
		gyro_rotation_changed.emit(gyro_rotation)
	get:
		return gyro_rotation

var gyro_rotation_delta: Vector3 = Vector3.ZERO:
	set(value):
		gyro_rotation_delta = value
		gyro_rotation_delta_changed.emit(gyro_rotation_delta)
	get:
		return gyro_rotation_delta

var gyro_acceleration: Vector3 = Vector3.ZERO:
	set(value):
		gyro_acceleration = value
		gyro_acceleration_changed.emit(gyro_acceleration)
	get:
		return gyro_acceleration

# Photodiode values from Arduino
var photodiode_raw: int = 0
var photodiode_normalized: float = 0.0

# Reference to the VTArduino autoload
var arduino = null

func _ready():
	# Try to get the VTArduino autoload
	if has_node("/root/VTArduino"):
		arduino = get_node("/root/VTArduino")
		print("VTHardware: Arduino autoload found")
	else:
		print("VTHardware: Arduino autoload NOT found")

func _process(_delta):
	# Update photodiode values from Arduino if available
	if arduino != null:
		if arduino.IsConnected():
			# Get the raw value directly from Arduino
			var new_raw = arduino.GetRawValue()
			
			# Calculate normalized value (assuming 10-bit ADC: 0-1023)
			var new_normalized = float(new_raw) / 1023.0
			
			# Only update if values changed
			if new_raw != photodiode_raw or new_normalized != photodiode_normalized:
				photodiode_raw = new_raw
				photodiode_normalized = new_normalized
				
				# Update brightness for compatibility
				brightness = photodiode_normalized
				
				# Emit signal
				photodiode_changed.emit(photodiode_raw, photodiode_normalized)

# For testing purposes, we process both mouse and keyboard input
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var sim_rotation = _process_sim_mouse(event)
		_process_gyro_rotation(sim_rotation)
	
	# Process keyboard input every frame for smooth acceleration
	_process_sim_keyboard()
	# print("gyro_rotation: ", gyro_rotation)
	# print("gyro_rotation_delta: ", gyro_rotation_delta)
	# print("gyro_acceleration: ", gyro_acceleration)
	# print("temperature: ", temperature)
	# print("brightness: ", brightness)
	# print("--------------------------------")


# Simulates gyroscope rotation using mouse input
func _process_sim_mouse(event: InputEventMouseMotion) -> Vector3:
	# Convert mouse movement to rotation
	# X movement = rotation around Y axis (yaw)
	# Y movement = rotation around X axis (pitch)
	return Vector3(
		deg_to_rad(- event.relative.y * MOUSE_ROTATION_SENSITIVITY),
		deg_to_rad(- event.relative.x * MOUSE_ROTATION_SENSITIVITY),
		0.0 # No roll for now
	)

# Simulates acceleration using keyboard input
func _process_sim_keyboard() -> void:
	var acceleration = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_LEFT):
		acceleration.x -= KEY_ACCELERATION_SENSITIVITY
	if Input.is_key_pressed(KEY_RIGHT):
		acceleration.x += KEY_ACCELERATION_SENSITIVITY
	if Input.is_key_pressed(KEY_UP):
		acceleration.z -= KEY_ACCELERATION_SENSITIVITY
	if Input.is_key_pressed(KEY_DOWN):
		acceleration.z += KEY_ACCELERATION_SENSITIVITY
	
	_process_gyro_acceleration(acceleration)

# Process actual gyro rotation (this would be used in production)
func _process_gyro_rotation(rotation_delta: Vector3) -> void:
	# Update absolute rotation
	gyro_rotation += rotation_delta
	# Store rotation delta
	gyro_rotation_delta = rotation_delta

# Process actual gyro acceleration (this would be used in production)
func _process_gyro_acceleration(acceleration: Vector3) -> void:
	gyro_acceleration = acceleration
