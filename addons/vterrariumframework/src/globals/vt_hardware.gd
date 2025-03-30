extends Node

########################################################
# Constants
########################################################

## Time in seconds to average brightness over
const BRIGHTNESS_AVERAGE_TIME = 5.0
## Time in seconds to average temperature over
const TEMPERATURE_AVERAGE_TIME = 25.0
## Time in seconds to average humidity over
const HUMIDITY_AVERAGE_TIME = 25.0
## The maximum value the photodiode can read
const ADC_MAX_VALUE = 1023
## The minimum brightness value, aka the darkest value the photodiode can read
const BRIGHTNESS_MIN_THRESHOLD = 0.01
## The maximum brightness value, aka the brightest value the photodiode can read
const BRIGHTNESS_MAX_THRESHOLD = 0.05

########################################################
# Signals
########################################################

## Emitted when the brightness value changes
signal brightness_changed(new_brightness: float)
## Emitted when the temperature value changes
signal temperature_changed(new_temperature: float)
## Emitted when the humidity value changes
signal humidity_changed(new_humidity: float)
## Emitted when the photodiode reading changes
signal photodiode_changed(raw_value: int, normalized_value: float)

########################################################
# Properties
########################################################

## The brightness of the hardware (0.0 to 1.0)
var brightness: float = 0.5:
	set(value):
		brightness = clamp(value, 0.0, 1.0)
		brightness_changed.emit(brightness)
	get:
		return brightness

## The temperature of the hardware in Celsius
var temperature: float = 25.0:
	set(value):
		temperature = value
		temperature_changed.emit(temperature)
	get:
		return temperature

## The humidity of the hardware in percentage (0-100%)
var humidity: float = 50.0:
	set(value):
		humidity = clamp(value, 0.0, 100.0)
		humidity_changed.emit(humidity)
	get:
		return humidity

########################################################
# Private Variables
########################################################

## The curve that the photodiode value will be mapped to
var _brightness_response_curve: Curve = preload("uid://ec86vlxi4w6d")

## Raw photodiode value from Arduino
var photodiode_raw: int = 0
## Normalized photodiode value (0.0 to 1.0)
var photodiode_normalized: float = 0.0
## Pre-curve photodiode value
var photodiode_normalized_pre_curve: float = 0.0

## Current simulation time
var current_time: float = 0.0

## Brightness history for averaging
var brightness_history: Array[float] = []
var brightness_history_times: Array[float] = []

## Temperature history for averaging
var temperature_history: Array[float] = []
var temperature_history_times: Array[float] = []

## Humidity history for averaging
var humidity_history: Array[float] = []
var humidity_history_times: Array[float] = []

## Reference to the VTArduino autoload
var arduino = null

########################################################
# Initialization
########################################################

func _ready():
	_initialize_arduino()

## Try to get the VTArduino autoload node
func _initialize_arduino():
	if has_node("/root/VTArduino"):
		arduino = get_node("/root/VTArduino")
		print("VTHardware: Arduino autoload found")
	else:
		print("VTHardware: Arduino autoload NOT found")

########################################################
# Process
########################################################

func _process(delta):
	current_time += delta
	
	if arduino != null and arduino.IsConnected():
		_update_photodiode_values()
		_update_temperature_values()
		_update_humidity_values()
		
		# Debug output
		_print_debug_values()

########################################################
# Sensor Update Methods
########################################################

## Updates photodiode values from Arduino and calculates brightness
func _update_photodiode_values():
	# Get raw photodiode value
	var new_raw = arduino.GetPhotodiodeValue()
	
	# Calculate normalized value (assuming 10-bit ADC: 0-1023)
	var new_normalized = float(new_raw) / ADC_MAX_VALUE
	
	# Store the pre-curve value
	photodiode_normalized_pre_curve = new_normalized

	# Apply the brightness response curve if available
	if _brightness_response_curve:
		# Map the raw value through our response curve
		new_normalized = _brightness_response_curve.sample(new_normalized)
	else:
		# Fallback to linear mapping with min/max thresholds
		new_normalized = (new_normalized - BRIGHTNESS_MIN_THRESHOLD) / (BRIGHTNESS_MAX_THRESHOLD - BRIGHTNESS_MIN_THRESHOLD)

	# Clamp the normalized value between 0 and 1
	new_normalized = clamp(new_normalized, 0.0, 1.0)

	photodiode_raw = new_raw
	photodiode_normalized = new_normalized
	
	# Add to brightness history for averaging
	brightness_history.append(new_normalized)
	brightness_history_times.append(current_time)
	
	# Calculate and update brightness
	_update_averaged_value(
		brightness_history,
		brightness_history_times,
		BRIGHTNESS_AVERAGE_TIME,
		func(avg): brightness = avg
	)
	
	# Emit signal for photodiode changes
	photodiode_changed.emit(photodiode_raw, photodiode_normalized)

## Updates temperature values from Arduino
func _update_temperature_values():
	# Get temperature from Arduino
	var new_temp = arduino.GetTemperature()
	
	# Add to temperature history
	temperature_history.append(new_temp)
	temperature_history_times.append(current_time)
	
	# Calculate and update temperature
	_update_averaged_value(
		temperature_history,
		temperature_history_times,
		TEMPERATURE_AVERAGE_TIME,
		func(avg): temperature = avg
	)

## Updates humidity values from Arduino
func _update_humidity_values():
	# Get humidity from Arduino
	var new_humidity = arduino.GetHumidity()
	
	# Add to humidity history
	humidity_history.append(new_humidity)
	humidity_history_times.append(current_time)
	
	# Calculate and update humidity
	_update_averaged_value(
		humidity_history,
		humidity_history_times,
		HUMIDITY_AVERAGE_TIME,
		func(avg): humidity = avg
	)

########################################################
# Helper Methods
########################################################

## Generic method to update an averaged value
## 
## Updates a value based on its history, removing old entries outside the time window
## and calculating the average of remaining entries.
##
## Parameters:
## - history: The array of historical values
## - times: The array of timestamps for each value
## - average_time: The time window to consider for averaging
## - set_func: A callback function to set the final averaged value
func _update_averaged_value(history: Array, times: Array, average_time: float, set_func: Callable):
	# Remove old values outside the averaging window
	while times.size() > 0 and current_time - times[0] > average_time:
		history.pop_front()
		times.pop_front()
	
	# Calculate average value
	var avg_value = 0.0
	if history.size() > 0:
		for value in history:
			avg_value += value
		avg_value /= history.size()
	
	# Update value using the provided callback
	set_func.call(avg_value)


## Prints debug information about current sensor values
func _print_debug_values():
	return
	print("VTHardware: Brightness: ", brightness, " Temperature: ", temperature, " Humidity: ", humidity)
	print("VTHardware: Photodiode: ", photodiode_raw, " Normalized: ", photodiode_normalized)
