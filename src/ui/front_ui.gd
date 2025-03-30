extends Control
class_name FrontUI

## The delay in seconds before the UI becomes transparent
const SLEEP_DELAY: float = 30.0
## The duration of the sleep animation
const SLEEP_ANIMATION_DURATION: float = 0.5
## The duration of the happiness lerp animation
const HAPPINESS_LERP_DURATION: float = 0.5

@export var happiness_percentage_label: Label
@export var money_label: Label
@export var time_label: Label

@export var temp_test_label: Label

@export var brightness_curve_visualizer: CurveVisualizerUI

var _sleep_counter: float = 0.0
var _is_sleeping: bool = false
var _original_modulate: Color
var _current_happiness_percentage: float = 0.0
var _target_happiness_percentage: float = 0.0
var _happiness_lerp_t: float = 0.0

func _ready():
	_update_time()
	_update_money()
	_update_happiness_percentage()
	_original_modulate = modulate
	VTInput.top_window_input.connect(_on_top_window_input)
	brightness_curve_visualizer.curve = VTHardware._brightness_response_curve

## Updates the brightness curve visualizer
func _update_brightness_curve_visualizer():
	brightness_curve_visualizer.current_value = VTHardware.brightness

func _process(delta):
	_update_time()
	_update_money()
	_update_happiness_percentage()
	_update_brightness_curve_visualizer()
	temp_test_label.text = str(Utils.celsius_to_fahrenheit(VTHardware.temperature))
	
	# Lerp the happiness percentage
	if _current_happiness_percentage != _target_happiness_percentage:
		_happiness_lerp_t += delta / HAPPINESS_LERP_DURATION
		if _happiness_lerp_t >= 1.0:
			_happiness_lerp_t = 1.0
			_current_happiness_percentage = _target_happiness_percentage
		else:
			_current_happiness_percentage = lerp(_current_happiness_percentage, _target_happiness_percentage, _happiness_lerp_t)
		
		# Update the label with the lerped value
		var happiness_display = int(round(_current_happiness_percentage * 100))
		happiness_percentage_label.text = str(happiness_display) + "%"
	
	if Utils.all_menus_closed:
		_sleep_counter += delta
	if _sleep_counter >= SLEEP_DELAY and not _is_sleeping:
		_sleep()

func _on_top_window_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_wake_up()

func _sleep() -> void:
	_is_sleeping = true
	_sleep_counter = 0.0
	
	# Create a tween to animate the transparency
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	var transparent_color = _original_modulate
	transparent_color.a = 0.2 # 20% opacity
	tween.tween_property(self, "modulate", transparent_color, SLEEP_ANIMATION_DURATION)

func _wake_up() -> void:
	if not _is_sleeping:
		return
		
	_is_sleeping = false
	_sleep_counter = 0.0
	
	# Create a tween to animate back to full opacity
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", _original_modulate, SLEEP_ANIMATION_DURATION)

# In format: 12:00 AM
func _update_time():
	var datetime = Time.get_datetime_dict_from_system()
	var hour = datetime.hour
	var minute = datetime.minute
	var am_pm = "AM"
	
	if hour >= 12:
		am_pm = "PM"
		if hour > 12:
			hour -= 12
	elif hour == 0:
		hour = 12
	
	var time_string = "%d:%02d %s" % [hour, minute, am_pm]
	time_label.text = time_string

func _update_money():
	money_label.text = Utils.convert_long_float_to_string(SaveManager.save_file.money)

func _update_happiness_percentage():
	_target_happiness_percentage = Utils.get_total_creature_happiness_percentage()
	if _current_happiness_percentage == 0 and _happiness_lerp_t == 0:
		# Initialize on first call
		_current_happiness_percentage = _target_happiness_percentage
		var happiness_display = int(round(_current_happiness_percentage * 100))
		happiness_percentage_label.text = str(happiness_display) + "%"
	elif abs(_target_happiness_percentage - _current_happiness_percentage) > 0.001:
		# Reset lerp when target changes significantly
		_happiness_lerp_t = 0.0
