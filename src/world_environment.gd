@tool
extends WorldEnvironment

@export var brightness_curve: Curve

@export var brightness_color_gradient: GradientTexture1D

@export var directional_light1: DirectionalLight3D

@export var directional_light2: DirectionalLight3D

## Overrides the brightness value for testing
@export var test_brightness: float = 0.0

@export var fog_density_curve: Curve

@export var fog_color_gradient: GradientTexture1D
## The current brightness value
var current_brightness: float = 0.0

func _process(delta):
	# Get current brightness from VTHardware
	var hardware = get_node("/root/VTHardware")
	if not hardware:
		return
		
	# If we are testing, use the test brightness value
	if test_brightness > 0.0:
		current_brightness = test_brightness
	else:
		current_brightness = hardware.brightness
	
	# Apply brightness curve to get the light energy
	var light_energy = brightness_curve.sample(current_brightness)
	
	# Apply brightness color gradient to get the light color
	var light_color = brightness_color_gradient.get_gradient().sample(current_brightness)
	
	# Update the environment ambient light
	environment.ambient_light_energy = light_energy
	environment.ambient_light_color = light_color

	# Update the directional lights
	directional_light1.light_energy = light_energy
	directional_light2.light_energy = light_energy
	directional_light1.light_color = light_color
	directional_light2.light_color = light_color


	# Update the fog
	var fog_density = fog_density_curve.sample(current_brightness)
	var fog_color = fog_color_gradient.get_gradient().sample(current_brightness)
	environment.fog_density = fog_density
	environment.fog_light_color = fog_color
