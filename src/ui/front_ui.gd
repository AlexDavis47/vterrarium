extends Control
class_name FrontUI

########################################################
# Constants
########################################################

## The delay in seconds before the UI becomes transparent
const SLEEP_DELAY: float = 30.0
## The duration of the sleep animation
const SLEEP_ANIMATION_DURATION: float = 0.5
## The duration of the happiness lerp animation
const HAPPINESS_LERP_DURATION: float = 0.5

########################################################
# Exports
########################################################

## Label to display the overall creature happiness percentage
@export var happiness_percentage_label: Label
## Label to display the current amount of money
@export var money_label: Label
## Label to display the current system time
@export var time_label: Label
## Label to display the calculated money earned per hour
@export var money_per_hour_label: Label

########################################################
# Private Variables
########################################################

var _sleep_counter: float = 0.0
var _is_sleeping: bool = false
var _original_modulate: Color

# Happiness Tweening
var _display_happiness_percentage: float = -1.0 # Value animated by tween
# var _last_target_happiness: float = -1.0 # Removed for simplification
# var _happiness_tween: Tween # Removed for simplification

# Money Tweening
var _display_money: float = -1.0
# var _last_target_money: float = -1.0 # Removed for simplification
# var _money_tween: Tween # Removed for simplification

# Money Per Hour Tweening
var _display_money_per_hour: float = -1.0
# var _last_target_money_per_hour: float = -1.0 # Removed for simplification
# var _money_per_hour_tween: Tween # Removed for simplification

var _process_scheduler: ProcessScheduler = ProcessScheduler.new()

########################################################
# Initialization
########################################################

func _ready() -> void:
	_update_time() # Time doesn't tween
	_original_modulate = modulate
	
	# Initialize display values directly
	_set_display_happiness_percentage(Utils.get_total_creature_happiness_percentage())
	_set_display_money(SaveManager.save_file.money)
	_set_display_money_per_hour(Utils._money_per_hour)
	
	# Remove last target initializations
	# _last_target_happiness = initial_happiness
	# _last_target_money = initial_money
	# _last_target_money_per_hour = initial_mph
	
	VTInput.top_window_input.connect(_on_top_window_input)
	_process_scheduler.tick_second.connect(_on_tick_second)
	add_child(_process_scheduler)

########################################################
# Update Methods
########################################################

## Updates all relevant UI elements. Called every second by the process scheduler.
func _update_ui(_delta: float) -> void:
	_update_money_per_hour()
	_update_happiness_percentage()
	_update_time()
	_update_money()
	if Utils.all_menus_closed:
		_sleep_counter += _delta # Use _delta here
	if _sleep_counter >= SLEEP_DELAY and not _is_sleeping:
		_sleep()

## Updates the time label with the current system time in 12-hour format (e.g., 12:00 AM).
func _update_time() -> void:
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

## Updates the money label, tweening towards the target value.
func _update_money() -> void:
	var new_target: float = SaveManager.save_file.money
	
	# Simply create and start a new tween each update
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_method(_set_display_money, _display_money, new_target, HAPPINESS_LERP_DURATION)

## Updates the money-per-hour label, tweening towards the target value.
func _update_money_per_hour() -> void:
	var new_target: float = Utils._money_per_hour
	
	# Simply create and start a new tween each update
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_method(_set_display_money_per_hour, _display_money_per_hour, new_target, HAPPINESS_LERP_DURATION)

## Updates the happiness percentage label, tweening towards the target value.
func _update_happiness_percentage() -> void:
	var new_target: float = Utils.get_total_creature_happiness_percentage()

	# Simply create and start a new tween each update
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_method(_set_display_happiness_percentage, _display_happiness_percentage, new_target, HAPPINESS_LERP_DURATION)

########################################################
# Helper Methods
########################################################

## Setter method for the displayed money value, updates the label.
## Called by the money tween.
func _set_display_money(value: float) -> void:
	_display_money = value
	money_label.text = Utils.convert_long_float_to_string(value)

## Setter method for the displayed money per hour value, updates the label.
## Called by the money per hour tween.
func _set_display_money_per_hour(value: float) -> void:
	_display_money_per_hour = value
	money_per_hour_label.text = "+" + Utils.convert_long_float_to_string(value) + "/h"

## Setter method for the displayed happiness percentage, updates the label.
## Called by the happiness tween.
func _set_display_happiness_percentage(value: float) -> void:
	_display_happiness_percentage = value
	var happiness_display = int(round(_display_happiness_percentage * 100))
	happiness_percentage_label.text = str(happiness_display) + "%"

## Initiates the fade-to-transparent animation when the UI goes idle.
func _sleep() -> void:
	_is_sleeping = true
	_sleep_counter = 0.0

	# Create a tween to animate the transparency
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	var transparent_color = _original_modulate
	transparent_color.a = 0.2 # 20% opacity
	tween.tween_property(self, "modulate", transparent_color, SLEEP_ANIMATION_DURATION)

## Initiates the fade-to-opaque animation when user interaction occurs.
func _wake_up() -> void:
	if not _is_sleeping:
		return

	_is_sleeping = false
	_sleep_counter = 0.0

	# Create a tween to animate back to full opacity
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate", _original_modulate, SLEEP_ANIMATION_DURATION)

########################################################
# Signal Handlers
########################################################

## Handles input events on the top window to wake up the UI.
func _on_top_window_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_wake_up()

## Handles the tick_second signal from the process scheduler.
func _on_tick_second(delta: float) -> void:
	_update_ui(delta)
